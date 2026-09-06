import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import '../services/localization.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = true;
  bool priceAlerts = true;
  bool biometric = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: Text(AppStrings.t('Settings', 'सेटिंग्स'))),
        body: ListView(padding: EdgeInsets.all(16), children: [
          Text(AppStrings.t('Preferences', 'पसंद'), style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 8),
          Card(child: Column(children: [
            ListTile(title: Text(AppStrings.t('Language', 'भाषा')), subtitle: Text(appState.isHindi ? 'हिन्दी' : AppStrings.t('English', 'अंग्रेज़ी')), leading: Icon(Icons.language), trailing: SegmentedButton<AppLanguage>(segments: [ButtonSegment(value: AppLanguage.english, label: Text('EN')), ButtonSegment(value: AppLanguage.hindi, label: Text('हि'))], selected: {appState.language}, onSelectionChanged: (s) => appState.setLanguage(s.first))),
            Divider(height: 1),
            SwitchListTile(value: notifications, onChanged: (v) => setState(() => notifications = v), title: Text(AppStrings.t('Notifications', 'सूचनाएँ')), subtitle: Text(AppStrings.t('Order and account updates', 'ऑर्डर और अकाउंट अपडेट')), secondary: Icon(Icons.notifications_outlined)),
            SwitchListTile(value: priceAlerts, onChanged: (v) => setState(() => priceAlerts = v), title: Text(AppStrings.t('Mandi Price Alerts', 'मंडी मूल्य अलर्ट')), subtitle: Text(AppStrings.t('Get price movement notifications', 'कीमत में बदलाव की सूचना पाएँ')), secondary: Icon(Icons.show_chart)),
            SwitchListTile(value: biometric, onChanged: (v) => setState(() => biometric = v), title: Text(AppStrings.t('Biometric Unlock', 'बायोमेट्रिक अनलॉक')), subtitle: Text(AppStrings.t('Use device biometrics when supported', 'डिवाइस बायोमेट्रिक्स का उपयोग करें')), secondary: Icon(Icons.fingerprint)),
          ])),
          SizedBox(height: 16),
          Text(AppStrings.t('Account & Security', 'अकाउंट और सुरक्षा'), style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 8),
          Card(child: Column(children: [
            ListTile(leading: Icon(Icons.lock_outline), title: Text(AppStrings.t('Change PIN / Password', 'PIN / पासवर्ड बदलें')), trailing: Icon(Icons.chevron_right), onTap: () {}),
            Divider(height: 1),
            ListTile(leading: Icon(Icons.privacy_tip_outlined), title: Text(AppStrings.t('Privacy & Terms', 'गोपनीयता और शर्तें')), trailing: Icon(Icons.chevron_right), onTap: () {}),
          ])),
          SizedBox(height: 14),
          Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.mintTint, borderRadius: BorderRadius.circular(12)), child: Text(AppStrings.t('API hook: persist these settings through your user-preferences endpoint in lib/services/api_service.dart.', 'API हुक: इन सेटिंग्स को lib/services/api_service.dart में user-preferences endpoint से सेव करें.'), style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary))),
        ]),
      ),
    );
  }
}
