import { AmqpConnection } from '@golevelup/nestjs-rabbitmq';
import {
  BadRequestException,
  Controller,
  forwardRef,
  Get,
  Headers,
  Inject,
  Param,
} from '@nestjs/common';
import { IRecord } from '../interfaces/record.interface';
import { RecordService } from './record.service';

@Controller('record')
export class RecordController {
  constructor(
    @Inject(forwardRef(() => AmqpConnection))
    private readonly amqpConnection: AmqpConnection,
    private readonly recordService: RecordService,
  ) {}

  @Get(':id')
  async getRecordVideo(
    @Headers('userId') userId = 'user123',
    @Param('id') recordId: string,
  ): Promise<string> {
    const record: IRecord = await this.amqpConnection.request<IRecord>({
      exchange: 'record-exchange',
      routingKey: 'request-one-record',
      payload: { recordId, userId },
    });
    if (!record.isVideoReady)
      throw new BadRequestException('Record Video is Not Ready');

    return this.recordService.getPreSignedURL(record);
  }
}
