import { ServiceAccountKey } from '@app/common';

export interface SecretConfig {
  secretAccessorKey: ServiceAccountKey;
  dummy?: string;
}
