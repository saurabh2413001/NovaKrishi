import 'package:flutter/material.dart';
import '../../services/localization.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/app_shell.dart';
import 'sign_in_screen.dart';

class FarmerRegistrationScreen extends StatefulWidget {
  FarmerRegistrationScreen({super.key});

  @override
  State<FarmerRegistrationScreen> createState() => _FarmerRegistrationScreenState();
}

class _FarmerRegistrationScreenState extends State<FarmerRegistrationScreen> {
  final _nameCtrl = TextEditingController(text: AppStrings.t('Ramesh Kumar', 'रमेश कुमार'));
  final _mobileCtrl = TextEditingController(text: '98452 31920');
  final _villageCtrl = TextEditingController(text: AppStrings.t('Dindori', 'दिंडोरी'));
  final _pincodeCtrl = TextEditingController(text: '422202');
  final _fpoCtrl = TextEditingController(text: AppStrings.t('Sahyadri Farmers Producer Co.', 'सह्याद्री किसान उत्पादक कंपनी'));

  String? _state = AppStrings.t('Maharashtra', 'महाराष्ट्र');
  String? _district = AppStrings.t('Nashik', 'नासिक');
  String _farmSize = '2-5 Acres';
  bool _fpoMember = true;
  bool _agreedToTerms = false;

  final List<String> _crops = ['Tomatoes', AppStrings.t('Onions', 'प्याज़'), AppStrings.t('Grapes', 'अंगूर')];
  static const List<String> _allFarmSizes = ['1-2 Acres', '2-5 Acres', '5-10 Acres', '10+ Acres'];
  static final _states = [AppStrings.t('Maharashtra', 'महाराष्ट्र'), AppStrings.t('Uttar Pradesh', 'उत्तर प्रदेश'), AppStrings.t('Punjab', 'पंजाब'), AppStrings.t('Haryana', 'हरियाणा'), AppStrings.t('Madhya Pradesh', 'मध्य प्रदेश')];
  static final _districts = [AppStrings.t('Nashik', 'नासिक'), AppStrings.t('Pune', 'पुणे'), AppStrings.t('Nagpur', 'नागपुर'), AppStrings.t('Aurangabad', 'औरंगाबाद')];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _villageCtrl.dispose();
    _pincodeCtrl.dispose();
    _fpoCtrl.dispose();
    super.dispose();
  }

  void _addCrop() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.t('Add crop', 'फसल जोड़ें')),
        content: TextField(controller: controller, decoration: InputDecoration(hintText: 'e.g. Soybean')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppStrings.t('Cancel', 'रद्द करें'))),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: Text(AppStrings.t('Add', 'जोड़ें'))),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      setState(() => _crops.add(result.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: authAppBar(context),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Pill(text: AppStrings.t('Farmer & FPO Onboarding', 'किसान और FPO पंजीकरण'), icon: Icons.agriculture_outlined),
            SizedBox(height: 14),
            Text(AppStrings.t('Register as Farmer', 'किसान के रूप में पंजीकरण करें'), style: Theme.of(context).textTheme.displaySmall),
            SizedBox(height: 6),
            Text(
              AppStrings.t('Connect directly with buyers and get transparent prices for your harvest.', 'खरीदारों से सीधे जुड़ें और अपनी उपज के लिए पारदर्शी मूल्य पाएँ।'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 12),
            ProgressHeader(eyebrow: AppStrings.t('Farm & crop profiling', 'खेत और फसल प्रोफ़ाइल'), step: AppStrings.t('STEP 2 OF 2', 'चरण 2 / 2'), progress: 1),
            SizedBox(height: 14),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: appCardDecoration(color: AppColors.mintTint, borderColor: AppColors.mintTintStrong),
              child: Row(
                children: [
                  Icon(Icons.savings_outlined, color: AppColors.primary, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppStrings.t('Kisan Direct Settlement — Guaranteed 48-hr mandi-linked escrow clearance', 'किसान डायरेक्ट सेटलमेंट — मंडी से जुड़े एस्क्रो का 48 घंटे में सुनिश्चित निपटान'),
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 6),
            FormSectionLabel(number: 1, title: AppStrings.t('Personal Information', 'व्यक्तिगत जानकारी')),
            FieldLabel(AppStrings.t('Full Name (as on Aadhaar / Bank A/c)', 'पूरा नाम (आधार / बैंक खाते के अनुसार)')),
            TextField(controller: _nameCtrl),
            FieldLabel(AppStrings.t('Mobile Number', 'मोबाइल नंबर')),
            TextField(
              controller: _mobileCtrl,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  child: Text('🇮🇳 +91', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                ),
                prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                suffixIcon: Icon(Icons.verified, color: AppColors.success, size: 18),
              ),
            ),
            SizedBox(height: 6),
            FormSectionLabel(number: 2, title: AppStrings.t('Farm Location', 'खेत का स्थान')),
            FieldLabel('State'),
            _Dropdown(value: _state, items: _states, onChanged: (v) => setState(() => _state = v)),
            FieldLabel(AppStrings.t('District', 'ज़िला')),
            _Dropdown(value: _district, items: _districts, onChanged: (v) => setState(() => _district = v)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FieldLabel('Village / Tehsil'),
                      TextField(controller: _villageCtrl),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FieldLabel(AppStrings.t('Pincode', 'पिनकोड')),
                      TextField(controller: _pincodeCtrl, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)]),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            _MapPreview(),
            SizedBox(height: 6),
            FormSectionLabel(number: 3, title: AppStrings.t('Farm & Crop Details', 'खेत और फसल विवरण')),
            FieldLabel(AppStrings.t('Farm Size (Acres)', 'खेत का आकार (एकड़)')),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final size in _allFarmSizes)
                  ChoiceChip(
                    label: Text(size),
                    selected: _farmSize == size,
                    onSelected: (_) => setState(() => _farmSize = size),
                    labelStyle: TextStyle(
                      color: _farmSize == size ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            FieldLabel(AppStrings.t('Primary Produce (Multi-select)', 'मुख्य उपज (एक से अधिक चुनें)')),
            Row(
              children: [
                Text(
                  '${_crops.length} Selected',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final crop in _crops)
                  InputChip(
                    label: Text(crop),
                    onDeleted: () => setState(() => _crops.remove(crop)),
                    backgroundColor: AppColors.mintTint,
                    labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                    deleteIconColor: AppColors.primaryDark,
                    side: BorderSide.none,
                  ),
                ActionChip(
                  label: Text('+ Add Crop'),
                  onPressed: _addCrop,
                  backgroundColor: AppColors.chipUnselected,
                  labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  side: BorderSide.none,
                ),
              ],
            ),
            SizedBox(height: 6),
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: appCardDecoration(),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 340;

                  final details = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.t(
                          'Member of an FPO? (Optional)',
                          'क्या आप FPO के सदस्य हैं? (वैकल्पिक)',
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppStrings.t(
                          'Unlock bulk transport subsidies & collective trading',
                          'थोक परिवहन सब्सिडी और सामूहिक व्यापार का लाभ पाएँ',
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  );

                  final toggle = Switch(
                    value: _fpoMember,
                    onChanged: (v) => setState(() => _fpoMember = v),
                    activeThumbColor: AppColors.primary,
                  );

                  if (compact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        details,
                        Align(
                          alignment: Alignment.centerRight,
                          child: toggle,
                        ),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: details),
                      const SizedBox(width: 8),
                      toggle,
                    ],
                  );
                },
              ),
            ),
            if (_fpoMember) ...[
              FieldLabel(AppStrings.t('Affiliated FPO / Cooperative Society Name', 'संबद्ध FPO / सहकारी समिति का नाम')),
              TextField(
                controller: _fpoCtrl,
                decoration: InputDecoration(prefixIcon: Icon(Icons.groups_outlined, size: 20)),
              ),
            ],
            SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: _agreedToTerms,
                    onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                    activeColor: AppColors.primary,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                      children: [
                        TextSpan(text: AppStrings.t('I agree to ', 'मैं सहमत हूँ ')),
                        TextSpan(
                          text: "NovaKrishi's Fair Trade Terms & Escrow Policy. ",
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                        ),
                        TextSpan(text: AppStrings.t('I confirm the agricultural declarations provided are authentic.', 'मैं पुष्टि करता/करती हूँ कि दी गई कृषि घोषणाएँ सही हैं।')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: !_agreedToTerms || _nameCtrl.text.trim().isEmpty || !RegExp(r'^\d{10}$').hasMatch(_mobileCtrl.text.replaceAll(' ', '')) || !RegExp(r'^\d{6}$').hasMatch(_pincodeCtrl.text.trim())
                  ? null
                  : () => Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => AppShell()),
                        (route) => false,
                      ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppStrings.t('Create Farmer Account', 'किसान खाता बनाएँ')),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
            SizedBox(height: 6),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 360;

                final content = Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.support_agent_outlined,
                        size: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        AppStrings.t(
                          'Need assistance? Toll-free Kisan Helpline: 1800-120-SETU',
                          'सहायता चाहिए? टोल-फ्री किसान हेल्पलाइन: 1800-120-SETU',
                        ),
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppColors.textMuted,
                        ),
                        textAlign: compact ? TextAlign.center : TextAlign.left,
                      ),
                    ),
                  ],
                );

                return Align(
                  alignment: Alignment.center,
                  child: content,
                );
              },
            ),
            SizedBox(height: 16),
            AuthFooter(),
          ],
        ),
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  _Dropdown({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      items: [
        for (final item in items) DropdownMenuItem(value: item, child: Text(item)),
      ],
      onChanged: onChanged,
      icon: Icon(Icons.keyboard_arrow_down, size: 20),
    );
  }
}

/// Lightweight placeholder for the Google-Maps-style farm-location preview —
/// avoids pulling in a maps SDK / API key just to sketch the layout. Swap
/// this for a real `google_maps_flutter` widget in production.
class _MapPreview extends StatelessWidget {
  _MapPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: Color(0xFFE7F0EA),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          CustomPaint(painter: _GridPainter(), size: Size.infinite),
          Center(
            child: Icon(Icons.location_on, color: AppColors.danger, size: 30),
          ),
          Positioned(
            left: 8,
            bottom: 8,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadii.pill),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4)],
              ),
              child: Text(
                '📍 Dindori Mandi Hub (6.2 km)',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  double step = 16.0;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.12)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
