import mongoose, { Schema } from 'mongoose';
const OtpSchema = new Schema({
    identifier: {
        type: String,
        required: true,
        trim: true,
        lowercase: true,
        index: true
    },
    otpHash: {
        type: String,
        required: true
    },
    expiresAt: {
        type: Date,
        required: true,
        index: { expires: 0 } // TTL index automatically removes document when expiresAt is reached
    },
    attempts: {
        type: Number,
        default: 0
    },
    verified: {
        type: Boolean,
        default: false
    }
}, {
    timestamps: true
});
export const Otp = mongoose.model('Otp', OtpSchema);
