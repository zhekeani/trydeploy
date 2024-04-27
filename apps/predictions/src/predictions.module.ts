import { Module } from '@nestjs/common';
import {
  ConfigService,
  ConfigModule as NestConfigModule,
} from '@nestjs/config';
import { PredictionsController } from './predictions.controller';
import { PredictionsService } from './predictions.service';
import { databaseConfig } from './config/config_files/database.config';
import { secretConfig } from './config/config_files/secret.config';
import {
  ConfigModule,
  SecretConfig,
  ServiceAccountKey,
  StorageConfig,
  StorageModule,
} from '@app/common';
import { storageConfig } from './config/config_files/storage.config';

@Module({
  imports: [
    ConfigModule.forRootAsync({
      loads: [databaseConfig, secretConfig, storageConfig],
      secretConfig: secretConfig,
    }),
    StorageModule.forRootAsync({
      configModuleConfig: {
        secretConfig: secretConfig,
        loads: [storageConfig],
      },
      useFactory: (configService: ConfigService) => {
        const { object_admin_sa_key: encodedObjectAdmin } =
          configService.get('secrets');
        const { bucket_name: bucketName } =
          configService.get<StorageConfig>('storage');
        const objectAdminServiceAccountKey: ServiceAccountKey = JSON.parse(
          Buffer.from(encodedObjectAdmin, 'base64').toString(),
        );

        return {
          serviceAccountKey: objectAdminServiceAccountKey,
          bucketName,
        };
      },
    }),
  ],
  controllers: [PredictionsController],
  providers: [PredictionsService],
})
export class PredictionsModule {}
