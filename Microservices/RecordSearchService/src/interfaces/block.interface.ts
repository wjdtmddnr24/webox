import { BlockMetadata } from '../record/entity/block-metadata.entity';
import { IRecord } from './record.interface';

export interface IBlock {
  id: string;
  offset: number;
  metadata?: BlockMetadata;
  recordId: string;
  record: IRecord;
  createdAt: Date;
  updatedAt: Date;
}
