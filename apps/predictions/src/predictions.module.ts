import { Module } from '@nestjs/common';
import { PredictionsController } from './predictions.controller';
import { PredictionsService } from './predictions.service';
import { databaseConfig } from './config/config_files/database.config';
import { secretConfig } from './config/config_files/secret.config';
import { ConfigModule } from '@app/common';

@Module({
  imports: [
    ConfigModule.forRootAsync({
      loads: [databaseConfig, secretConfig],
      secretConfig: secretConfig,
    }),
  ],
  controllers: [PredictionsController],
  providers: [PredictionsService],
})
export class PredictionsModule {}
