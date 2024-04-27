import { NestFactory } from '@nestjs/core';
import { ConfigService } from '@nestjs/config';
import { DatabaseConfig, SecretConfig, StorageConfig } from '@app/common';
import * as cookieParser from 'cookie-parser';
import { ValidationPipe } from '@nestjs/common';

import { PredictionsModule } from './predictions.module';

async function bootstrap() {
  const app = await NestFactory.create(PredictionsModule);

  const configService = app.get(ConfigService);
  const secrets = configService.get('secrets');
  const rawDummyEnv = configService.get('DUMMY_ENV');

  app.use(cookieParser());

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
    }),
  );

  await app.listen(3000);
  console.log('this is from Secret Config ', secrets);
  console.log(rawDummyEnv);
}
bootstrap();
