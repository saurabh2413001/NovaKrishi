import mongoose, { Schema, Document } from 'mongoose';

export interface IProductImage extends Document {
  _id: mongoose.Types.ObjectId;
  data: Buffer;
  contentType: string;
  fileName: string;
  createdAt: Date;
}

const ProductImageSchema = new Schema<IProductImage>(
  {
    data: {
      type: Buffer,
      required: true
    },
    contentType: {
      type: String,
      required: true
    },
    fileName: {
      type: String,
      default: 'product-image'
    }
  },
  {
    timestamps: true
  }
);

export const ProductImage = mongoose.model<IProductImage>(
  'ProductImage',
  ProductImageSchema
);
