import { DynamicModule, Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { SecretManagerServiceClient } from '@google-cloud/secret-manager';
import * as dotenv from 'dotenv';
import { merge } from 'lodash';
import * as path from 'path';

import { rewriteRecordWithSecrets } from './utils/config_loader';
import { SecretConfig } from './interfaces';

dotenv.config({
  path: path.resolve('apps/predictions/.env'),
});

@Module({})
export class ConfigModule {
  static forRootAsync(options: {
    loads: any[];
    secretConfig: () => { secret: SecretConfig };
  }): DynamicModule {
    return {
      module: ConfigModule,
      providers: [
        {
          provide: ConfigService,
          useFactory: async () => {
            let mergedConfig: Record<string, any> = {};
            let configsToLoad: any[] = options.loads;

            const { secret } = options.secretConfig();
            let secretsToLoad = secret.secretsToLoad;

            // Check connecting to Secret Manager
            const client = new SecretManagerServiceClient({
              projectId: secret.secretAccessorKey.project_id,
              credentials: {
                client_email: secret.secretAccessorKey.client_email,
                private_key: secret.secretAccessorKey.private_key,
              },
            });

            await rewriteRecordWithSecrets(secretsToLoad, undefined, client);

            const loadedSecrets = () => ({
              secrets: secretsToLoad,
            });

            configsToLoad.push(loadedSecrets);

            configsToLoad.forEach((configFile) => {
              mergedConfig = merge(mergedConfig, configFile());
            });

            return new ConfigService(mergedConfig);
          },
        },
      ],
      exports: [ConfigService],
    };
  }
}
