import '../models/models.dart';
import '../services/app_state.dart';
import '../screens/customer_screen.dart';
import '../screens/delivery_partner_screen.dart';
import '../screens/buyer_offer_screen.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import '../services/localization.dart';
import '../screens/home_screen.dart';
import '../screens/marketplace_screen.dart';
import '../screens/prices_screen.dart';
import '../screens/ai_insights_screen.dart';
import '../screens/profile_screen.dart';

/// Responsive app shell. Swipe left/right between tabs, or tap the bottom bar.
class AppShell extends StatefulWidget {
  final int initialIndex;
  AppShell({super.key, this.initialIndex = 0});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index = widget.initialIndex;
  late final PageController _controller = PageController(initialPage: widget.initialIndex);

  final _pages = [HomeScreen(), MarketplaceScreen(), PricesScreen(), AiInsightsScreen(), ProfileScreen()];
  final _destinations = [
    (icon: Icons.home_outlined, activeIcon: Icons.home, en: AppStrings.t('Home', 'होम'), hi: 'होम'),
    (icon: Icons.storefront_outlined, activeIcon: Icons.storefront, en: AppStrings.t('Market', 'बाज़ार'), hi: 'बाज़ार'),
    (icon: Icons.show_chart_outlined, activeIcon: Icons.show_chart, en: AppStrings.t('Prices', 'भाव'), hi: 'भाव'),
    (icon: Icons.auto_awesome_outlined, activeIcon: Icons.auto_awesome, en: AppStrings.t('AI Insights', 'AI जानकारी'), hi: 'AI जानकारी'),
    (icon: Icons.person_outline, activeIcon: Icons.person, en: AppStrings.t('Profile', 'प्रोफ़ाइल'), hi: 'प्रोफ़ाइल'),
  ];

  @override
  void initState() {
    super.initState();
    appState.addListener(_onLanguageChanged);
  }

  void _onLanguageChanged() => setState(() {});

  @override
  void dispose() {
    appState.removeListener(_onLanguageChanged);
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    setState(() => _index = index);
    _controller.animateToPage(index, duration: Duration(milliseconds: 260), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final role = appState.role;
    debugPrint("CURRENT ROLE = $role");
    if (role == KrishiRole.customer) {
      return const CustomerScreen();
    }

    if (role == KrishiRole.bulkBuyer) {
      return const BuyerOfferScreen();
    }

    if (role == KrishiRole.deliveryPartner) {
      return const DeliveryPartnerScreen();
    }
    // Responsive navbar: bottom tab bar on phones, a side NavigationRail on
    // tablets / foldables / desktop-width windows (>= 700 logical px), where
    // a bottom bar would stretch tab labels awkwardly across the full width.
    final isWide = MediaQuery.sizeOf(context).width >= 700;

    final body = SafeArea(
      bottom: !isWide,
      child: PageView.builder(
        controller: _controller,
        itemCount: _pages.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (context, i) => _pages[i],
      ),
    );

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                selectedIndex: _index,
                onDestinationSelected: _goTo,
                labelType: NavigationRailLabelType.all,
                backgroundColor: AppColors.surface,
                destinations: [
                  for (final d in _destinations)
                    NavigationRailDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.activeIcon),
                      label: Text(AppStrings.t(d.en, d.hi)),
                    ),
                ],
              ),
            ),
            VerticalDivider(width: 1, color: AppColors.border),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.border))),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 66,
            child: LayoutBuilder(builder: (context, constraints) {
              final compact = constraints.maxWidth < 390;
              return Row(children: List.generate(_destinations.length, (i) {
                final d = _destinations[i];
                final active = i == _index;
                final color = active ? AppColors.primaryDark : AppColors.textMuted;
                return Expanded(
                  child: Semantics(
                    button: true,
                    selected: active,
                    label: AppStrings.t(d.en, d.hi),
                    child: InkWell(
                      onTap: () => _goTo(i),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(active ? d.activeIcon : d.icon, color: color, size: compact ? 20 : 22),
                        SizedBox(height: 3),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          child: Text(AppStrings.t(d.en, d.hi), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: compact ? 9 : 10, fontWeight: active ? FontWeight.w700 : FontWeight.w500, color: color)),
                        ),
                      ]),
                    ),
                  ),
                );
              }));
            }),
          ),
        ),
      ),
    );
  }
}
