import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { RecordModule } from './record/record.module';
import { HealthController } from './health/health.controller';
import { TerminusModule } from '@nestjs/terminus';
import { TypeOrmModule } from '@nestjs/typeorm';
import * as Joi from 'joi';
import { AwsSdkModule } from 'nest-aws-sdk';
import {
  CredentialProviderChain,
  EnvironmentCredentials,
  S3,
  TokenFileWebIdentityCredentials,
} from 'aws-sdk';
import { RabbitMQModule } from '@golevelup/nestjs-rabbitmq';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      validationSchema: Joi.object({
        DB_HOST: Joi.string().required(),
        DB_PORT: Joi.number().default(5432),
        DB_USERNAME: Joi.string().required(),
        DB_PASSWORD: Joi.string().required(),
        DB_DATABASE: Joi.string().default('record'),
        RMQ_USERNAME: Joi.string().required(),
        RMQ_PASSWORD: Joi.string().required(),
        RMQ_HOST: Joi.string().required(),
      }),
    }),
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
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DB_HOST,
      port: +process.env.DB_PORT,
      username: process.env.DB_USERNAME,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_DATABASE,
      autoLoadEntities: true,
      synchronize: true,
    }),
    RecordModule,
    TerminusModule,
    RabbitMQModule.forRoot(RabbitMQModule, {
      uri: `amqps://${process.env.RMQ_USERNAME}:${process.env.RMQ_PASSWORD}@${process.env.RMQ_HOST}`,
      exchanges: [{ name: 'record-exchange', type: 'topic' }],
    }),
  ],
  controllers: [AppController, HealthController],
  providers: [AppService],
  exports: [RabbitMQModule],
})
export class AppModule {}
