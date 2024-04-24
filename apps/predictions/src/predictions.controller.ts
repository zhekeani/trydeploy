import { Controller, Get } from '@nestjs/common';
import { PredictionsService } from './predictions.service';

@Controller()
export class PredictionsController {
  constructor(private readonly predictionsService: PredictionsService) {}

  @Get()
  getHello(): string {
    return this.predictionsService.getHello();
  }
}
