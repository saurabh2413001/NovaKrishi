import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../services/localization.dart';

class OrderHistoryScreen extends StatelessWidget {
  OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.t('Order History', 'ऑर्डर इतिहास'))),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          TopStrip(text: AppStrings.t('Track purchases, deliveries and payouts', 'खरीद, डिलीवरी और भुगतान ट्रैक करें')),
          SizedBox(height: 14),
          _OrderCard(
            orderId: '#NV-2026-00124',
            item: AppStrings.t('Fresh Tomatoes', 'ताज़े टमाटर'),
            qty: '80 kg',
            amount: '₹3,840',
            status: AppStrings.t('Delivered', 'डिलीवर हो गया'),
            icon: Icons.check_circle,
            color: AppColors.success,
          ),
          _OrderCard(
            orderId: '#NV-2026-00119',
            item: AppStrings.t('Red Onions', 'लाल प्याज़'),
            qty: '120 kg',
            amount: '₹4,560',
            status: AppStrings.t('In transit', 'रास्ते में'),
            icon: Icons.local_shipping_outlined,
            color: AppColors.primary,
          ),
          _OrderCard(
            orderId: '#NV-2026-00103',
            item: AppStrings.t('Grapes', 'अंगूर'),
            qty: '40 kg',
            amount: '₹2,800',
            status: AppStrings.t('Cancelled', 'रद्द'),
            icon: Icons.cancel_outlined,
            color: AppColors.danger,
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(16),
            decoration: appCardDecoration(color: AppColors.mintTint),
            child: Row(
              children: [
                Icon(Icons.receipt_long_outlined, color: AppColors.primary),
                SizedBox(width: 12),
                Expanded(child: Text(AppStrings.t('Your live order data will appear here after backend API integration.', 'बैकएंड API जोड़ने के बाद आपके लाइव ऑर्डर यहाँ दिखेंगे.'), style: Theme.of(context).textTheme.bodySmall)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final String orderId;
  final String item;
  final String qty;
  final String amount;
  final String status;
  final IconData icon;
  final Color color;

  _OrderCard({required this.orderId, required this.item, required this.qty, required this.amount, required this.status, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(14),
      decoration: appCardDecoration(),
      child: Row(
        children: [
          Container(width: 46, height: 46, decoration: BoxDecoration(color: AppColors.mintTint, borderRadius: BorderRadius.circular(12)), child: Icon(Icons.eco_outlined, color: color)),
          SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item, style: Theme.of(context).textTheme.titleMedium), SizedBox(height: 3), Text('$orderId • $qty', style: Theme.of(context).textTheme.bodySmall), SizedBox(height: 7), Row(children: [Icon(icon, size: 15, color: color), SizedBox(width: 5), Text(status, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: color))])])),
          Text(amount, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
