import { deliveryService } from '../services/deliveryService.js';
export const deliveryController = {
    // POST /api/delivery
    async createDelivery(req, res) {
        try {
            const { orderId } = req.body;
            if (!orderId) {
                return res.status(400).json({ success: false, message: 'orderId is required.' });
            }
            const delivery = await deliveryService.createDelivery(req.body);
            return res.status(201).json({
                success: true,
                message: 'Delivery dispatch record created successfully.',
                delivery
            });
        }
        catch (error) {
            console.error('Error in createDelivery controller:', error);
            return res.status(500).json({ success: false, message: error.message || 'Unable to create delivery dispatch.' });
        }
    },
    // GET /api/delivery/:id
    async getDeliveryById(req, res) {
        try {
            const deliveryId = req.params.id;
            const delivery = await deliveryService.getDeliveryById(deliveryId);
            if (!delivery) {
                return res.status(404).json({ success: false, message: 'Delivery record not found.' });
            }
            return res.status(200).json({ success: true, delivery });
        }
        catch (error) {
            return res.status(500).json({ success: false, message: 'Unable to fetch delivery details.' });
        }
    },
    // GET /api/orders/:orderId/tracking
    async getOrderTracking(req, res) {
        try {
            const orderId = req.params.orderId;
            const tracking = await deliveryService.getOrderTracking(orderId);
            return res.status(200).json({ success: true, tracking });
        }
        catch (error) {
            console.error('Error in getOrderTracking controller:', error);
            return res.status(500).json({ success: false, message: error.message || 'Unable to fetch order tracking.' });
        }
    },
    // POST /api/delivery/location
    async updateLocation(req, res) {
        try {
            const { lat, lng } = req.body;
            if (lat === undefined || lng === undefined) {
                return res.status(400).json({ success: false, message: 'lat and lng are required.' });
            }
            const updated = await deliveryService.updateLocation(req.body);
            return res.status(200).json({
                success: true,
                message: 'Vehicle location snapshot updated.',
                delivery: updated
            });
        }
        catch (error) {
            return res.status(500).json({ success: false, message: error.message || 'Unable to update location.' });
        }
    }
};
