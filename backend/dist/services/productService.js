import mongoose from 'mongoose';
import { Product, } from '../models/Product.js';
export const productService = {
    // Normalize category names coming from Flutter/API.
    // Example: "grains", "Grains", "GRAINS" -> "Grains"
    normalizeCategory(category) {
        const normalized = category.trim().toLowerCase();
        const categories = {
            vegetables: 'Vegetables',
            fruits: 'Fruits',
            grains: 'Grains',
            pulses: 'Pulses',
            spices: 'Spices',
            dairy: 'Dairy',
            'organic products': 'Organic Products',
            seeds: 'Seeds',
            fertilizers: 'Fertilizers',
            'farm equipment': 'Farm Equipment',
        };
        return categories[normalized] ?? 'Grains';
    },
    // Convert Mongoose Doc to Clean API Response
    toProductResponse(doc) {
        return {
            id: doc._id.toString(),
            title: doc.title,
            category: doc.category,
            price: doc.price,
            unit: doc.unit,
            mandiBenchmarkPrice: doc.mandiBenchmarkPrice || 0,
            availableQuantity: doc.availableQuantity,
            minOrderQuantity: doc.minOrderQuantity || 1,
            description: doc.description || '',
            imageUrl: doc.imageUrl,
            farmerId: doc.farmerId ? doc.farmerId.toString() : '',
            farmerName: doc.farmerName,
            fpoName: doc.fpoName || '',
            isVerifiedFPO: !!doc.isVerifiedFPO,
            isOrganicCertified: !!doc.isOrganicCertified,
            location: {
                village: doc.location?.village || '',
                district: doc.location?.district || 'Gorakhpur',
                state: doc.location?.state || 'Uttar Pradesh',
            },
            rating: doc.rating || 4.8,
            reviewCount: doc.reviewCount || 12,
            harvestDate: doc.harvestDate
                ? new Date(doc.harvestDate).toISOString()
                : new Date().toISOString(),
            status: doc.status || 'available',
            createdAt: doc.createdAt
                ? new Date(doc.createdAt).toISOString()
                : new Date().toISOString(),
        };
    },
    // 1. Get All Filtered Marketplace Products
    async getProducts(filter) {
        await this.seedInitialProducts();
        const query = {
            status: { $ne: 'unlisted' },
        };
        if (filter.category && filter.category !== 'All') {
            query.category = this.normalizeCategory(filter.category);
        }
        if (filter.search) {
            const q = filter.search.trim();
            query.$or = [
                { title: { $regex: q, $options: 'i' } },
                { farmerName: { $regex: q, $options: 'i' } },
                { fpoName: { $regex: q, $options: 'i' } },
                { 'location.district': { $regex: q, $options: 'i' } },
                { 'location.state': { $regex: q, $options: 'i' } },
            ];
        }
        if (filter.minPrice !== undefined ||
            filter.maxPrice !== undefined) {
            query.price = {};
            if (filter.minPrice !== undefined) {
                query.price.$gte = Number(filter.minPrice);
            }
            if (filter.maxPrice !== undefined) {
                query.price.$lte = Number(filter.maxPrice);
            }
        }
        if (filter.state && filter.state !== 'All') {
            query['location.state'] = filter.state;
        }
        if (filter.district && filter.district !== 'All') {
            query['location.district'] = filter.district;
        }
        if (filter.organicOnly) {
            query.isOrganicCertified = true;
        }
        if (filter.verifiedOnly) {
            query.isVerifiedFPO = true;
        }
        // Sorting
        let sortOptions = {
            createdAt: -1,
        };
        if (filter.sort === 'price_asc') {
            sortOptions = { price: 1 };
        }
        if (filter.sort === 'price_desc') {
            sortOptions = { price: -1 };
        }
        if (filter.sort === 'rating') {
            sortOptions = { rating: -1 };
        }
        if (filter.sort === 'stock') {
            sortOptions = { availableQuantity: -1 };
        }
        const page = filter.page && filter.page > 0
            ? Number(filter.page)
            : 1;
        const limit = filter.limit && filter.limit > 0
            ? Number(filter.limit)
            : 12;
        const skip = (page - 1) * limit;
        const [total, docs] = await Promise.all([
            Product.countDocuments(query),
            Product.find(query)
                .sort(sortOptions)
                .skip(skip)
                .limit(limit),
        ]);
        const totalPages = Math.ceil(total / limit) || 1;
        return {
            success: true,
            total,
            page,
            limit,
            totalPages,
            products: docs.map((d) => this.toProductResponse(d)),
        };
    },
    // 2. Get Single Product By ID
    async getProductById(id) {
        if (!mongoose.Types.ObjectId.isValid(id)) {
            return null;
        }
        const doc = await Product.findById(id);
        if (!doc) {
            return null;
        }
        return this.toProductResponse(doc);
    },
    // 3. Get Products Belonging to Authenticated Farmer
    async getMyProducts(farmerId) {
        if (!mongoose.Types.ObjectId.isValid(farmerId)) {
            return [];
        }
        const docs = await Product.find({
            farmerId: new mongoose.Types.ObjectId(farmerId),
        }).sort({
            createdAt: -1,
        });
        return docs.map((d) => this.toProductResponse(d));
    },
    // 4. Create New Product Listing
    // Farmer Authorization Required
    async createProduct(dto, farmerUser) {
        const normalizedCategory = this.normalizeCategory(dto.category);
        const newDoc = new Product({
            title: dto.title.trim(),
            // IMPORTANT:
            // Converts "grains" -> "Grains"
            category: normalizedCategory,
            price: dto.price,
            unit: dto.unit || 'kg',
            mandiBenchmarkPrice: dto.mandiBenchmarkPrice ||
                Math.round(dto.price * 0.85),
            availableQuantity: dto.availableQuantity,
            minOrderQuantity: dto.minOrderQuantity || 1,
            description: dto.description || '',
            imageUrl: dto.imageUrl ||
                'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?auto=format&fit=crop&w=500&q=80',
            farmerId: new mongoose.Types.ObjectId(farmerUser.id),
            farmerName: farmerUser.name,
            fpoName: dto.fpoName ||
                farmerUser.farmInfo?.fpoName ||
                '',
            isVerifiedFPO: dto.isVerifiedFPO !== undefined
                ? dto.isVerifiedFPO
                : !!farmerUser.farmInfo?.fpoName,
            isOrganicCertified: dto.isOrganicCertified !== undefined
                ? dto.isOrganicCertified
                : !!farmerUser.farmInfo?.organicCertified,
            location: {
                village: dto.village ||
                    farmerUser.village ||
                    '',
                district: dto.district ||
                    farmerUser.district ||
                    'Gorakhpur',
                state: dto.state ||
                    farmerUser.state ||
                    'Uttar Pradesh',
            },
            rating: 4.9,
            reviewCount: 1,
            harvestDate: dto.harvestDate
                ? new Date(dto.harvestDate)
                : new Date(),
            status: dto.availableQuantity > 0
                ? 'available'
                : 'sold_out',
        });
        const saved = await newDoc.save();
        return this.toProductResponse(saved);
    },
    // 5. Update Product
    // Strict Ownership Authorization
    async updateProduct(productId, dto, userId, userRole) {
        if (!mongoose.Types.ObjectId.isValid(productId)) {
            return {
                success: false,
                message: 'Invalid product ID',
            };
        }
        const doc = await Product.findById(productId);
        if (!doc) {
            return {
                success: false,
                message: 'Product not found',
            };
        }
        // Only product owner or admin can edit
        if (doc.farmerId.toString() !== userId &&
            userRole !== 'admin') {
            return {
                success: false,
                message: 'Forbidden: You are not authorized to modify another farmer’s produce.',
            };
        }
        if (dto.title !== undefined) {
            doc.title = dto.title.trim();
        }
        if (dto.category !== undefined) {
            doc.category =
                this.normalizeCategory(dto.category);
        }
        if (dto.price !== undefined) {
            doc.price = dto.price;
        }
        if (dto.unit !== undefined) {
            doc.unit = dto.unit;
        }
        if (dto.mandiBenchmarkPrice !== undefined) {
            doc.mandiBenchmarkPrice =
                dto.mandiBenchmarkPrice;
        }
        if (dto.availableQuantity !== undefined) {
            doc.availableQuantity =
                dto.availableQuantity;
            doc.status =
                dto.availableQuantity > 0
                    ? 'available'
                    : 'sold_out';
        }
        if (dto.minOrderQuantity !== undefined) {
            doc.minOrderQuantity =
                dto.minOrderQuantity;
        }
        if (dto.description !== undefined) {
            doc.description = dto.description;
        }
        if (dto.imageUrl !== undefined) {
            doc.imageUrl = dto.imageUrl;
        }
        if (dto.isOrganicCertified !== undefined) {
            doc.isOrganicCertified =
                dto.isOrganicCertified;
        }
        if (dto.isVerifiedFPO !== undefined) {
            doc.isVerifiedFPO =
                dto.isVerifiedFPO;
        }
        if (dto.status !== undefined) {
            doc.status = dto.status;
        }
        const updated = await doc.save();
        return {
            success: true,
            product: this.toProductResponse(updated),
        };
    },
    // 6. Delete Product
    // Strict Ownership Authorization
    async deleteProduct(productId, userId, userRole) {
        if (!mongoose.Types.ObjectId.isValid(productId)) {
            return {
                success: false,
                message: 'Invalid product ID',
            };
        }
        const doc = await Product.findById(productId);
        if (!doc) {
            return {
                success: false,
                message: 'Product not found',
            };
        }
        // Only product owner or admin can delete
        if (doc.farmerId.toString() !== userId &&
            userRole !== 'admin') {
            return {
                success: false,
                message: 'Forbidden: You are not authorized to delete another farmer’s produce.',
            };
        }
        await Product.findByIdAndDelete(productId);
        return {
            success: true,
            message: 'Product deleted successfully.',
        };
    },
    // 7. Seed Initial Produce Dataset
    // into MongoDB if Empty
    async seedInitialProducts() {
        try {
            const count = await Product.countDocuments();
            if (count > 0) {
                return;
            }
            console.log('🌱 Seeding initial dynamic Agricultural Marketplace produce items...');
            const dummyFarmerId = new mongoose.Types.ObjectId();
            const seedItems = [
                {
                    title: 'Fresh Grade-A Red Tomatoes',
                    category: 'Vegetables',
                    price: 32,
                    unit: 'kg',
                    mandiBenchmarkPrice: 26,
                    availableQuantity: 1500,
                    minOrderQuantity: 50,
                    description: 'Farm-fresh, pesticide-free red tomatoes harvested directly from Nashik beds.',
                    imageUrl: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=500&q=80',
                    farmerId: dummyFarmerId,
                    farmerName: 'Rameshwar Singh',
                    fpoName: 'Green Valley FPO',
                    isVerifiedFPO: true,
                    isOrganicCertified: true,
                    location: {
                        village: 'Pimpalgaon',
                        district: 'Nashik',
                        state: 'Maharashtra',
                    },
                    rating: 4.9,
                    reviewCount: 28,
                    status: 'available',
                },
                {
                    title: 'Organic Sharbati Premium Wheat',
                    category: 'Grains',
                    price: 2450,
                    unit: 'Quintal',
                    mandiBenchmarkPrice: 2100,
                    availableQuantity: 250,
                    minOrderQuantity: 10,
                    description: 'Golden Sharbati wheat grains grown naturally without synthetic chemical fertilizers.',
                    imageUrl: 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?auto=format&fit=crop&w=500&q=80',
                    farmerId: dummyFarmerId,
                    farmerName: 'Gorakhpur Kisan FPO',
                    fpoName: 'Gorakhpur Farmers Producer Co.',
                    isVerifiedFPO: true,
                    isOrganicCertified: true,
                    location: {
                        village: 'Kheri Sadh',
                        district: 'Gorakhpur',
                        state: 'Uttar Pradesh',
                    },
                    rating: 4.8,
                    reviewCount: 42,
                    status: 'available',
                },
                {
                    title: 'Desi Chana (Whole Chickpeas)',
                    category: 'Pulses',
                    price: 5800,
                    unit: 'Quintal',
                    mandiBenchmarkPrice: 5100,
                    availableQuantity: 120,
                    minOrderQuantity: 5,
                    description: 'High-protein organic desi chana harvested in Malwa region.',
                    imageUrl: 'https://images.unsplash.com/photo-1515543904379-3d757afe72e4?auto=format&fit=crop&w=500&q=80',
                    farmerId: dummyFarmerId,
                    farmerName: 'Suresh Malviya',
                    fpoName: 'Malwa Organic FPO',
                    isVerifiedFPO: true,
                    isOrganicCertified: true,
                    location: {
                        village: 'Sanwer',
                        district: 'Indore',
                        state: 'Madhya Pradesh',
                    },
                    rating: 4.7,
                    reviewCount: 19,
                    status: 'available',
                },
                {
                    title: 'Alphonso Mangoes (Ratnagiri Fresh)',
                    category: 'Fruits',
                    price: 650,
                    unit: 'Dozen',
                    mandiBenchmarkPrice: 550,
                    availableQuantity: 80,
                    minOrderQuantity: 2,
                    description: 'Authentic GI-tagged Ratnagiri Alphonso mangoes, naturally ripened.',
                    imageUrl: 'https://images.unsplash.com/photo-1553279768-865429fa0078?auto=format&fit=crop&w=500&q=80',
                    farmerId: dummyFarmerId,
                    farmerName: 'Konkan Fruit Producers FPO',
                    fpoName: 'Konkan Mango Producer Co.',
                    isVerifiedFPO: true,
                    isOrganicCertified: true,
                    location: {
                        village: 'Devgad',
                        district: 'Ratnagiri',
                        state: 'Maharashtra',
                    },
                    rating: 5.0,
                    reviewCount: 64,
                    status: 'available',
                },
                {
                    title: 'Pure Desi Cow Ghee (A2 Bilona)',
                    category: 'Dairy',
                    price: 1200,
                    unit: 'Liter',
                    mandiBenchmarkPrice: 950,
                    availableQuantity: 50,
                    minOrderQuantity: 1,
                    description: 'Traditional Vedic Bilona method Ghee prepared from free-grazing Gir Cows.',
                    imageUrl: 'https://images.unsplash.com/photo-1628088062854-d1870b4553da?auto=format&fit=crop&w=500&q=80',
                    farmerId: dummyFarmerId,
                    farmerName: 'Vedic Gaushala Dairy',
                    fpoName: 'Gir Krishi Gaushala',
                    isVerifiedFPO: true,
                    isOrganicCertified: true,
                    location: {
                        village: 'Vrindavan',
                        district: 'Mathura',
                        state: 'Uttar Pradesh',
                    },
                    rating: 4.9,
                    reviewCount: 35,
                    status: 'available',
                },
                {
                    title: 'Organic Certified Black Pepper (Kali Mirch)',
                    category: 'Spices',
                    price: 620,
                    unit: 'kg',
                    mandiBenchmarkPrice: 540,
                    availableQuantity: 300,
                    minOrderQuantity: 5,
                    description: 'Sun-dried aromatic Malabar black pepper direct from Wayanad spices estate.',
                    imageUrl: 'https://images.unsplash.com/photo-1599940824399-b87987ceb72a?auto=format&fit=crop&w=500&q=80',
                    farmerId: dummyFarmerId,
                    farmerName: 'Wayanad Spice Growers',
                    fpoName: 'Kerala Organic Spices FPO',
                    isVerifiedFPO: true,
                    isOrganicCertified: true,
                    location: {
                        village: 'Mananthavady',
                        district: 'Wayanad',
                        state: 'Kerala',
                    },
                    rating: 4.9,
                    reviewCount: 51,
                    status: 'available',
                },
            ];
            await Product.insertMany(seedItems);
            console.log('✅ Marketplace initial items seeded successfully into MongoDB.');
        }
        catch (err) {
            console.error('Error seeding initial products:', err);
        }
    },
};
