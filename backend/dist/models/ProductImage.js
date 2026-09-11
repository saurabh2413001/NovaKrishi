import mongoose, { Schema } from 'mongoose';
const ProductImageSchema = new Schema({
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
}, {
    timestamps: true
});
export const ProductImage = mongoose.model('ProductImage', ProductImageSchema);
