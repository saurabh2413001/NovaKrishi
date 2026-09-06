import { Router } from 'express';
const router = Router();
router.get('/', (_req, res) => {
    res.json({
        success: true,
        message: "NovaKrishi AI Disease Scanner Endpoint active"
    });
});
export default router;
