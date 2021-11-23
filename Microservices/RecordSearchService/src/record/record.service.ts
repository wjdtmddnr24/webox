import { RabbitRPC, RabbitSubscribe } from '@golevelup/nestjs-rabbitmq';
import { HttpService } from '@nestjs/axios';
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { S3 } from 'aws-sdk';
import * as FormData from 'form-data';
import { createReadStream } from 'fs';
import { InjectAwsService } from 'nest-aws-sdk';
import { Repository } from 'typeorm';
import { BlockMetadata, objects } from './entity/block-metadata.entity';
import { SearchRecordsDto } from './search-records.dto';
import * as Ffmpeg from 'fluent-ffmpeg';
import { file, FileResult } from 'tmp-promise';
import { basename, dirname } from 'path';

@Injectable()
export class RecordService {
  constructor(
    @InjectRepository(BlockMetadata)
    private readonly blockMetadatasRepository: Repository<BlockMetadata>,
    @InjectAwsService(S3) private readonly s3: S3,
    private readonly httpService: HttpService,
  ) {}

  async getBlockMetadatasByRecordId(
    recordId: string,
  ): Promise<BlockMetadata[]> {
    return this.blockMetadatasRepository.find({
      where: { recordId },
    });
  }

  async searchRecordIds(
    userId: string,
    searchRecordsDto: SearchRecordsDto,
  ): Promise<string[]> {
    const queryBuilder = this.blockMetadatasRepository
      .createQueryBuilder('block_metadata')
      .distinct(true)
      .select('block_metadata.recordId', 'recordId')
      .where('block_metadata.userId= :userId', { userId });

    if (searchRecordsDto.capturedAt)
      queryBuilder.andWhere(
        'block_metadata.createdAt BETWEEN :start AND :end',
        {
          start: searchRecordsDto.capturedAt.start,
          end: searchRecordsDto.capturedAt.end,
        },
      );

    if (searchRecordsDto.location)
      queryBuilder.andWhere(
        'ST_DWithin(block_metadata.location, ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326), :distance)',
        {
          ...searchRecordsDto.location,
        },
      );

    if (
      searchRecordsDto.match_objects &&
      searchRecordsDto.match_objects.length > 0
    ) {
      const match_objects = [...new Set(searchRecordsDto.match_objects)].filter(
        (obj) => objects.includes(obj),
      );

      for (const obj of match_objects)
        queryBuilder.andWhere(`block_metadata.obj_${obj} IS TRUE`);
    }

    const filteredRecordIds: string[] = (await queryBuilder.getRawMany()).map(
      (bm) => bm['recordId'],
    );

    return filteredRecordIds;
  }

  async searchOtherUsersRecordIds(
    userId: string,
    searchRecordsDto: SearchRecordsDto,
  ): Promise<string[]> {
    const queryBuilder = this.blockMetadatasRepository
      .createQueryBuilder('block_metadata')
      .distinct(true)
      .select('block_metadata.recordId', 'recordId')
      .where('block_metadata.userId != :userId', { userId });

    if (searchRecordsDto.capturedAt)
      queryBuilder.andWhere(
        'block_metadata.createdAt BETWEEN :start AND :end',
        {
          start: searchRecordsDto.capturedAt.start,
          end: searchRecordsDto.capturedAt.end,
        },
      );

    if (searchRecordsDto.location)
      queryBuilder.andWhere(
        'ST_DWithin(block_metadata.location, ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326), :distance)',
        {
          ...searchRecordsDto.location,
        },
      );

    if (
      searchRecordsDto.match_objects &&
      searchRecordsDto.match_objects.length > 0
    ) {
      const match_objects = [...new Set(searchRecordsDto.match_objects)].filter(
        (obj) => objects.includes(obj),
      );

      for (const obj of match_objects)
        queryBuilder.andWhere(`block_metadata.obj_${obj} IS TRUE`);
    }

    const filteredRecordIds: string[] = (await queryBuilder.getRawMany()).map(
      (bm) => bm['recordId'],
    );

    return filteredRecordIds;
  }

  async createImage(videoURL: string): Promise<FileResult> {
    const tmpFile = await file({ postfix: '.png' });
    const tmpDirname = dirname(tmpFile.path);
    const tmpFilename = basename(tmpFile.path);
    try {
      await new Promise((resolve, reject) => {
        Ffmpeg()
          .on('error', reject)
          .on('end', resolve)
          .input(videoURL)
          .thumbnail({
            folder: tmpDirname,
            filename: tmpFilename,
            timestamps: [0.1],
          });
      });
    } catch (error) {
      throw error;
    }
    return tmpFile;
  }

  async getObjectNames(imagePath: string): Promise<string[]> {
    try {
      const url =
        'http://object-detection-service-webox-object-detection-service.webox:5000/inference';
      const form = new FormData();
      form.append('file', createReadStream(imagePath));
      const result = await this.httpService
        .post<{ class: number }[]>(url, form, {
          headers: form.getHeaders(),
        })
        .toPromise();
      const object_names = [...new Set(result.data.map((e) => e.class))].map(
        (e) => objects[e],
      );
      return object_names;
    } catch (e) {
      console.error(e);
      return [];
    }
  }

  @RabbitSubscribe({
    exchange: 'record-exchange',
    routingKey: 'block-upload-finished',
    queue: 'record-block-upload-finished-queue',
  })
  async createBlockMetadata({
    id,
    recordId,
    userId,
    metadata: { createdAt, location },
  }: {
    id: string;
    recordId: string;
    userId: string;
    metadata: {
      createdAt: Date;
      location?: { longitude: number; latitude: number };
    };
  }): Promise<void> {
    try {
      const blockMetadata = await this.blockMetadatasRepository.create({
        id,
        recordId,
        userId,
        createdAt,
        ...(location && {
          location: {
            type: 'Point',
            coordinates: [location.longitude, location.latitude],
          },
        }),
      });
      await this.blockMetadatasRepository.save(blockMetadata);
      const { path, cleanup } = await this.createImage(
        `https://webox-record-bucket.s3.ap-northeast-2.amazonaws.com/${blockMetadata.userId}/${blockMetadata.recordId}/${blockMetadata.id}.mp4`,
      );
      const object_names = await this.getObjectNames(path);
      console.log(`block "${id}" has object_names: ${object_names}"`);
      await cleanup();
      for (const object_name of object_names)
        blockMetadata[`obj_${object_name}`] = true;
      await this.blockMetadatasRepository.save(blockMetadata);
    } catch (e) {
      console.error(e);
    }
  }

  @RabbitRPC({
    exchange: 'record-exchange',
    routingKey: 'delete-metadata',
    queue: 'record-delete-metadata-queue',
  })
  async deleteBlockMetadatas(recordId: string): Promise<boolean> {
    try {
      await this.blockMetadatasRepository.delete({ recordId });
      return true;
    } catch (e) {
      return false;
    }
  }
}
