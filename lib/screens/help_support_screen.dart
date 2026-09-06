import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/localization.dart';

class HelpSupportScreen extends StatelessWidget {
  HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.t('Help & Support', 'सहायता और सपोर्ट'))),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Container(padding: EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.primaryDark, borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.support_agent_outlined, color: Colors.white, size: 28), SizedBox(height: 10), Text(AppStrings.t('We are here to help', 'हम मदद के लिए यहाँ हैं'), style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)), SizedBox(height: 5), Text(AppStrings.t('Get help with orders, payments, account, delivery or farm onboarding.', 'ऑर्डर, भुगतान, अकाउंट, डिलीवरी या किसान ऑनबोर्डिंग में सहायता पाएँ.'), style: TextStyle(color: Colors.white.withOpacity(.82), height: 1.4))])),
          SizedBox(height: 14),
          _SupportTile(icon: Icons.call_outlined, title: AppStrings.t('Kisan Helpline', 'किसान हेल्पलाइन'), subtitle: '1800-120-SETU', onTap: () {}),
          _SupportTile(icon: Icons.chat_outlined, title: AppStrings.t('Chat with Support', 'सपोर्ट से चैट करें'), subtitle: AppStrings.t('Typically replies in a few minutes', 'आमतौर पर कुछ मिनटों में जवाब'), onTap: () {}),
          _SupportTile(icon: Icons.report_problem_outlined, title: AppStrings.t('Report a Problem', 'समस्या रिपोर्ट करें'), subtitle: AppStrings.t('Create a support ticket', 'सपोर्ट टिकट बनाएँ'), onTap: () {}),
          _SupportTile(icon: Icons.menu_book_outlined, title: AppStrings.t('FAQs', 'अक्सर पूछे जाने वाले सवाल'), subtitle: AppStrings.t('Payments, escrow, delivery and returns', 'भुगतान, एस्क्रो, डिलीवरी और रिटर्न'), onTap: () {}),
          SizedBox(height: 8),
          Text(AppStrings.t('Backend hook', 'बैकएंड हुक'), style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 6),
          Text(AppStrings.t('Connect support actions to your ticket/chat APIs in lib/services/api_service.dart.', 'सपोर्ट के टिकट/चैट API को lib/services/api_service.dart में जोड़ें.'), style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _SupportTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  _SupportTile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(margin: EdgeInsets.only(bottom: 10), child: ListTile(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 3), leading: Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.mintTint, borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: AppColors.primary)), title: Text(title, style: Theme.of(context).textTheme.titleMedium), subtitle: Text(subtitle), trailing: Icon(Icons.chevron_right), onTap: onTap));
}
