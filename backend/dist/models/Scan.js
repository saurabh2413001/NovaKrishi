import mongoose, { Schema } from 'mongoose';
const ScanSchema = new Schema({
    userId: {
        type: Schema.Types.ObjectId,
        ref: 'User',
        required: true,
        index: true
    },
    cropName: {
        type: String,
        required: true,
        trim: true
    },
    diseaseName: {
        type: String,
        required: true,
        trim: true
    },
    diseaseHindi: {
        type: String,
        trim: true,
        default: ''
    },
    confidence: {
        type: Number,
        default: 0
    },
    imageUrl: {
        type: String,
        default: ''
    },
    severity: {
        type: String,
        enum: ['Low', 'Medium', 'High', 'Critical'],
        default: 'Medium'
    },
    symptoms: {
        type: [String],
        default: []
    },
    precautions: {
        type: [String],
        default: []
    },
    treatment: {
        type: [String],
        default: []
    },
    location: {
        village: { type: String, default: '' },
        district: { type: String, default: '' },
        state: { type: String, default: '' },
        latitude: { type: Number },
        longitude: { type: Number }
    }
}, {
    timestamps: true
});
export const Scan = mongoose.model('Scan', ScanSchema);
