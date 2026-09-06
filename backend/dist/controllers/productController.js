import { productService } from '../services/productService.js';
import { farmerMatchingService } from '../services/farmerMatchingService.js';
export const productController = {
    // GET /api/products/matches
    async getMatchingFarmers(req, res) {
        try {
            if (!req.user) {
                return res.status(401).json({ success: false, message: 'Authentication required.' });
            }
            const { category, quantity, qualityPreference } = req.query;
            const buyerDistrict = req.user.deliveryAddress?.city || req.user.district;
            const buyerState = req.user.deliveryAddress?.state || req.user.state;
            const matches = await farmerMatchingService.findMatchingFarmers({
                productCategory: category,
                quantity: quantity ? Number(quantity) : undefined,
                qualityPreference: qualityPreference,
                buyerDistrict: req.query.district || buyerDistrict,
                buyerState: req.query.state || buyerState
            });
            return res.status(200).json({
                success: true,
                matches
            });
        }
        catch (error) {
            console.error('Error fetching matching farmers:', error);
            return res.status(500).json({
                success: false,
                message: 'Unable to fetch smart matches. Please try again.'
            });
        }
    },
    // GET /api/products
    async getProducts(req, res) {
        try {
            const filter = {
                category: req.query.category,
                search: req.query.search,
                minPrice: req.query.minPrice ? Number(req.query.minPrice) : undefined,
                maxPrice: req.query.maxPrice ? Number(req.query.maxPrice) : undefined,
                state: req.query.state,
                district: req.query.district,
                organicOnly: req.query.organicOnly === 'true',
                verifiedOnly: req.query.verifiedOnly === 'true',
                sort: req.query.sort,
                page: req.query.page ? parseInt(req.query.page, 10) : 1,
                limit: req.query.limit ? parseInt(req.query.limit, 10) : 12
            };
            const result = await productService.getProducts(filter);
            return res.status(200).json(result);
        }
        catch (error) {
            console.error('Error fetching marketplace products:', error);
            return res.status(500).json({
                success: false,
                message: 'Unable to fetch produce listings. Please try again.'
            });
        }
    },
    // GET /api/products/my-products (Authenticated Farmer)
    async getMyProducts(req, res) {
        try {
            if (!req.user) {
                return res.status(401).json({ success: false, message: 'Authentication required.' });
            }
            const products = await productService.getMyProducts(req.user.id);
            return res.status(200).json({
                success: true,
                total: products.length,
                products
            });
        }
        catch (error) {
            return res.status(500).json({
                success: false,
                message: 'Unable to fetch your product listings.'
            });
        }
    },
    // GET /api/products/:id
    async getProductById(req, res) {
        try {
            const productId = req.params.id;
            const product = await productService.getProductById(productId);
            if (!product) {
                return res.status(404).json({
                    success: false,
                    message: 'Product not found.'
                });
            }
            return res.status(200).json({
                success: true,
                product
            });
        }
        catch (error) {
            return res.status(500).json({
                success: false,
                message: 'Unable to fetch product details.'
            });
        }
    },
    // POST /api/products (Farmer/Admin Only)
    async createProduct(req, res) {
        try {
            if (!req.user) {
                return res.status(401).json({ success: false, message: 'Authentication required.' });
            }
            const { title, category, price, unit, availableQuantity } = req.body;
            if (!title || !category || !price || !availableQuantity) {
                return res.status(400).json({
                    success: false,
                    message: 'Product title, category, price, and available quantity are required.'
                });
            }
            const product = await productService.createProduct(req.body, req.user);
            return res.status(201).json({
                success: true,
                message: 'Produce listing published to Marketplace successfully.',
                product
            });
        }
        catch (error) {
            console.error('Error creating product:', error);
            return res.status(500).json({
                success: false,
                message: 'An error occurred while creating product listing.'
            });
        }
    },
    // PUT /api/products/:id (Ownership Check)
    async updateProduct(req, res) {
        try {
            if (!req.user) {
                return res.status(401).json({ success: false, message: 'Authentication required.' });
            }
            const productId = req.params.id;
            const result = await productService.updateProduct(productId, req.body, req.user.id, req.user.role);
            if (!result.success) {
                const statusCode = result.message?.includes('Forbidden') ? 403 : 400;
                return res.status(statusCode).json(result);
            }
            return res.status(200).json(result);
        }
        catch (error) {
            console.error('Error updating product:', error);
            return res.status(500).json({
                success: false,
                message: 'An error occurred while updating product listing.'
            });
        }
    },
    // DELETE /api/products/:id (Ownership Check)
    async deleteProduct(req, res) {
        try {
            if (!req.user) {
                return res.status(401).json({ success: false, message: 'Authentication required.' });
            }
            const productId = req.params.id;
            const result = await productService.deleteProduct(productId, req.user.id, req.user.role);
            if (!result.success) {
                const statusCode = result.message?.includes('Forbidden') ? 403 : 400;
                return res.status(statusCode).json(result);
            }
            return res.status(200).json(result);
        }
        catch (error) {
            return res.status(500).json({
                success: false,
                message: 'An error occurred while deleting product listing.'
            });
        }
    }
};
