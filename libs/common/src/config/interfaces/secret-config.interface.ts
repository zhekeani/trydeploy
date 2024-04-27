import { ServiceAccountKey } from '../../common';

export interface SecretsToLoad {
  dummy_secret: string;
}

export interface SecretConfig {
  secretAccessorKey: ServiceAccountKey;
  secretsToLoad: SecretsToLoad;
}
