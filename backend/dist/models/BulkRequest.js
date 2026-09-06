import mongoose, { Schema } from 'mongoose';
const FarmerOfferSchema = new Schema({
    requestId: { type: Schema.Types.ObjectId, ref: 'BulkRequest', required: true, index: true },
    farmerId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    farmerName: { type: String, required: true },
    fpoName: { type: String, default: '' },
    farmerDistrict: { type: String, default: 'Gorakhpur' },
    farmerState: { type: String, default: 'Uttar Pradesh' },
    offeredQuantity: { type: Number, required: true },
    offeredPricePerUnit: { type: Number, required: true },
    totalOfferAmount: { type: Number, required: true },
    logisticsIncluded: { type: Boolean, default: true },
    notes: { type: String, default: '' },
    status: { type: String, enum: ['PENDING', 'ACCEPTED', 'REJECTED'], default: 'PENDING' }
}, { timestamps: true });
const BulkRequestSchema = new Schema({
    requestNumber: { type: String, required: true, unique: true },
    buyerId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    buyerName: { type: String, required: true },
    organizationName: { type: String, default: 'Bulk Procurement Corp' },
    buyerPhone: { type: String, default: '+91 98765 00000' },
    productTitle: { type: String, required: true },
    category: { type: String, default: 'Vegetables' },
    targetQuantity: { type: Number, required: true },
    unit: { type: String, default: 'kg' },
    deliveryCity: { type: String, required: true },
    deliveryState: { type: String, required: true },
    requiredByDate: { type: Date, required: true },
    targetPricePerUnit: { type: Number },
    status: {
        type: String,
        enum: ['OPEN', 'QUOTES_RECEIVED', 'ACCEPTED', 'FULFILLED', 'CANCELLED'],
        default: 'OPEN',
        index: true
    },
    matchingFarmers: [
        {
            farmerId: { type: Schema.Types.ObjectId, ref: 'User' },
            farmerName: String,
            fpoName: String,
            district: String,
            availableQty: Number
        }
    ],
    offers: [FarmerOfferSchema],
    acceptedOfferId: { type: Schema.Types.ObjectId },
    orderId: { type: Schema.Types.ObjectId, ref: 'Order' }
}, { timestamps: true });
export const BulkRequest = mongoose.model('BulkRequest', BulkRequestSchema);
