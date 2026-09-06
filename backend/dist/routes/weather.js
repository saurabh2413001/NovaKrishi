import { Router } from 'express';
import { INITIAL_WEATHER } from '../data/seedData.js';
const router = Router();
router.get('/', (_req, res) => {
    res.json({
        success: true,
        data: INITIAL_WEATHER
    });
});
export default router;
