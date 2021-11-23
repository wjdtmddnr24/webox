import { IRecord } from './record.interface';

export interface IBlock {
  id: string;
  offset: number;
  recordId: string;
  record: IRecord;
  createdAt: Date;
  updatedAt: Date;
}
