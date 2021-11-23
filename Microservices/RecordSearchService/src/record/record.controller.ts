import { AmqpConnection, RabbitRPC } from '@golevelup/nestjs-rabbitmq';
import {
  Body,
  Controller,
  forwardRef,
  Get,
  Headers,
  Inject,
  Post,
} from '@nestjs/common';
import { IRecord } from '../interfaces/record.interface';
import { RecordService } from './record.service';
import { SearchRecordsDto } from './search-records.dto';

@Controller('record')
export class RecordController {
  constructor(
    @Inject(forwardRef(() => AmqpConnection))
    private readonly amqpConnection: AmqpConnection,
    private readonly recordService: RecordService,
  ) {}

  @Post()
  async searchRecords(
    @Headers('userId') userId: string,
    @Body() searchRecordsDto: SearchRecordsDto,
  ): Promise<IRecord[]> {
    const recordIds: string[] = await this.recordService.searchRecordIds(
      userId,
      searchRecordsDto,
    );

    if (recordIds.length == 0) return [];

    const records: IRecord[] = await this.amqpConnection.request<IRecord[]>({
      exchange: 'record-exchange',
      routingKey: 'request-records',
      payload: recordIds,
    });
    for (const record of records) {
      const blockMatadatas =
        await this.recordService.getBlockMetadatasByRecordId(record.id);
      for (const blockMetadata of blockMatadatas) {
        const block = record.blocks.find((b) => b.id == blockMetadata.id);
        if (block) block.metadata = blockMetadata;
      }
    }
    return records;
  }

  @Post('others')
  async searchOtherUsersRecords(
    @Headers('userId') userId: string,
    @Body() searchRecordsDto: SearchRecordsDto,
  ): Promise<IRecord[]> {
    const recordIds: string[] =
      await this.recordService.searchOtherUsersRecordIds(
        userId,
        searchRecordsDto,
      );

    if (recordIds.length == 0) return [];

    const records: IRecord[] = await this.amqpConnection.request<IRecord[]>({
      exchange: 'record-exchange',
      routingKey: 'request-records',
      payload: recordIds,
    });
    for (const record of records) {
      const blockMatadatas =
        await this.recordService.getBlockMetadatasByRecordId(record.id);
      for (const blockMetadata of blockMatadatas) {
        const block = record.blocks.find((b) => b.id == blockMetadata.id);
        if (block) block.metadata = blockMetadata;
      }
    }
    return records;
  }
}
