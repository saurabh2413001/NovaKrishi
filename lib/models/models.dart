/// Simple immutable data holders used to feed the demo UI.
/// In a production build these would be replaced by models generated from
/// the NovaKrishi backend / GraphQL schema.
library models;

/// One listing on the "Fresh From the Farm" marketplace.
class Produce {
  final String name;
  final String category; // Vegetables, Fruits, Grains, ...
  final String farmName;
  final String location;
  final double distanceKm;
  final double price;
  final String unit; // /kg, /Quintal, /dozen
  final int availableQty;
  final String availableUnit;
  final double rating;
  final bool verified;
  final bool organic;
  final String? imageUrl;
  final String? id;

  const Produce({
    required this.name,
    required this.category,
    required this.farmName,
    required this.location,
    required this.distanceKm,
    required this.price,
    required this.unit,
    required this.availableQty,
    required this.availableUnit,
    required this.rating,
    this.verified = true,
    this.organic = false,
    this.imageUrl,
    this.id,
  });
}

/// A live mandi (wholesale market) benchmark price used on the Prices tab.
class MandiPrice {
  final String cropName;
  final double price;
  final String unit;
  final double changePercent; // positive = up, negative = down
  final String mandiName;
  final String updatedAt;

  const MandiPrice({
    required this.cropName,
    required this.price,
    required this.unit,
    required this.changePercent,
    required this.mandiName,
    required this.updatedAt,
  });

  bool get isUp => changePercent >= 0;
}

/// A single stage in the cold-chain dispatch / route protocol.
class DispatchStep {
  final String stepLabel; // STEP 1, STEP 2 ...
  final String title;
  final String subtitle;
  final bool active;

  const DispatchStep({
    required this.stepLabel,
    required this.title,
    required this.subtitle,
    this.active = false,
  });
}

/// The four account types offered during onboarding.
enum KrishiRole { farmer, consumer, bulkBuyer, coldChainPartner }

extension KrishiRoleX on KrishiRole {
  String get title {
    switch (this) {
      case KrishiRole.farmer:
        return 'Farmer / FPO';
      case KrishiRole.consumer:
        return 'Consumer';
      case KrishiRole.bulkBuyer:
        return 'Bulk Buyer / Trader';
      case KrishiRole.coldChainPartner:
        return 'Cold-Chain Partner';
    }
  }

  String get badge {
    switch (this) {
      case KrishiRole.farmer:
        return 'Zero Commission';
      case KrishiRole.consumer:
        return 'Fresh Farm Produce';
      case KrishiRole.bulkBuyer:
        return 'Mandi Verified';
      case KrishiRole.coldChainPartner:
        return 'Route Optimized';
    }
  }

  String get description {
    switch (this) {
      case KrishiRole.farmer:
        return 'Sell crops directly at live mandi benchmark prices with '
            'direct bank payout.';
      case KrishiRole.consumer:
        return 'Buy verified farm-fresh vegetables and fruits delivered '
            'straight to your doorstep.';
      case KrishiRole.bulkBuyer:
        return 'Source truckload agricultural lots with verified quality '
            'test reports.';
      case KrishiRole.coldChainPartner:
        return 'Deliver fresh consignments with AI route optimization and '
            'instant payouts.';
    }
  }
}
