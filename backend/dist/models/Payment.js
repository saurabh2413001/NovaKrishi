import mongoose, { Schema } from 'mongoose';
const EscrowTimelineEntrySchema = new Schema({
    status: { type: String, required: true },
    timestamp: { type: Date, default: Date.now },
    note: { type: String, default: '' },
    triggeredBy: { type: String, default: 'system' }
});
const PaymentSchema = new Schema({
    transactionId: {
        type: String,
        required: true,
        unique: true,
        index: true
    },
    orderId: {
        type: Schema.Types.ObjectId,
        ref: 'Order',
        required: true,
        index: true
    },
    orderNumber: { type: String, required: true },
    buyerId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    farmerId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    totalAmount: { type: Number, required: true },
    farmerAmount: { type: Number, required: true },
    logisticsAmount: { type: Number, required: true },
    platformFee: { type: Number, required: true },
    farmerPayoutAmount: { type: Number, default: 0 },
    platformFeeAmount: { type: Number, default: 0 },
    paymentState: {
        type: String,
        enum: [
            'PENDING',
            'PAID',
            'HELD_FOR_ORDER',
            'RELEASE_PENDING',
            'RELEASED',
            'REFUND_PENDING',
            'REFUNDED',
            'FAILED'
        ],
        default: 'PENDING',
        index: true
    },
    gatewayProvider: {
        type: String,
        default: 'RAZORPAY_SANDBOX'
    },
    // Razorpay identifiers
    razorpayOrderId: { type: String, default: '' },
    razorpayPaymentId: { type: String, default: '' },
    razorpayRefundId: { type: String, default: '' },
    razorpaySignature: { type: String, default: '' },
    paymentSignature: { type: String, default: '' },
    rawGatewayResponse: { type: Schema.Types.Mixed, default: {} },
    // Rich escrow timeline for UI display
    escrowTimeline: [EscrowTimelineEntrySchema],
    // Legacy history array (kept for backward compat)
    history: [
        {
            state: { type: String, required: true },
            timestamp: { type: Date, default: Date.now },
            note: { type: String, default: '' }
        }
    ]
}, {
    timestamps: true
});
export const Payment = mongoose.model('Payment', PaymentSchema);
