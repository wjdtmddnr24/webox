import { IBlock } from './block.interface';

export enum RecordUploadStatus {
  UPLOADING = 'uploading',
  DONE = 'done',
}

export interface IRecord {
  id: string;
  thumbnailURL?: string;
  userId: string;
  isVideoReady: boolean;
  updateStatus: RecordUploadStatus;
  blocks: IBlock[];
  createdAt: Date;
  updatedAt: Date;
}
