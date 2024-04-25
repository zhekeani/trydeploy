import { DynamicModule, Module } from '@nestjs/common';
import { DatabaseModuleConfig } from './interfaces';
import {
  ModelDefinition,
  MongooseModule,
  MongooseModuleOptions,
} from '@nestjs/mongoose';
import { ConfigService } from '@nestjs/config';
import { DeploymentStage, EnvironmentRuntime } from '../common';

@Module({})
export class DatabaseModule {
  static forRootAsync(options: {
    useFactory: (
      ...args: any[]
    ) => Promise<DatabaseModuleConfig> | DatabaseModuleConfig;
    inject?: any[];
  }): DynamicModule {
    return MongooseModule.forRootAsync({
      inject: options.inject || [ConfigService],
      useFactory: async (...args: any[]) => {
        const mongooseConfig: MongooseModuleOptions = {};

        const { deploymentStage, environmentRuntime, appName, databaseConfig } =
          await options.useFactory(...args);

        switch (deploymentStage) {
          case DeploymentStage.Development:
            mongooseConfig.uri = `${environmentRuntime}-${databaseConfig.mongodb_uri}-${appName}`;
            break;

          case DeploymentStage.Testing:
            mongooseConfig.uri = `${environmentRuntime}-${databaseConfig.mongodb_testing_uri}-${appName}`;
        }

        return mongooseConfig;
      },
    });
  }

  static forFeature(models: ModelDefinition[]) {
    return MongooseModule.forFeature(models);
  }
}
