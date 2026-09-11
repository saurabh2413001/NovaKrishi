import mongoose from 'mongoose';
import { ProductImage } from '../models/ProductImage.js';
export const productImageService = {
    async saveImage(data, contentType, fileName) {
        const image = await ProductImage.create({
            data,
            contentType,
            fileName
        });
        return image._id.toString();
    },
    async getImage(id) {
        if (!mongoose.Types.ObjectId.isValid(id)) {
            return null;
        }
        return ProductImage.findById(id).select('data contentType fileName');
    }
};
