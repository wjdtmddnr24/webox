import { ConfigModule } from '@nestjs/config';
import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import {
  CredentialProviderChain,
  EnvironmentCredentials,
  S3,
  TokenFileWebIdentityCredentials,
} from 'aws-sdk';
import { AwsSdkModule } from 'nest-aws-sdk';
import { Block } from '../entity/block.entity';
import { Record } from '../entity/record.entity';
import { RecordService } from './record.service';

describe('RecordService', () => {
  let service: RecordService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      imports: [
        ConfigModule.forRoot(),
        AwsSdkModule.forRoot({
          defaultServiceOptions: {
            region: 'ap-northeast-2',
            credentialProvider: new CredentialProviderChain([
              () => new TokenFileWebIdentityCredentials(),
              () => new EnvironmentCredentials('AWS'),
            ]),
          },
          services: [S3],
        }),
      ],

      providers: [
        RecordService,
        { provide: getRepositoryToken(Record), useValue: {} },
        { provide: getRepositoryToken(Block), useValue: {} },
      ],
    }).compile();

    service = module.get<RecordService>(RecordService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it.todo('should storeBlock');
});
