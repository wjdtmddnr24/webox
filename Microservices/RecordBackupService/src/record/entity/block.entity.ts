import {
  Column,
  Entity,
  ManyToOne,
  PrimaryGeneratedColumn,
  Unique,
} from 'typeorm';
import { BaseEntity } from './base.entity';
import { Record } from './record.entity';

@Entity()
@Unique(['recordId', 'offset'])
export class Block extends BaseEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  offset: number;

  @Column()
  recordId: string;

  @ManyToOne((type) => Record, (record) => record.blocks, {
    onDelete: 'CASCADE',
  })
  record: Record;
}
