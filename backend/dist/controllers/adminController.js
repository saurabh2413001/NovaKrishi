import { adminService } from '../services/adminService.js';
export const adminController = {
    // GET /api/admin/metrics
    async getMetrics(req, res) {
        try {
            const metrics = await adminService.getMetrics();
            return res.status(200).json({ success: true, metrics });
        }
        catch (error) {
            console.error('Error in admin getMetrics:', error);
            return res.status(500).json({ success: false, message: 'Unable to fetch admin metrics.' });
        }
    },
    // GET /api/admin/farmers
    async getFarmers(req, res) {
        try {
            const farmers = await adminService.getFarmers();
            return res.status(200).json({ success: true, total: farmers.length, farmers });
        }
        catch (error) {
            return res.status(500).json({ success: false, message: 'Unable to fetch farmers list.' });
        }
    },
    // PUT /api/admin/farmers/:id/verify
    async verifyFarmer(req, res) {
        try {
            const farmerId = req.params.id;
            const { status } = req.body;
            if (!status || !['PENDING', 'VERIFIED', 'REJECTED'].includes(status)) {
                return res.status(400).json({ success: false, message: 'Status must be PENDING, VERIFIED, or REJECTED.' });
            }
            const farmer = await adminService.verifyFarmer(farmerId, status);
            return res.status(200).json({
                success: true,
                message: `Farmer status updated to ${status}.`,
                farmer
            });
        }
        catch (error) {
            return res.status(500).json({ success: false, message: error.message || 'Unable to update farmer status.' });
        }
    }
};
