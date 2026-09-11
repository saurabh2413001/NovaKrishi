import { productImageService } from '../services/productImageService.js';
export const productImageController = {
    async uploadImage(req, res) {
        try {
            const { imageBase64, contentType, fileName } = req.body ?? {};
            if (typeof imageBase64 !== 'string' || !imageBase64.trim()) {
                return res.status(400).json({
                    success: false,
                    message: 'Product image is required.'
                });
            }
            if (typeof contentType !== 'string' ||
                !contentType.toLowerCase().startsWith('image/')) {
                return res.status(400).json({
                    success: false,
                    message: 'Only image files are allowed.'
                });
            }
            const cleanBase64 = imageBase64.replace(/^data:image\/[^;]+;base64,/, '');
            const data = Buffer.from(cleanBase64, 'base64');
            if (!data.length) {
                return res.status(400).json({
                    success: false,
                    message: 'Image file is empty or invalid.'
                });
            }
            if (data.length > 8 * 1024 * 1024) {
                return res.status(413).json({
                    success: false,
                    message: 'Image must be smaller than 8 MB.'
                });
            }
            const id = await productImageService.saveImage(data, contentType, typeof fileName === 'string' && fileName.trim()
                ? fileName.trim()
                : 'product-image');
            return res.status(201).json({
                success: true,
                imageId: id,
                imageUrl: `/api/product-images/${id}`
            });
        }
        catch (error) {
            console.error('Error saving product image:', error);
            return res.status(500).json({
                success: false,
                message: 'Unable to save product image.'
            });
        }
    },
    async getImage(req, res) {
        try {
            const image = await productImageService.getImage(req.params.id);
            if (!image) {
                return res.status(404).json({
                    success: false,
                    message: 'Image not found.'
                });
            }
            res.setHeader('Content-Type', image.contentType);
            res.setHeader('Cache-Control', 'public, max-age=31536000, immutable');
            return res.send(image.data);
        }
        catch (error) {
            console.error('Error fetching product image:', error);
            return res.status(500).json({
                success: false,
                message: 'Unable to fetch product image.'
            });
        }
    }
};
