import { forwardRef, Module } from '@nestjs/common';
import { RecordService } from './record.service';
import { RecordController } from './record.controller';
import { AppModule } from '../app.module';
import { TypeOrmModule } from '@nestjs/typeorm';
import { BlockMetadata } from './entity/block-metadata.entity';
import { HttpModule } from '@nestjs/axios';

@Module({
  imports: [
    HttpModule,
    TypeOrmModule.forFeature([BlockMetadata]),
    forwardRef(() => AppModule),
  ],
  providers: [RecordService],
  controllers: [RecordController],
})
export class RecordModule {}
