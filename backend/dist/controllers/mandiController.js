import { mandiService } from '../services/mandiService.js';
export const mandiController = {
    async getPrices(req, res) {
        try {
            const query = {
                state: req.query.state,
                district: req.query.district,
                mandi: req.query.mandi,
                commodity: req.query.commodity,
                category: req.query.category,
                search: req.query.search,
                page: req.query.page ? parseInt(req.query.page, 10) : 1,
                limit: req.query.limit ? parseInt(req.query.limit, 10) : 25
            };
            const result = await mandiService.getMandiPrices(query);
            return res.status(200).json(result);
        }
        catch (error) {
            console.error('Error fetching mandi prices:', error);
            return res.status(500).json({
                success: false,
                message: 'Unable to fetch current mandi prices. Please try again.'
            });
        }
    },
    getDistricts(req, res) {
        try {
            const state = req.query.state;
            const districts = mandiService.getDistricts(state);
            return res.status(200).json({
                success: true,
                districts
            });
        }
        catch (error) {
            return res.status(500).json({
                success: false,
                message: 'Unable to fetch districts.'
            });
        }
    }
};
