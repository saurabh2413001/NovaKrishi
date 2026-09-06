import jwt from 'jsonwebtoken';
import { authService } from '../services/authService.js';
const JWT_SECRET = process.env.JWT_SECRET || 'NovaKrishiDefaultSecretKey2026';
export const authenticateUser = async (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({
                success: false,
                message: 'Authentication token required.'
            });
        }
        const token = authHeader.split(' ')[1];
        const decoded = jwt.verify(token, JWT_SECRET);
        if (!decoded || (!decoded.userId && !decoded.id)) {
            return res.status(401).json({
                success: false,
                message: 'Invalid or expired authentication token.'
            });
        }
        const userId = decoded.userId || decoded.id;
        const authResult = await authService.getProfile(userId);
        if (!authResult.success || !authResult.user) {
            return res.status(401).json({
                success: false,
                message: 'User account not found.'
            });
        }
        req.user = authResult.user;
        next();
    }
    catch (err) {
        return res.status(401).json({
            success: false,
            message: 'Unauthorized access.'
        });
    }
};
export const requireAuth = authenticateUser;
export const authorizeRole = (...roles) => {
    return (req, res, next) => {
        if (!req.user) {
            return res.status(401).json({
                success: false,
                message: 'Authentication required.'
            });
        }
        if (!roles.includes(req.user.role)) {
            return res.status(403).json({
                success: false,
                message: `Forbidden: Access restricted to ${roles.join(', ')} role(s). Your role is ${req.user.role}.`
            });
        }
        next();
    };
};
