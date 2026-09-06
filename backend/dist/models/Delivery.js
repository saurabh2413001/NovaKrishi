import mongoose, { Schema } from 'mongoose';
const DeliveryLocationSchema = new Schema({
    address: { type: String, required: true },
    district: { type: String, required: true },
    state: { type: String, required: true },
    lat: { type: Number, required: true },
    lng: { type: Number, required: true }
});
const CurrentVehicleLocationSchema = new Schema({
    address: { type: String, required: true, default: 'Gorakhpur FPO Hub' },
    lat: { type: Number, required: true, default: 26.7606 },
    lng: { type: Number, required: true, default: 83.3732 },
    speedKmH: { type: Number, default: 45 },
    heading: { type: Number, default: 120 },
    lastUpdated: { type: Date, default: Date.now }
});
const DeliverySchema = new Schema({
    orderId: {
        type: Schema.Types.ObjectId,
        ref: 'Order',
        required: true,
        index: true
    },
    orderNumber: { type: String, required: true },
    deliveryPartnerId: {
        type: Schema.Types.ObjectId,
        ref: 'User',
        required: true,
        index: true
    },
    deliveryPartnerName: { type: String, required: true },
    deliveryPartnerPhone: { type: String, default: '+91 98765 43210' },
    vehicleInfo: {
        vehicleType: { type: String, default: 'Mini Truck' },
        vehicleNumber: { type: String, default: 'UP53BT9821' }
    },
    pickupLocation: { type: DeliveryLocationSchema, required: true },
    destination: { type: DeliveryLocationSchema, required: true },
    currentLocation: { type: CurrentVehicleLocationSchema, required: true },
    status: {
        type: String,
        enum: ['ASSIGNED', 'PICKED_UP', 'IN_TRANSIT', 'OUT_FOR_DELIVERY', 'DELIVERED'],
        default: 'IN_TRANSIT',
        index: true
    },
    estimatedArrival: { type: Date, required: true },
    distanceRemainingKm: { type: Number, default: 142 },
    isDemoSimulator: { type: Boolean, default: true },
    pickupTime: { type: Date },
    deliveryTime: { type: Date }
}, {
    timestamps: true
});
export const Delivery = mongoose.model('Delivery', DeliverySchema);
