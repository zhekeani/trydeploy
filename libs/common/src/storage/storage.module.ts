import { DynamicModule, Module } from '@nestjs/common';
import { Storage } from '@google-cloud/storage';
import { ConfigService } from '@nestjs/config';

import { StorageModuleConfig } from './interfaces/storage-module-config.interface';
import { StorageService } from './storage.service';

@Module({})
export class StorageModule {
  static forRootAsync(options: {
    useFactory: (
      ...args: any[]
    ) => Promise<StorageModuleConfig> | StorageModuleConfig;
    inject?: any[];
  }): DynamicModule {
    return {
      module: StorageModule,
      providers: [
        StorageService,
        {
          provide: 'BUCKET',
          useFactory: async (...args: any[]) => {
            const { serviceAccountKey, bucketName } = await options.useFactory(
              ...args,
            );

            const bucket = new Storage({
              projectId: serviceAccountKey.project_id,
              credentials: {
                client_email: serviceAccountKey.client_email,
                private_key: serviceAccountKey.private_key,
              },
            }).bucket(bucketName);

            return bucket;
          },
          inject: options.inject || [ConfigService],
        },
      ],
      exports: [StorageService],
    };
  }
}
