import { Module } from '@nestjs/common';
import {
  ConfigService,
  ConfigModule as NestConfigModule,
} from '@nestjs/config';
import * as dotenv from 'dotenv';
import * as path from 'path';
import { isString, merge } from 'lodash';

import { databaseConfig } from './config_files/database.config';
import { secretConfig } from './config_files/secret.config';
import { SecretManagerServiceClient } from '@google-cloud/secret-manager';

dotenv.config({
  path: path.resolve('apps/predictions/.env'),
});

@Module({
  providers: [
    {
      provide: ConfigService,
      useFactory: async () => {
        let mergedConfig: Record<string, any> = {};
        let configFilesToLoad = [databaseConfig, secretConfig];

        const { secret } = secretConfig();

        // Check connecting to Secret Manager
        const client = new SecretManagerServiceClient({
          projectId: secret.secretAccessorKey.project_id,
          credentials: {
            client_email: secret.secretAccessorKey.client_email,
            private_key: secret.secretAccessorKey.private_key,
          },
        });

        const dummySecret = await client.accessSecretVersion({
          name: 'projects/play-ground-421204/secrets/dev-dummy-secret/versions/latest',
        });

        console.log(
          'this is dummy secret',
          dummySecret[0].payload.data.toString(),
        );

        const dummySecretConfig = {
          dummy: 'ahlo',
        };

        merge(mergedConfig, dummySecretConfig);

        configFilesToLoad.forEach((configFile) => {
          merge(mergedConfig, configFile());
        });

        return new ConfigService(mergedConfig);
      },
    },
  ],
  exports: [ConfigService],
})
export class ConfigModule {}
