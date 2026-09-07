import 'package:flutter/material.dart';
import '../../services/localization.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../models/models.dart';
import '../../widgets/app_shell.dart';
import 'sign_in_screen.dart';
import 'farmer_registration_screen.dart';
import '../buyer_offer_screen.dart';
import '../customer_screen.dart';
import '../delivery_partner_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  KrishiRole _selected = KrishiRole.farmer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: authAppBar(context),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_back, size: 14, color: AppColors.textMuted),
                      SizedBox(width: 4),
                      Text(AppStrings.t('Back to Login', 'लॉगिन पर वापस जाएँ'), style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Pill(text: AppStrings.t('Account Type', 'खाता प्रकार'), icon: Icons.badge_outlined),
            SizedBox(height: 14),
            Text('How will you use\nNovaKrishi?', style: Theme.of(context).textTheme.displaySmall),
            SizedBox(height: 10),
            ProgressHeader(
              eyebrow: AppStrings.t('Select your role', 'अपनी भूमिका चुनें'),
              step: AppStrings.t('STEP 1 OF 2', 'चरण 1 / 2'),
              progress: 0.5,
            ),
            SizedBox(height: 8),
            Text(
              AppStrings.t('Select your primary role. You can easily link buyer and seller profiles later.', 'अपनी मुख्य भूमिका चुनें। आप बाद में खरीदार और विक्रेता प्रोफ़ाइल जोड़ सकते हैं।'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            RoleOptionCard(
              icon: Icons.agriculture_outlined,
              role: KrishiRole.farmer,
              selected: _selected == KrishiRole.farmer,
              onTap: () => setState(() => _selected = KrishiRole.farmer),
            ),
            RoleOptionCard(
              icon: Icons.shopping_bag_outlined,
              role: KrishiRole.customer,
              selected: _selected == KrishiRole.customer,
              onTap: () => setState(() => _selected = KrishiRole.customer),
            ),
            RoleOptionCard(
              icon: Icons.storefront_outlined,
              role: KrishiRole.bulkBuyer,
              selected: _selected == KrishiRole.bulkBuyer,
              onTap: () => setState(() => _selected = KrishiRole.bulkBuyer),
            ),
            RoleOptionCard(
              icon: Icons.local_shipping_outlined,
              role: KrishiRole.deliveryPartner,
              selected: _selected == KrishiRole.deliveryPartner,
              onTap: () => setState(() => _selected = KrishiRole.deliveryPartner),
            ),
            SizedBox(height: 6),
            Container(
              padding: EdgeInsets.all(12),
              decoration: appCardDecoration(color: AppColors.mintTint, borderColor: AppColors.mintTintStrong),
              child: Row(
                children: [
                  Icon(Icons.verified_outlined, color: AppColors.primary, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.t('Unified National Agriculture Market', 'एकीकृत राष्ट्रीय कृषि बाज़ार'),
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: AppColors.primaryDark)),
                        SizedBox(height: 2),
                        Text(
                          AppStrings.t(
                            'KYC & Aadhaar verified network connecting 4,200+ mandis',
                            'KYC और आधार सत्यापित नेटवर्क, 4,200+ मंडियों से जुड़ा',
                          ),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.t('Admin access is restricted to authorized accounts.', 'एडमिन एक्सेस केवल अधिकृत खातों के लिए है।')))),
                child: Text.rich(
                  TextSpan(
                    text: AppStrings.t('Looking for Admin access? ', 'क्या आपको एडमिन एक्सेस चाहिए? '),
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    children: [
                      TextSpan(
                        text: AppStrings.t('Secure Portal →', 'सुरक्षित पोर्टल →'),
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 6),
            ElevatedButton(
              onPressed: () {
              if (_selected == KrishiRole.farmer) {

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => FarmerRegistrationScreen(),
    ),
  );

} else if (_selected == KrishiRole.bulkBuyer) {

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (_) => const BuyerOfferScreen(),
    ),
    (route) => false,
  );

} else if (_selected == KrishiRole.customer) {

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (_) => const CustomerScreen(),
    ),
    (route) => false,
  );

} else if (_selected == KrishiRole.deliveryPartner) {

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (_) => const DeliveryPartnerScreen(),
    ),
    (route) => false,
  );

} else {

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (_) => AppShell(),
    ),
    (route) => false,
  );

}
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final label = AppStrings.t(
                    'Continue as ${_selected.title}',
                    '${_selected.title} के रूप में जारी रखें',
                  );

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 18),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 6),
            Center(
              child: Text(
                'Takes less than 2 minutes • Instant digital verification',
                style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
              ),
            ),
            SizedBox(height: 20),
            AuthFooter(),
          ],
        ),
      ),
    );
  }
}
