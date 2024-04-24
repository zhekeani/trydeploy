import { NestFactory } from '@nestjs/core';
import { PredictionsModule } from './predictions.module';

async function bootstrap() {
  const app = await NestFactory.create(PredictionsModule);
  await app.listen(3000);
}
bootstrap();
