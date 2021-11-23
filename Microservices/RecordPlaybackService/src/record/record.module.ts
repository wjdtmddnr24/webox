import { forwardRef, Module } from '@nestjs/common';
import { AppModule } from '../app.module';
import { RecordController } from './record.controller';
import { RecordService } from './record.service';

@Module({
  imports: [forwardRef(() => AppModule)],
  controllers: [RecordController],
  providers: [RecordService],
})
export class RecordModule {}
