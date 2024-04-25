import { NestFactory } from '@nestjs/core';
import { ConfigService } from '@nestjs/config';
import { DatabaseConfig, SecretConfig } from '@app/common';
import * as cookieParser from 'cookie-parser';
import { ValidationPipe } from '@nestjs/common';

import { PredictionsModule } from './predictions.module';

async function bootstrap() {
  const app = await NestFactory.create(PredictionsModule);

  const configService = app.get(ConfigService);
  const secretConfig = configService.get<SecretConfig>('secret');
  const rawDummyEnv = configService.get('DUMMY_ENV');

  app.use(cookieParser());

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
    }),
  );

  await app.listen(3000);
  console.log('this is from Secret Config ', secretConfig.secretAccessorKey);
  console.log('this is dummy secret version', secretConfig.dummy);
  console.log(rawDummyEnv);
}
bootstrap();
