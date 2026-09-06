import 'package:flutter/material.dart';
import '../services/localization.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'crop_photo_screen.dart';

class AiInsightsScreen extends StatefulWidget {
  AiInsightsScreen({super.key});
  @override
  State<AiInsightsScreen> createState() => _AiInsightsScreenState();
}

class _AiInsightsScreenState extends State<AiInsightsScreen> {
  final _api = ApiService();
  bool _loading = true;
  List<Map<String, dynamic>> _forecast = [];

  @override
  void initState() {
    super.initState();
    _loadForecast();
  }

  Future<void> _loadForecast() async {
    try {
      final rows = await _api.getDemandForecast(crop: 'Tomato', state: 'Uttar Pradesh', district: 'Gorakhpur');
      if (mounted) setState(() { _forecast = rows; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.surface,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [Expanded(child: BrandWordmark(subtitle: AppStrings.t('AI INSIGHTS', 'AI जानकारी'))), IconButton(onPressed: _loadForecast, icon: Icon(Icons.refresh))]),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              EyebrowLabel(text: AppStrings.t('AI-Powered Insights', 'AI आधारित जानकारी'), icon: Icons.auto_awesome_outlined),
              SizedBox(height: 8),
              Text(AppStrings.t('Forecasts for your crops', 'आपकी फसलों के पूर्वानुमान'), style: Theme.of(context).textTheme.displaySmall),
              SizedBox(height: 8),
              Text(AppStrings.t('Demand forecasts and harvest-timing suggestions are loaded from the NovaKrishi API.', 'मांग पूर्वानुमान और कटाई समय सुझाव NovaKrishi API से लोड होते हैं।'), style: Theme.of(context).textTheme.bodyMedium),
              SizedBox(height: 16),
              if (_loading) Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
              else if (_forecast.isEmpty) Container(padding: EdgeInsets.all(18), decoration: appCardDecoration(), child: Text(AppStrings.t('No forecast is available right now. Refresh after the backend is online.', 'अभी कोई पूर्वानुमान उपलब्ध नहीं है। बैकएंड ऑनलाइन होने के बाद रीफ्रेश करें।')))
              else ...[
                for (final row in _forecast.take(8))
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    padding: EdgeInsets.all(14),
                    decoration: appCardDecoration(),
                    child: Row(children: [
                      Icon(Icons.trending_up, color: AppColors.primary),
                      SizedBox(width: 10),
                      Expanded(child: Text('${row['crop'] ?? row['name'] ?? 'Tomato'} — ${row['forecast'] ?? row['prediction'] ?? row['demand'] ?? 'Available'}', style: Theme.of(context).textTheme.titleMedium)),
                    ]),
                  ),
              ],
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(20),
                decoration: appCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.camera_alt_outlined, size: 36, color: AppColors.primary),
                    SizedBox(height: 10),
                    Text(AppStrings.t('Scan a crop photo', 'फसल की फ़ोटो स्कैन करें'), style: TextStyle(fontWeight: FontWeight.w700), textAlign: TextAlign.center),
                    SizedBox(height: 4),
                    Text(AppStrings.t('Upload a crop photo for the configured AI analysis service.', 'कॉन्फ़िगर की गई AI विश्लेषण सेवा के लिए फसल की फ़ोटो अपलोड करें।'), textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                    SizedBox(height: 12),
                    ElevatedButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CropPhotoScreen())), icon: Icon(Icons.camera_alt_outlined, size: 18), label: Text(AppStrings.t('Open Camera', 'कैमरा खोलें'))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
