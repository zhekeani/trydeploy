import { ServicesConfig } from '@app/common';
import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { NestFactory } from '@nestjs/core';
import * as cookieParser from 'cookie-parser';

import { PredictionsModule } from './predictions.module';

async function bootstrap() {
  const app = await NestFactory.create(PredictionsModule);

  const configService = app.get(ConfigService);
  const servicesConfig = configService.get<ServicesConfig>('services');

  app.use(cookieParser());

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
    }),
  );

  await app.listen(servicesConfig.predictions.http_port);
}
bootstrap();
