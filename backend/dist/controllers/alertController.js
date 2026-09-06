import { alertService } from '../services/alertService.js';
export const alertController = {
    async getAlerts(req, res) {
        try {
            const state = req.query.state;
            const district = req.query.district;
            const crop = req.query.crop;
            const alerts = await alertService.getRelevantAlerts(state, district, crop);
            return res.status(200).json({
                success: true,
                count: alerts.length,
                alerts
            });
        }
        catch (err) {
            console.error('Error fetching community alerts:', err);
            return res.status(500).json({ success: false, message: 'Server error fetching alerts' });
        }
    }
};
