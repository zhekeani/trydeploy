import {
  Controller,
  Get,
  Post,
  UploadedFile,
  UseInterceptors,
  Body,
} from '@nestjs/common';
import { PredictionsService } from './predictions.service';
import { FileInterceptor } from '@nestjs/platform-express';

@Controller()
export class PredictionsController {
  constructor(private readonly predictionsService: PredictionsService) {}

  @Get()
  getHello(): string {
    return this.predictionsService.getHello();
  }

  @Get('/dummy')
  getDummySecret(): string {
    return this.predictionsService.getDummySecret();
  }

  @Post('/upload')
  @UseInterceptors(FileInterceptor('file'))
  uploadFile(
    @UploadedFile() file: Express.Multer.File,
    @Body() body: { fileName: string },
  ) {
    return this.predictionsService.uploadPic(file, body.fileName);
  }
}
