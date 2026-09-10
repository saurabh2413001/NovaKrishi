import { Router } from 'express';
import { productImageController } from '../controllers/productImageController.js';
import { authenticateUser, authorizeRole } from '../middleware/authMiddleware.js';

export const productImageRouter = Router();

// POST /api/product-images
// Farmers/Admins can upload marketplace product images.
productImageRouter.post(
  '/',
  authenticateUser,
  authorizeRole('farmer', 'admin'),
  productImageController.uploadImage
);

// GET /api/product-images/:id
// Public because marketplace buyers need to see product images.
productImageRouter.get('/:id', productImageController.getImage);

export default productImageRouter;
