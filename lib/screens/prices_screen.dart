import 'package:flutter/material.dart';
import '../services/localization.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class PricesScreen extends StatefulWidget {
  PricesScreen({super.key});

  @override
  State<PricesScreen> createState() => _PricesScreenState();
}

class _PricesScreenState extends State<PricesScreen> {
  final _api = ApiService();
  List<MandiPrice> _livePrices = [];
  bool _loading = true;

  static final List<MandiPrice> _fallbackPrices = [
    MandiPrice(
      cropName: 'Wheat',
      price: 2450,
      unit: AppStrings.t('Quintal', 'क्विंटल'),
      changePercent: 2.4,
      mandiName: AppStrings.t('Rohtak Mandi, Haryana', 'रोहतक मंडी, हरियाणा'),
      updatedAt: '10:30 AM',
    ),
    MandiPrice(
      cropName: AppStrings.t('Basmati Rice', 'बासमती चावल'),
      price: 3180,
      unit: AppStrings.t('Quintal', 'क्विंटल'),
      changePercent: -0.6,
      mandiName: AppStrings.t('Karnal Mandi, HR', 'करनाल मंडी, हरियाणा'),
      updatedAt: '10:15 AM',
    ),
    MandiPrice(
      cropName: 'Tomato',
      price: 32,
      unit: 'kg',
      changePercent: 4.1,
      mandiName: AppStrings.t('Azadpur, Delhi', 'आज़ादपुर, दिल्ली'),
      updatedAt: '09:45 AM',
    ),
    MandiPrice(
      cropName: AppStrings.t('Potato', 'आलू'),
      price: 18,
      unit: 'kg',
      changePercent: 1.2,
      mandiName: AppStrings.t('Agra Mandi, UP', 'आगरा मंडी, उ.प्र.'),
      updatedAt: '12:00 PM',
    ),
  ];

  static final List<DispatchStep> _steps = [
    DispatchStep(
      stepLabel: AppStrings.t('STEP 1', 'चरण 1'),
      title: AppStrings.t('Farmer Location', 'किसान का स्थान'),
      subtitle: 'Nashik FPO pickup point',
      active: true,
    ),
    DispatchStep(
      stepLabel: AppStrings.t('STEP 2', 'चरण 2'),
      title: AppStrings.t('Cold Pickup', 'कोल्ड पिकअप'),
      subtitle: 'Tonkgi 4°C Controlled',
      active: true,
    ),
    DispatchStep(
      stepLabel: AppStrings.t('STEP 3', 'चरण 3'),
      title: AppStrings.t('Optimized Route', 'अनुकूलित मार्ग'),
      subtitle: 'AI routed via NH160',
    ),
    DispatchStep(
      stepLabel: AppStrings.t('STEP 4', 'चरण 4'),
      title: AppStrings.t('Doorstep Delivery', 'घर तक डिलीवरी'),
      subtitle: AppStrings.t('City fulfillment hub', 'शहर पूर्ति केंद्र'),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  Future<void> _loadRates() async {
    try {
      final rows = await _api.getMarketRates();
      final mapped = rows.map((r) => MandiPrice(
        cropName: '${r['name'] ?? r['commodity'] ?? 'Crop'}',
        price: (r['price'] ?? r['modalPrice'] ?? 0) is num ? ((r['price'] ?? r['modalPrice'] ?? 0) as num).toDouble() : double.tryParse('${r['price'] ?? r['modalPrice'] ?? 0}') ?? 0,
        unit: '${r['unit'] ?? 'Quintal'}',
        changePercent: (r['priceChange'] as num?)?.toDouble() ?? 0,
        mandiName: '${r['mandi'] ?? r['market'] ?? 'Mandi'}',
        updatedAt: '${r['lastUpdated'] ?? r['arrivalDate'] ?? 'Latest'}',
      )).toList();
      if (mounted) setState(() { _livePrices = mapped; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prices = _livePrices.isNotEmpty ? _livePrices : _fallbackPrices;
    return Column(
      children: [
        TopStrip(text: AppStrings.t('Direct Trade • 100% Escrow Protected • Zero Middlemen', 'सीधा व्यापार • 100% एस्क्रो सुरक्षा • कोई बिचौलिया नहीं')),
        Container(
          color: AppColors.surface,
          padding: EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: BrandWordmark(subtitle: AppStrings.t('FARM TO MARKET DIRECT', 'खेत से सीधे बाज़ार'))),
                  IconButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.t('Notifications are available from Home.', 'सूचनाएँ होम स्क्रीन पर उपलब्ध हैं।')))), icon: Icon(Icons.notifications_none, size: 22)),
                ],
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  hintText: AppStrings.t('Search crop or mandi... e.g. Azadpur', 'फसल या मंडी खोजें... जैसे आज़ादपुर'),
                  prefixIcon: Icon(Icons.search, size: 20),
                  suffixIcon: Icon(Icons.refresh, size: 18),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 24),
            children: [
              EyebrowLabel(text: AppStrings.t('Live Mandi Benchmarks', 'लाइव मंडी भाव'), icon: Icons.wifi_tethering),
              SizedBox(height: 6),
              Text('Know the Market.\nSell Smarter.', style: Theme.of(context).textTheme.displaySmall),
              SizedBox(height: 6),
              Text(
                AppStrings.t('Real-time mandi rate benchmarks across major regional agricultural trading hubs.', 'प्रमुख क्षेत्रीय कृषि मंडियों के रीयल-टाइम भाव।'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 14),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: prices.length,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 420,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  mainAxisExtent: 150,
                ),
                itemBuilder: (context, i) => MandiPriceCard(price: prices[i]),
              ),
              SizedBox(height: 20),
              _PriceTrendCard(),
              SizedBox(height: 24),
              EyebrowLabel(text: AppStrings.t('Cold-Chain Dispatch & Routing', 'कोल्ड-चेन डिस्पैच और रूटिंग'), icon: Icons.local_shipping_outlined),
              SizedBox(height: 6),
              Text(AppStrings.t('From Farm to Doorstep.', 'खेत से आपके दरवाज़े तक।'), style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 6),
              Text(
                AppStrings.t('Intelligent route optimization reduces transit time, maintains produce freshness, and cuts logistics costs.', 'स्मार्ट मार्ग अनुकूलन परिवहन समय कम करता है, उपज की ताजगी बनाए रखता है और लॉजिस्टिक्स लागत घटाता है।'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 12),
              _DispatchStepsCard(steps: _steps),
              SizedBox(height: 16),
              _LiveTelemetryCard(),
              SizedBox(height: 16),
              _AiRecommendationBanner(),
            ],
          ),
        ),
      ],
    );
  }
}

class _PriceTrendCard extends StatelessWidget {
  _PriceTrendCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: appCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.t('7-Day Mandi Price Trend', '7-दिन का मंडी भाव रुझान'), style: Theme.of(context).textTheme.titleMedium),
              Pill(text: AppStrings.t('Agrovision', 'एग्रोविज़न'), background: AppColors.mintTint, foreground: AppColors.primary),
            ],
          ),
          SizedBox(height: 2),
          Text(AppStrings.t('Tomatoes vs Wheat Index Comparison', 'टमाटर बनाम गेहूँ सूचकांक तुलना'), style: Theme.of(context).textTheme.bodySmall),
          SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: CustomPaint(
              painter: _TrendChartPainter(),
              size: Size(double.infinity, 130),
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              _LegendDot(color: AppColors.accentMint, label: 'Tomato ₹32'),
              SizedBox(width: 16),
              _LegendDot(color: Color(0xFFE9A23B), label: 'Wheat ₹24.5'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: 5),
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  List<String> days = [];
  @override
  void paint(Canvas canvas, Size size) {
    days = [AppStrings.t('Mon', 'सोम'), AppStrings.t('Tue', 'मंगल'), AppStrings.t('Wed', 'बुध'), AppStrings.t('Thu', 'गुरु'), AppStrings.t('Fri', 'शुक्र'), AppStrings.t('Sat', 'शनि'), AppStrings.t('Sun', 'रवि')];
    final tomato = [0.55, 0.5, 0.6, 0.4, 0.45, 0.3, 0.2];
    final wheat = [0.7, 0.68, 0.66, 0.64, 0.6, 0.58, 0.5];

    final chartHeight = size.height - 20;

    void drawSeries(List<double> values, Color color, {bool dashed = false}) {
      final path = Path();
      for (var i = 0; i < values.length; i++) {
        final x = size.width * (i / (values.length - 1));
        final y = chartHeight * values[i];
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;
      if (dashed) {
        canvas.drawPath(_dashPath(path, 5, 4), paint);
      } else {
        canvas.drawPath(path, paint);
      }
    }

    drawSeries(wheat, Color(0xFFE9A23B), dashed: true);
    drawSeries(tomato, AppColors.accentMint);

    final labelStyle = TextStyle(fontSize: 9, color: AppColors.textMuted.withOpacity(0.9));
    for (var i = 0; i < days.length; i++) {
      final tp = TextPainter(
        text: TextSpan(text: days[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final x = size.width * (i / (days.length - 1)) - tp.width / 2;
      tp.paint(canvas, Offset(x.clamp(0, size.width - tp.width), size.height - 14));
    }
  }

  Path _dashPath(Path source, double dashWidth, double dashGap) {
    final dest = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      var draw = true;
      while (distance < metric.length) {
        final len = draw ? dashWidth : dashGap;
        if (draw) {
          dest.addPath(metric.extractPath(distance, distance + len), Offset.zero);
        }
        distance += len;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DispatchStepsCard extends StatelessWidget {
  final List<DispatchStep> steps;
  _DispatchStepsCard({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: appCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.t('Dispatch Protocol Steps', 'डिस्पैच प्रक्रिया के चरण'), style: Theme.of(context).textTheme.titleMedium),
              Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: steps.length,
              separatorBuilder: (_, __) => SizedBox(width: 10),
              itemBuilder: (context, i) {
                final step = steps[i];
                return Container(
                  width: 140,
                  padding: EdgeInsets.all(10),
                  decoration: appCardDecoration(
                    color: step.active ? AppColors.mintTint : AppColors.canvas,
                    borderColor: step.active ? AppColors.primary.withOpacity(0.4) : AppColors.border,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.stepLabel,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: step.active ? AppColors.primary : AppColors.textMuted,
                          letterSpacing: 0.4,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(step.title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                      SizedBox(height: 4),
                      Text(
                        step.subtitle,
                        style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveTelemetryCard extends StatelessWidget {
  _LiveTelemetryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: AppColors.accentMint, shape: BoxShape.circle),
              ),
              SizedBox(width: 6),
              Text(
                AppStrings.t('LIVE ROUTE TELEMETRY (DEMO BENCHMARK)', 'लाइव रूट टेलीमेट्री (डेमो)'),
                style: TextStyle(color: Colors.white70, fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 0.4),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Text(AppStrings.t('Nashik Hub', 'नासिक हब'), style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Divider(color: Colors.white24, height: 1),
                ),
              ),
              Icon(Icons.flag, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Text(AppStrings.t('Delhi City Fulfillment', 'दिल्ली शहर पूर्ति केंद्र'),
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
          SizedBox(height: 14),
          Row(
            children: [
              _TelemetryStat(value: '31 km', label: AppStrings.t('OPTIMIZED', 'अनुकूलित')),
              _TelemetryStat(value: '18%', label: AppStrings.t('FUEL SAVED', 'ईंधन बचत')),
              _TelemetryStat(value: '42 min', label: AppStrings.t('EST. ARRIVAL', 'अनुमानित आगमन')),
            ],
          ),
          SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.t('Delivery tracking will appear here when an order is active.', 'ऑर्डर सक्रिय होने पर डिलीवरी ट्रैकिंग यहाँ दिखाई जाएगी।')))),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentMint),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppStrings.t('Track Your Delivery', 'अपनी डिलीवरी ट्रैक करें')),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TelemetryStat extends StatelessWidget {
  final String value;
  final String label;
  _TelemetryStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
          SizedBox(height: 2),
          Text(label, style: TextStyle(color: Colors.white54, fontSize: 8.5, letterSpacing: 0.3)),
        ],
      ),
    );
  }
}

class _AiRecommendationBanner extends StatelessWidget {
  _AiRecommendationBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: appCardDecoration(color: AppColors.mintTint, borderColor: AppColors.mintTintStrong),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.t('AI Recommendation', 'AI सुझाव'),
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: AppColors.primaryDark)),
                SizedBox(height: 3),
                Text(
                  AppStrings.t('Hold Tomato dispatch 18 hrs for +5.2% estimated mandi arbitrage.', 'टमाटर की डिलीवरी 18 घंटे रोकें; अनुमानित मंडी लाभ +5.2% है।'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
