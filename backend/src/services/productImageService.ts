import mongoose from 'mongoose';
import { ProductImage } from '../models/ProductImage.js';

export const productImageService = {
  async saveImage(
    data: Buffer,
    contentType: string,
    fileName: string
  ): Promise<string> {
    const image = await ProductImage.create({
      data,
      contentType,
      fileName
    });

    return image._id.toString();
  },

  async getImage(id: string) {
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return null;
    }

    return ProductImage.findById(id).select('data contentType fileName');
  }
};
