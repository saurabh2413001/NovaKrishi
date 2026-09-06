import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import { userService } from './userService.js';
const JWT_SECRET = process.env.JWT_SECRET || 'NovaKrishiDefaultSecretKey2026';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';
export const authService = {
    async register(dto) {
        const contact = dto.email || dto.emailOrPhone;
        if (!dto.name || !contact || !dto.password || !dto.role) {
            return { success: false, message: 'Name, email/phone, password, and role are required.' };
        }
        if (dto.role === 'admin') {
            const expectedAdminKey = process.env.ADMIN_REGISTRATION_SECRET || 'NovaKrishiAdmin2026';
            if (dto.adminSecretKey !== expectedAdminKey) {
                return { success: false, message: 'Forbidden: Invalid Admin Secret Registration Key.' };
            }
        }
        const existingUser = await userService.findUserByEmailOrPhone(contact);
        if (existingUser) {
            return { success: false, message: 'An account with this email/mobile number already exists.' };
        }
        const passwordHash = await bcrypt.hash(dto.password, 10);
        const createdUser = await userService.createUser({ ...dto, password: passwordHash });
        const token = jwt.sign({
            userId: createdUser.id,
            id: createdUser.id,
            role: createdUser.role,
            email: createdUser.email
        }, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });
        return {
            success: true,
            token,
            user: createdUser
        };
    },
    async login(dto) {
        const contact = dto.email || dto.emailOrPhone;
        if (!contact || !dto.password) {
            return { success: false, message: 'Email/mobile and password are required.' };
        }
        const user = await userService.findUserByEmailOrPhone(contact);
        if (!user || !user.passwordHash) {
            return { success: false, message: 'Invalid credentials.' };
        }
        const isMatch = await bcrypt.compare(dto.password, user.passwordHash);
        if (!isMatch) {
            return { success: false, message: 'Invalid credentials.' };
        }
        const token = jwt.sign({
            userId: user._id.toString(),
            id: user._id.toString(),
            role: user.role,
            email: user.email
        }, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });
        return {
            success: true,
            token,
            user: userService.toUserResponse(user)
        };
    },
    async googleLogin(idToken) {
        try {
            const response = await fetch(`https://oauth2.googleapis.com/tokeninfo?id_token=${encodeURIComponent(idToken)}`);
            if (!response.ok) {
                return { success: false, message: 'Invalid Google ID token.' };
            }
            const googleUser = await response.json();
            const expectedAudience = process.env.GOOGLE_SERVER_CLIENT_ID;
            if (!expectedAudience) {
                console.error('GOOGLE_SERVER_CLIENT_ID is not configured.');
                return { success: false, message: 'Google login is not configured on the server.' };
            }
            if (!googleUser.aud || googleUser.aud !== expectedAudience) {
                return { success: false, message: 'Google token audience does not match this app.' };
            }
            const emailVerified = googleUser.email_verified === true || googleUser.email_verified === 'true';
            if (!googleUser.email || !emailVerified) {
                return { success: false, message: 'Google account email is not verified.' };
            }
            const email = googleUser.email.toLowerCase().trim();
            let user = await userService.findUserByEmailOrPhone(email);
            if (!user) {
                const created = await userService.createUser({
                    name: (googleUser.name || email.split('@')[0]).trim(),
                    email,
                    emailOrPhone: email,
                    role: 'farmer',
                    verificationStatus: 'VERIFIED',
                    profileImage: googleUser.picture || '',
                    state: 'Uttar Pradesh',
                    district: 'Gorakhpur'
                });
                const token = jwt.sign({
                    userId: created.id,
                    id: created.id,
                    role: created.role,
                    email: created.email
                }, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });
                return { success: true, token, user: created };
            }
            user.emailVerified = true;
            if (googleUser.name && !user.name)
                user.name = googleUser.name.trim();
            if (googleUser.picture)
                user.profileImage = googleUser.picture;
            if (!user.email)
                user.email = email;
            await user.save();
            const token = jwt.sign({
                userId: user._id.toString(),
                id: user._id.toString(),
                role: user.role,
                email: user.email
            }, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });
            return {
                success: true,
                token,
                user: userService.toUserResponse(user)
            };
        }
        catch (error) {
            console.error('Google login service error:', error);
            return { success: false, message: 'Unable to complete Google login.' };
        }
    },
    async getProfile(userId) {
        const user = await userService.findUserById(userId);
        if (!user) {
            return { success: false, message: 'User not found.' };
        }
        return {
            success: true,
            user: userService.toUserResponse(user)
        };
    }
};
