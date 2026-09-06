import * as reviewService from '../services/reviewService.js';
export const createReview = async (req, res) => {
    try {
        const reviewerId = req.user.id;
        const { orderId, revieweeId, rating, comment, tags } = req.body;
        const reviewerRole = req.user.role;
        if (!orderId || !revieweeId || !rating) {
            return res.status(400).json({ message: 'orderId, revieweeId, and rating are required' });
        }
        const review = await reviewService.createReview(orderId, reviewerId, revieweeId, reviewerRole, rating, comment, tags);
        res.status(201).json(review);
    }
    catch (error) {
        if (error.code === 11000) {
            // Mongoose duplicate key error
            return res.status(400).json({ message: 'You have already reviewed this order' });
        }
        res.status(400).json({ message: error.message });
    }
};
export const getUserReviews = async (req, res) => {
    try {
        const { userId } = req.params;
        if (!userId || typeof userId !== 'string') {
            return res.status(400).json({ message: 'User ID is required' });
        }
        const data = await reviewService.getUserReviews(userId);
        res.json(data);
    }
    catch (error) {
        res.status(500).json({ message: error.message });
    }
};
export const getOrderReviews = async (req, res) => {
    try {
        const { orderId } = req.params;
        if (!orderId || typeof orderId !== 'string') {
            return res.status(400).json({ message: 'Order ID is required' });
        }
        const reviews = await reviewService.getOrderReviews(orderId);
        res.json(reviews);
    }
    catch (error) {
        res.status(500).json({ message: error.message });
    }
};
