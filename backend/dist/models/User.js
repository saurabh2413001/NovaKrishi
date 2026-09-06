import mongoose, { Schema } from 'mongoose';
const UserSchema = new Schema({
    name: {
        type: String,
        required: true,
        trim: true
    },
    email: {
        type: String,
        trim: true,
        lowercase: true
    },
    phone: {
        type: String,
        trim: true
    },
    emailOrPhone: {
        type: String,
        required: true,
        unique: true,
        trim: true,
        lowercase: true,
        index: true
    },
    passwordHash: {
        type: String
    },
    role: {
        type: String,
        enum: ['farmer', 'consumer', 'bulk_buyer', 'delivery_partner', 'admin'],
        default: 'farmer',
        required: true,
        index: true
    },
    phoneVerified: {
        type: Boolean,
        default: false
    },
    emailVerified: {
        type: Boolean,
        default: false
    },
    verificationStatus: {
        type: String,
        enum: ['PENDING', 'VERIFIED', 'REJECTED'],
        default: 'VERIFIED',
        required: true,
        index: true
    },
    state: {
        type: String,
        default: 'Uttar Pradesh'
    },
    district: {
        type: String,
        default: 'Gorakhpur'
    },
    village: {
        type: String,
        default: ''
    },
    primaryCrop: {
        type: String,
        default: ''
    },
    profileImage: {
        type: String,
        default: ''
    },
    farmInfo: {
        fpoName: { type: String, default: '' },
        fpoRegistrationNumber: { type: String, default: '' },
        landSizeAcres: { type: Number, default: 0 },
        primaryCrop: { type: String, default: '' },
        organicCertified: { type: Boolean, default: false }
    },
    deliveryAddress: {
        streetAddress: { type: String, default: '' },
        city: { type: String, default: '' },
        state: { type: String, default: '' },
        pincode: { type: String, default: '' },
        landmark: { type: String, default: '' }
    },
    businessInfo: {
        organizationName: { type: String, default: '' },
        gstin: { type: String, default: '' },
        businessType: { type: String, default: 'Wholesaler' },
        annualVolumeEstimate: { type: String, default: '' }
    },
    vehicleInfo: {
        vehicleType: { type: String, default: 'MiniTruck' },
        vehicleNumber: { type: String, default: '' },
        licenseNumber: { type: String, default: '' },
        operatingDistrict: { type: String, default: '' },
        maxCapacityKg: { type: Number, default: 1000 }
    },
    reliability: {
        score: { type: Number, default: 70 },
        totalOrders: { type: Number, default: 0 },
        completedOrders: { type: Number, default: 0 },
        disputesRaisedAgainst: { type: Number, default: 0 },
        disputesResolved: { type: Number, default: 0 },
        avgPaymentDelayDays: { type: Number, default: 0 },
        badge: { type: String, enum: ['trusted', 'good', 'new', 'flagged'], default: 'new' }
    }
}, {
    timestamps: true
});
export const User = mongoose.model('User', UserSchema);
export function toUserResponse(user) {
    return {
        id: user._id.toString(),
        name: user.name,
        email: user.email || undefined,
        phone: user.phone || undefined,
        emailOrPhone: user.emailOrPhone,
        role: user.role,
        phoneVerified: !!user.phoneVerified,
        emailVerified: !!user.emailVerified,
        verificationStatus: user.verificationStatus || 'VERIFIED',
        state: user.state,
        district: user.district,
        village: user.village || undefined,
        primaryCrop: user.primaryCrop || undefined,
        profileImage: user.profileImage || undefined,
        farmInfo: user.farmInfo,
        deliveryAddress: user.deliveryAddress,
        businessInfo: user.businessInfo,
        vehicleInfo: user.vehicleInfo,
        reliability: user.reliability,
        createdAt: user.createdAt ? user.createdAt.toISOString() : new Date().toISOString()
    };
}
