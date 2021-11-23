import {
  AfterLoad,
  Column,
  Entity,
  OneToMany,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { BaseEntity } from './base.entity';
import { Block } from './block.entity';

export enum RecordUploadStatus {
  UPLOADING = 'uploading',
  DONE = 'done',
  ERROR = 'error',
}

@Entity()
export class Record extends BaseEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ nullable: true })
  thumbnailURL?: string;

  @Column()
  userId: string;

  @Column({ default: false })
  isVideoReady: boolean;

  @Column({
    type: 'enum',
    enum: RecordUploadStatus,
    default: RecordUploadStatus.UPLOADING,
  })
  updateStatus: RecordUploadStatus;

  @OneToMany((type) => Block, (block) => block.record, { cascade: true })
  blocks: Block[];

  @AfterLoad()
  sortBlocksByOffset() {
    if (this?.blocks?.length) {
      this.blocks.sort((a, b) =>
        a.offset < b.offset ? -1 : a.offset === b.offset ? 0 : 1,
      );
    }
  }
}
