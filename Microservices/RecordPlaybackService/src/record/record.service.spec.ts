import { AmqpConnection } from '@golevelup/nestjs-rabbitmq';
import { Test, TestingModule } from '@nestjs/testing';
import {
  CredentialProviderChain,
  EnvironmentCredentials,
  S3,
  TokenFileWebIdentityCredentials,
} from 'aws-sdk';
import { AwsSdkModule } from 'nest-aws-sdk';
import { RecordService } from './record.service';

describe('RecordService', () => {
  let service: RecordService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      imports: [
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
      providers: [RecordService, { provide: AmqpConnection, useValue: {} }],
    }).compile();

    service = module.get<RecordService>(RecordService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
