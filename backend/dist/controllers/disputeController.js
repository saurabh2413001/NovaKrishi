import * as disputeService from '../services/disputeService.js';
export const createDispute = async (req, res) => {
    try {
        const raisedBy = req.user.id;
        const { orderId, raisedAgainst, type, description, evidenceUrls } = req.body;
        if (!orderId || !raisedAgainst || !type || !description) {
            return res.status(400).json({ message: 'Missing required fields' });
        }
        const dispute = await disputeService.createDispute(orderId, raisedBy, raisedAgainst, type, description, evidenceUrls);
        res.status(201).json(dispute);
    }
    catch (error) {
        res.status(400).json({ message: error.message });
    }
};
export const getDisputes = async (req, res) => {
    try {
        const userId = req.user.id;
        const role = req.user.role;
        const disputes = await disputeService.getDisputes(userId, role);
        res.json(disputes);
    }
    catch (error) {
        res.status(500).json({ message: error.message });
    }
};
export const getDisputeById = async (req, res) => {
    try {
        const { id } = req.params;
        if (!id || typeof id !== 'string') {
            return res.status(400).json({ message: 'Dispute ID is required' });
        }
        const dispute = await disputeService.getDisputeById(id);
        if (!dispute) {
            return res.status(404).json({ message: 'Dispute not found' });
        }
        res.json(dispute);
    }
    catch (error) {
        res.status(500).json({ message: error.message });
    }
};
export const updateDisputeStatus = async (req, res) => {
    try {
        // Only admins should be able to reach this if we use roleMiddleware
        const { id } = req.params;
        if (!id || typeof id !== 'string') {
            return res.status(400).json({ message: 'Dispute ID is required' });
        }
        const { status, resolution, note } = req.body;
        const dispute = await disputeService.updateDisputeStatus(id, status, resolution, note);
        res.json(dispute);
    }
    catch (error) {
        res.status(400).json({ message: error.message });
    }
};
