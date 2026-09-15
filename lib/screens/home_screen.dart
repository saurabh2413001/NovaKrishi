import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/app_state.dart';
import '../services/localization.dart';
import 'marketplace_screen.dart';
import 'settings_screen.dart';
import 'my_store_screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ApiService();
  List<Produce> _liveProduce = [];
  bool _loading = true;
  bool _serverOnline = false;

  @override
  void initState() {
    super.initState();
    appState.addListener(_refreshLanguage);
    _loadHomeData();
  }

  @override
  void dispose() {
    appState.removeListener(_refreshLanguage);
    super.dispose();
  }

  void _refreshLanguage() => setState(() {});

  Future<void> _loadHomeData() async {
    try {
      final rows = await _api.getProducts(limit: 4);
      final mapped = rows.map(_toProduce).toList();
      if (mounted) {
        setState(() {
          _liveProduce = mapped;
          _serverOnline = true;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() {
        _serverOnline = false;
        _loading = false;
      });
    }
  }

  Produce _toProduce(Map<String, dynamic> p) {
    final location = p['location'] is Map ? Map<String, dynamic>.from(p['location']) : <String, dynamic>{};
    return Produce(
      id: p['id']?.toString(),
      name: '${p['title'] ?? 'Farm Produce'}',
      category: '${p['category'] ?? 'Produce'}',
      farmName: '${p['fpoName'] ?? p['farmerName'] ?? 'Verified Farm'}',
      location: '${location['district'] ?? ''}, ${location['state'] ?? ''}',
      distanceKm: 0,
      price: (p['price'] as num?)?.toDouble() ?? 0,
      unit: '/${p['unit'] ?? 'kg'}',
      availableQty: (p['availableQuantity'] as num?)?.round() ?? 0,
      availableUnit: '${p['unit'] ?? 'kg'}',
      rating: (p['rating'] as num?)?.toDouble() ?? 4.5,
      verified: p['isVerifiedFPO'] == true,
      organic: p['isOrganicCertified'] == true,
      imageUrl: p['imageUrl']?.toString(),
    );
  }

  void _toggleLanguage() {
    appState.setLanguage(appState.isHindi ? AppLanguage.english : AppLanguage.hindi);
  }

  Future<void> _showNotifications() async {
    try {
      final alerts = await _api.getAlerts();
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(AppStrings.t('Notifications', 'सूचनाएँ')),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.82,
              maxHeight: MediaQuery.sizeOf(context).height * 0.55,
            ),
            child: alerts.isEmpty
                ? Text(AppStrings.t('No new alerts right now.', 'अभी कोई नई सूचना नहीं है।'))
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: alerts.length > 8 ? 8 : alerts.length,
                    separatorBuilder: (_, __) => Divider(),
                    itemBuilder: (_, i) => Text(
                      '${alerts[i]['title'] ?? alerts[i]['message'] ?? 'Farm alert'}',
                    ),
                  ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(AppStrings.t('Close', 'बंद करें'))),
          ],
        ),
      );
    } catch (_) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(AppStrings.t('Notifications', 'सूचनाएँ')),
          content: Text(AppStrings.t(
            'Notifications are temporarily unavailable. Check the backend connection.',
            'सूचनाएँ अभी उपलब्ध नहीं हैं। बैकएंड कनेक्शन जाँचें।',
          )),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(AppStrings.t('Close', 'बंद करें')))],
        ),
      );
    }
  }

  static final List<Produce> _previewProduce = [
    Produce(
      name: AppStrings.t('Fresh Farm Tomatoes', 'खेत के ताज़ा टमाटर'),
      category: AppStrings.t('Vegetables', 'सब्ज़ियाँ'),
      farmName: AppStrings.t('Green Valley FPO', 'ग्रीन वैली FPO'),
      location: AppStrings.t('Nashik, Maharashtra', 'नासिक, महाराष्ट्र'),
      distanceKm: 4.1,
      price: 32,
      unit: '/kg',
      availableQty: 4500,
      availableUnit: 'kg',
      rating: 4.6,
    ),
    Produce(
      name: AppStrings.t('Organic Potatoes (Desi)', 'ऑर्गेनिक देसी आलू'),
      category: AppStrings.t('Vegetables', 'सब्ज़ियाँ'),
      farmName: AppStrings.t('Devbhumi FPO', 'देवभूमि FPO'),
      location: 'Gorakhpur, UP',
      distanceKm: 6.8,
      price: 24,
      unit: '/kg',
      availableQty: 8000,
      availableUnit: 'kg',
      rating: 4.4,
      organic: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TopStrip(text: AppStrings.t('Direct Trade • 100% Escrow Protected • Zero Middlemen', 'सीधा व्यापार • 100% एस्क्रो सुरक्षा • कोई बिचौलिया नहीं')),
        _HomeAppBar(onLanguage: _toggleLanguage, onNotifications: _showNotifications, serverOnline: _serverOnline, isFarmer: appState.role == KrishiRole.farmer),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadHomeData,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
              EyebrowLabel(text: AppStrings.t('Smart Agriculture Marketplace', 'स्मार्ट कृषि बाज़ार')),
              SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.displaySmall,
                  children: [
                    TextSpan(text: 'From Farm to Market,\n'),
                    TextSpan(
                      text: 'Without the Middlemen.',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Text(
                AppStrings.t(
                  'Connect directly with farmers, FPOs, consumers and bulk buyers through a transparent digital marketplace powered by fair prices, intelligent logistics and AI-driven insights.',
                  'किसानों, FPO, उपभोक्ताओं और थोक खरीदारों से पारदर्शी डिजिटल बाज़ार के माध्यम से सीधे जुड़ें, जो उचित कीमतों, स्मार्ट लॉजिस्टिक्स और AI-आधारित जानकारी से संचालित है।',
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => Scaffold(body: MarketplaceScreen())),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppStrings.t('Explore Marketplace', 'बाज़ार देखें')),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
              SizedBox(height: 10),
              SizedBox(height: 6),
              _PriceInsightCard(),
              SizedBox(height: 16),
              _SecureBanner(),
              SizedBox(height: 24),
              EyebrowLabel(text: AppStrings.t('Core Platform Benefits', 'मुख्य प्लेटफ़ॉर्म लाभ')),
              SizedBox(height: 12),
              BenefitTile(
                icon: Icons.handshake_outlined,
                title: AppStrings.t('Direct From Farmers', 'सीधे किसानों से'),
                subtitle: 'Zero APMC broker commissions & markups',
              ),
              BenefitTile(
                icon: Icons.price_change_outlined,
                title: 'Transparent Pricing',
                subtitle: AppStrings.t('Real-time fair price benchmarks & dynamic pricing', 'रीयल-टाइम उचित मूल्य और गतिशील मूल्य निर्धारण'),
              ),
              BenefitTile(
                icon: Icons.auto_awesome_outlined,
                title: AppStrings.t('AI-Powered Insights', 'AI आधारित जानकारी'),
                subtitle: AppStrings.t('Demand & harvest price predictive forecasts', 'मांग और कटाई मूल्य के पूर्वानुमान'),
              ),
              BenefitTile(
                icon: Icons.local_shipping_outlined,
                title: 'Smart Logistics',
                subtitle: AppStrings.t('Cold-chain fleet with live GPS route status', 'लाइव GPS मार्ग स्थिति वाला कोल्ड-चेन बेड़ा'),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  EyebrowLabel(text: AppStrings.t('Direct Marketplace', 'सीधा बाज़ार')),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => Scaffold(body: MarketplaceScreen())),
                    ),
                    child: Text(AppStrings.t('View All  ›', 'सभी देखें  ›')),
                  ),
                ],
              ),
              Text(AppStrings.t('Fresh From the Farm', 'खेत से सीधे ताज़ा'), style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 12),
              if (_loading) Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              for (final p in (_liveProduce.isNotEmpty ? _liveProduce : _previewProduce)) ProduceCard(produce: p),
            ],
          ),
          ),
        ),
      ],
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  final VoidCallback onLanguage;
  final VoidCallback onNotifications;
  final bool serverOnline;
  final bool isFarmer;

  _HomeAppBar({
    required this.onLanguage,
    required this.onNotifications,
    required this.serverOnline,
    required this.isFarmer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: BrandWordmark(
              onTap: () {
                // The brand is a safe home shortcut from every home state.
                Scrollable.ensureVisible(context);
              },
            ),
          ),
          Tooltip(
            message: serverOnline ? AppStrings.t('Backend online', 'बैकएंड ऑनलाइन') : AppStrings.t('Backend offline', 'बैकएंड ऑफ़लाइन'),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                Icons.circle,
                size: 8,
                color: serverOnline ? AppColors.success : AppColors.danger,
              ),
            ),
          ),
          if (isFarmer)
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MyStoreScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.storefront_outlined, size: 21),
              tooltip: AppStrings.t('My Store', 'मेरी दुकान'),
            ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onLanguage,
            icon: Icon(Icons.translate, size: 20),
            tooltip: AppStrings.t('English / Hindi', 'अंग्रेज़ी / हिन्दी'),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onNotifications,
            icon: Icon(Icons.notifications_none, size: 22),
            tooltip: AppStrings.t('Notifications', 'सूचनाएँ'),
          ),
          PopupMenuButton<String>(
            tooltip: AppStrings.t('More', 'अधिक'),
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(),
                  ),
                );
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    const Icon(Icons.settings_outlined, size: 20),
                    const SizedBox(width: 10),
                    Text(AppStrings.t('Settings', 'सेटिंग्स')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// AppStrings.t("Welcome back, Farmer!", "किसान, आपका स्वागत है!") price-insight preview card shown on the home tab.
class _PriceInsightCard extends StatelessWidget {
  _PriceInsightCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: appCardDecoration(color: AppColors.primaryDark, borderColor: AppColors.primaryDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 330;

              final title = Text(
                AppStrings.t('Welcome back, Farmer!', 'किसान, आपका स्वागत है!'),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
                maxLines: compact ? 2 : 1,
                overflow: TextOverflow.ellipsis,
              );

              final feed = Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(
                  AppStrings.t('Farm Feed', 'कृषि फ़ीड'),
                  style: TextStyle(color: Colors.white, fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    SizedBox(height: 6),
                    feed,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: title),
                  SizedBox(width: 8),
                  feed,
                ],
              );
            },
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.eco, size: 14, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text(AppStrings.t("Today's Price Insights", "आज के भाव की जानकारी"),
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                      ],
                    ),
                    Pill(text: AppStrings.t('High Demand', 'उच्च मांग'), background: Color(0xFFFCEAEA), foreground: AppColors.danger),
                  ],
                ),
                SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 250;

                    final price = Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '₹42',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 3),
                        Text(
                          AppStrings.t('/ kg', ' / किग्रा'),
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    );

                    final change = Pill.change(4.0, fontSize: 10);

                    if (compact) {
                      return Wrap(
                        spacing: 6,
                        runSpacing: 5,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          price,
                          change,
                        ],
                      );
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        price,
                        change,
                      ],
                    );
                  },
                ),
                SizedBox(height: 10),
                Divider(height: 1),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _MiniStat(label: 'This Week', value: '12', suffix: 'orders'),
                    ),
                    Expanded(
                      child: _MiniStat(label: AppStrings.t('Earnings', 'कमाई'), value: '₹18,450', badge: '+12%'),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.trending_up, size: 13, color: AppColors.primary),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(AppStrings.t('AI Demand Forecast', 'AI मांग पूर्वानुमान'),
                          maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5)),
                    ),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(AppStrings.t('Tomato demand +20%', 'टमाटर की मांग +20%'),
                          maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                SizedBox(
                  height: 40,
                  child: CustomPaint(
                    painter: _SparklinePainter(),
                    size: Size(double.infinity, 40),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final String? suffix;
  final String? badge;
  _MiniStat({required this.label, required this.value, this.suffix, this.badge});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
        SizedBox(height: 2),
        Row(
          children: [
            Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            if (suffix != null) ...[
              SizedBox(width: 3),
              Text(suffix!, style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
            ],
            if (badge != null) ...[
              SizedBox(width: 4),
              Pill(text: badge!, fontSize: 9),
            ],
          ],
        ),
      ],
    );
  }
}

class _SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final points = [0.7, 0.5, 0.6, 0.35, 0.45, 0.2, 0.1];
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = size.width * (i / (points.length - 1));
      final y = size.height * points[i];
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final linePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = AppColors.primary;
    final lastX = size.width;
    final lastY = size.height * points.last;
    canvas.drawCircle(Offset(lastX, lastY), 3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SecureBanner extends StatelessWidget {
  _SecureBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: appCardDecoration(color: AppColors.mintTint, borderColor: AppColors.mintTintStrong),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '100% Safe & Secure',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.primaryDark),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            AppStrings.t('Escrow Protected Payments. No Middleman. Fair Price.', 'एस्क्रो सुरक्षित भुगतान। कोई बिचौलिया नहीं। उचित मूल्य।'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Pill(text: 'Smart Logistics', icon: Icons.local_shipping_outlined),
              Pill(text: AppStrings.t('Cold-chain GPS Tracking', 'कोल्ड-चेन GPS ट्रैकिंग'), icon: Icons.ac_unit),
              Pill(text: '10 Countries', icon: Icons.public),
            ],
          ),
        ],
      ),
    );
  }
}
