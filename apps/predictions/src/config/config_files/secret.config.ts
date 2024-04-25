import { SecretConfig, ServiceAccountKey } from '@app/common';
import * as dotenv from 'dotenv';
import * as path from 'path';

dotenv.config({
  path: path.resolve('apps/predictions/.env'),
});

const encodedSecretAccessorKey = process.env.SA_SECRET_ACCESSOR_KEY;

const decodedSecretAccessorKey: ServiceAccountKey = JSON.parse(
  Buffer.from(encodedSecretAccessorKey, 'base64').toString(),
);

const decodedSecretConfig: SecretConfig = {
  secretAccessorKey: decodedSecretAccessorKey,
};

export const secretConfig = () => ({
  secret: decodedSecretConfig,
});
