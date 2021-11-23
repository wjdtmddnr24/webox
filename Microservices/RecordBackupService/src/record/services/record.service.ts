import { RabbitRPC, RabbitSubscribe } from '@golevelup/nestjs-rabbitmq';
import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { S3 } from 'aws-sdk';
import {
  DeleteObjectRequest,
  DeleteObjectsRequest,
  PutObjectRequest,
} from 'aws-sdk/clients/s3';
import { InjectAwsService } from 'nest-aws-sdk';
import { Repository } from 'typeorm';
import { Block } from '../entity/block.entity';
import { Record, RecordUploadStatus } from '../entity/record.entity';

@Injectable()
export class RecordService {
  constructor(
    @InjectRepository(Record)
    private readonly recordsRepository: Repository<Record>,
    @InjectRepository(Block)
    private readonly blocksRepository: Repository<Block>,
    @InjectAwsService(S3) private readonly s3: S3,
  ) {}

  async findAllRecords(userId: string): Promise<Record[]> {
    return this.recordsRepository.find({
      where: { userId },
      relations: ['blocks'],
      order: {
        createdAt: 'DESC',
      },
    });
  }

  @RabbitRPC({
    exchange: 'record-exchange',
    routingKey: 'request-records',
    queue: 'record-request-records-queue',
  })
  async findRecordsByIds(recordIds: string[]): Promise<Record[]> {
    return this.recordsRepository.findByIds(recordIds, {
      relations: ['blocks'],
      order: {
        createdAt: 'DESC',
      },
    });
  }

  @RabbitRPC({
    exchange: 'record-exchange',
    routingKey: 'request-one-record',
    queue: 'record-request-one-record-queue',
  })
  async findOneRecord({
    userId,
    recordId,
  }: {
    userId?: string;
    recordId: string;
  }): Promise<Record> {
    const options = {
      where: { id: recordId, ...(userId && { userId }) },
      relations: ['blocks'],
    };
    const record = await this.recordsRepository.findOne(options);
    return record;
  }

  async createRecord(userId: string): Promise<Record> {
    const record = this.recordsRepository.create({ userId });
    return this.recordsRepository.save(record);
  }

  async updateRecord(userId: string, data: Partial<Record>): Promise<Record> {
    await this.findOneRecord({ userId, recordId: data.id });
    return this.recordsRepository.save(
      await this.recordsRepository.preload(data),
    );
  }

  async deleteRecord(userId: string, recordId: string): Promise<Record> {
    const record = await this.findOneRecord({ userId, recordId });
    await this.recordsRepository.remove(record);
    const objects = await this.s3
      .listObjects({
        Bucket: 'webox-record-bucket',
        Prefix: `${userId}/${recordId}`,
      })
      .promise();
    const params: DeleteObjectsRequest = {
      Bucket: 'webox-record-bucket',
      Delete: { Objects: objects.Contents.map(({ Key }) => ({ Key })) },
    };
    await this.s3.deleteObjects(params).promise();
    return record;
  }

  async findAllBlocks(recordId: string): Promise<Block[]> {
    const blocks: Block[] = await this.blocksRepository.find({
      where: { recordId },
      relations: ['record'],
    });
    return blocks;
  }

  async findOneBlock(blockId: string): Promise<Block> {
    const block = await this.blocksRepository.findOne(blockId, {
      relations: ['record'],
    });
    if (!block) throw new NotFoundException(`Block "${blockId}" Not Found."`);
    return block;
  }

  async deleteBlock(blockId: string): Promise<Block> {
    const block = await this.findOneBlock(blockId);
    await this.blocksRepository.remove(block);
    const {
      recordId,
      record: { userId },
    } = block;
    const params: DeleteObjectRequest = {
      Bucket: 'webox-record-bucket',
      Key: `${userId}/${recordId}/${block.id}.mp4`,
    };
    await this.s3.deleteObject(params).promise();
    return block;
  }

  async storeBlock(
    userId: string,
    recordId: string,
    offset: number,
    buffer: Buffer,
  ): Promise<Block> {
    const record = await this.findOneRecord({ userId, recordId });
    const block = await this.blocksRepository.save(
      this.blocksRepository.create({ offset, record }),
    );
    const params: PutObjectRequest = {
      Bucket: 'webox-record-bucket',
      Key: `${userId}/${recordId}/${block.id}.mp4`,
      Body: buffer,
      ACL: 'public-read',
    };
    await this.s3.upload(params).promise();
    return block;
  }

  @RabbitSubscribe({
    exchange: 'record-exchange',
    routingKey: 'video-created',
    queue: 'record-video-created-queue',
  })
  async setVideoReady({
    recordId,
    thumbnailURL,
  }: {
    recordId: string;
    thumbnailURL?: string;
  }): Promise<void> {
    const record = await this.findOneRecord({ recordId });
    if (thumbnailURL == null) {
      record.updateStatus = RecordUploadStatus.ERROR;
    } else {
      record.isVideoReady = true;
      record.thumbnailURL = thumbnailURL;
    }
    await this.recordsRepository.save(record);
  }

  async finishBackup(userId: string, recordId: string): Promise<Record> {
    const record = await this.findOneRecord({ userId, recordId });
    record.updateStatus = RecordUploadStatus.DONE;
    return this.recordsRepository.save(record);
  }
}
