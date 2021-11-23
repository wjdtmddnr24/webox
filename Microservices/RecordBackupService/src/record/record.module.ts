import { forwardRef, Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppModule } from '../app.module';
import { Block } from './entity/block.entity';
import { Record } from './entity/record.entity';
import { RecordController } from './record.controller';
import { RecordService } from './services/record.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([Record, Block]),
    forwardRef(() => AppModule),
  ],
  controllers: [RecordController],
  providers: [RecordService],
})
export class RecordModule {}
