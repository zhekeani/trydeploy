import { Injectable } from '@nestjs/common';

@Injectable()
export class PredictionsService {
  getHello(): string {
    return 'Hello World!';
  }
}
