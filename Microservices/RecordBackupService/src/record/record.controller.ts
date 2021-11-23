import { AmqpConnection } from '@golevelup/nestjs-rabbitmq';
import {
  BadRequestException,
  Body,
  Controller,
  Delete,
  Get,
  Headers,
  Param,
  ParseIntPipe,
  Post,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { Block } from './entity/block.entity';
import { Record, RecordUploadStatus } from './entity/record.entity';
import { RecordService } from './services/record.service';

@Controller('record')
export class RecordController {
  constructor(
    private readonly recordService: RecordService,
    private readonly amqpConnection: AmqpConnection,
  ) {}

  @Get()
  async getRecords(@Headers('userId') userId: string): Promise<Record[]> {
    return this.recordService.findAllRecords(userId);
  }

  @Get(':id')
  async getRecord(
    @Headers('userId') userId: string,
    @Param('id') recordId: string,
  ): Promise<Record> {
    return this.recordService.findOneRecord({ userId, recordId });
  }

  @Post()
  async createRecord(@Headers('userId') userId: string): Promise<Record> {
    return this.recordService.createRecord(userId);
  }

  @Post(':id/finish')
  async finishUpload(
    @Headers('userId') userId: string,
    @Param('id') recordId: string,
  ): Promise<Record> {
    const record = await this.recordService.findOneRecord({ userId, recordId });
    if (record.updateStatus == RecordUploadStatus.DONE)
      throw new BadRequestException(
        `Record "${record.id}" already finished uploading.`,
      );
    console.log(`Finished Upload of Record "${recordId}"`);
    this.amqpConnection.publish(
      'record-exchange',
      'record-upload-finished',
      record,
    );

    return this.recordService.finishBackup(userId, recordId);
  }

  @Delete(':id')
  async deleteRecord(
    @Headers('userId') userId: string,
    @Param('id') recordId: string,
  ) {
    const record = await this.recordService.findOneRecord({ userId, recordId });
    if (
      record.updateStatus == RecordUploadStatus.DONE &&
      !record.isVideoReady
    ) {
      throw new BadRequestException(
        `Cannot delete Record which is creating Video.`,
      );
    }
    await this.amqpConnection.request<boolean>({
      exchange: 'record-exchange',
      routingKey: 'delete-metadata',
      payload: recordId,
    });
    return this.recordService.deleteRecord(userId, recordId);
  }

  @Post(':id/block')
  @UseInterceptors(FileInterceptor('file'))
  async createBlock(
    @Headers('userId') userId: string,
    @Param('id') recordId: string,
    @UploadedFile()
    file: Express.Multer.File,
    @Body('offset', new ParseIntPipe()) offset: number,
    @Body('metadata') metadata: any,
  ): Promise<Block> {
    const block = await this.recordService.storeBlock(
      userId,
      recordId,
      offset,
      file.buffer,
    );
    console.log(
      `Received Block "${block.id}" of Record "${recordId}" from User "${userId}"`,
    );
    const payload = {
      id: block.id,
      recordId,
      userId,
      metadata,
    };

    this.amqpConnection.publish(
      'record-exchange',
      'block-upload-finished',
      payload,
    );

    return block;
  }
}
