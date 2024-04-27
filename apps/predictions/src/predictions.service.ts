import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { StorageService } from '@app/common';
import { join } from 'path';

@Injectable()
export class PredictionsService {
  private pathPrefix: string = 'media';

  constructor(
    private readonly configService: ConfigService,
    private readonly storageService: StorageService,
  ) {}

  getHello(): string {
    return 'Hello World!';
  }

  getDummySecret(): string {
    const secrets = this.configService.get('secrets');
    return secrets.dummy_secret;
  }

  constructPath(fileName: string) {
    return join(this.pathPrefix, '/', fileName);
  }

  uploadPic(file: Express.Multer.File, fileName: string) {
    const filePath = this.constructPath(fileName);

    return this.storageService.save(filePath, file.mimetype, file.buffer, []);
  }
}
