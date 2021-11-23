import { Injectable } from '@nestjs/common';
import { S3 } from 'aws-sdk';
import { GetObjectRequest, PutObjectRequest } from 'aws-sdk/clients/s3';
import { InjectAwsService } from 'nest-aws-sdk';
import { IBlock } from '../interfaces/block.interface';
import { file, FileResult } from 'tmp-promise';
import * as fs from 'fs-extra';
import * as Ffmpeg from 'fluent-ffmpeg';
import { IRecord } from '../interfaces/record.interface';
import { AmqpConnection, RabbitSubscribe } from '@golevelup/nestjs-rabbitmq';
import { dirname, basename } from 'path';

@Injectable()
export class RecordService {
  constructor(
    @InjectAwsService(S3) private readonly s3: S3,
    private readonly amqpConnection: AmqpConnection,
  ) {}

  async fetchBlock(userId: string, block: IBlock): Promise<FileResult> {
    const params: GetObjectRequest = {
      Bucket: 'webox-record-bucket',
      Key: `${userId}/${block.recordId}/${block.id}.mp4`,
    };
    const tmpFile = await file({ postfix: '.mp4' });
    const { path } = tmpFile;
    const { Body } = await this.s3.getObject(params).promise();
    await fs.writeFile(path, Body);
    return tmpFile;
  }

  async fetchBlocks(userId: string, blocks: IBlock[]): Promise<FileResult[]> {
    return Promise.all(blocks.map((block) => this.fetchBlock(userId, block)));
  }

  async deleteFile(path: string): Promise<void> {
    return fs.unlink(path);
  }

  @RabbitSubscribe({
    exchange: 'record-exchange',
    routingKey: 'record-upload-finished',
    queue: 'record-upload-finished-queue',
  })
  async finalConcatBlocks({
    userId,
    id: recordId,
    blocks,
  }: IRecord): Promise<void> {
    let fetchedBlocks: FileResult[] = null;
    let recordVideo: FileResult;
    let thumbnailImage: FileResult;
    try {
      fetchedBlocks = await this.fetchBlocks(userId, blocks);
      recordVideo = await this.concatBlocks(fetchedBlocks);
      thumbnailImage = await this.createThumbnailImage(recordVideo);
      const thumbnailUploadParams: PutObjectRequest = {
        Bucket: 'webox-record-bucket',
        Key: `${userId}/${recordId}/thumbnail.png`,
        Body: fs.createReadStream(thumbnailImage.path),
        ACL: 'public-read',
      };
      const { Location: thumbnailURL } = await this.s3
        .upload(thumbnailUploadParams)
        .promise();
      console.log(`Created Thumbnail for Record "${recordId}"`);
      const videoUploadParams: PutObjectRequest = {
        Bucket: 'webox-record-bucket',
        Key: `${userId}/${recordId}/output.mp4`,
        Body: fs.createReadStream(recordVideo.path),
      };
      await this.s3.upload(videoUploadParams).promise();
      console.log(`Created Full Video of Record "${recordId}"`);
      await thumbnailImage.cleanup();
      await recordVideo.cleanup();
      this.amqpConnection.publish('record-exchange', 'video-created', {
        recordId,
        thumbnailURL,
      });
    } catch (e) {
      console.error(e);
      try {
        fetchedBlocks &&
          Promise.all(fetchedBlocks.map((f) => f.cleanup())).catch(
            console.error,
          );
        recordVideo && (await recordVideo.cleanup().catch(console.error));
        thumbnailImage && (await thumbnailImage.cleanup().catch(console.error));
      } catch (e) {
        console.error(e);
      }
      this.amqpConnection.publish('record-exchange', 'video-created', {
        recordId,
        thumbnailURL: null,
      });
    }
  }

  async getPreSignedURL({ userId, id: recordId }: IRecord): Promise<string> {
    const params = {
      Bucket: 'webox-record-bucket',
      Key: `${userId}/${recordId}/output.mp4`,
    };
    return this.s3.getSignedUrlPromise('getObject', params);
  }

  async createThumbnailImage(video: FileResult): Promise<FileResult> {
    const tmpFile = await file({ postfix: '.png' });
    const tmpDirname = dirname(tmpFile.path);
    const tmpFilename = basename(tmpFile.path);
    try {
      await new Promise((resolve, reject) => {
        Ffmpeg()
          .on('error', reject)
          .on('end', resolve)
          .input(video.path)
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

  async concatBlocks(fetchedBlocks: FileResult[]): Promise<FileResult> {
    const command = fetchedBlocks.reduce((p, c) => p.input(c.path), Ffmpeg());
    const tmpFile = await file({ postfix: '.mp4' });
    try {
      await new Promise((resolve, reject) => {
        command
          .addOutputOption(['-preset veryfast'])
          .on('error', reject)
          .on('end', resolve)
          .mergeToFile(tmpFile.path);
      });
    } catch (error) {
      throw error;
    } finally {
      await Promise.all(fetchedBlocks.map((f) => f.cleanup()));
    }
    return tmpFile;
  }
}
