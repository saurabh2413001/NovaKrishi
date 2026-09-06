import 'dart:io';
import 'package:flutter/material.dart';
import '../services/localization.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../services/api_service.dart';

/// AppStrings.t("Scan Crop", "फसल स्कैन करें") screen: lets a farmer take (or pick) a photo of a crop and
/// submit it for analysis (e.g. disease/pest detection, quality grading).
///
/// TODO BACKEND API: wire ApiService.analyzeCropPhoto to your real endpoint,
/// e.g. POST /ai/crop-scan (multipart/form-data with the image file), and
/// render the returned diagnosis/insight below the preview instead of the
/// placeholder result card.
class CropPhotoScreen extends StatefulWidget {
  CropPhotoScreen({super.key});

  @override
  State<CropPhotoScreen> createState() => _CropPhotoScreenState();
}

class _CropPhotoScreenState extends State<CropPhotoScreen> {
  final _picker = ImagePicker();
  final _api = ApiService();

  XFile? _photo;
  bool _submitting = false;
  Map<String, dynamic>? _result;
  String? _error;

  Future<void> _capture(ImageSource source) async {
    setState(() => _error = null);
    try {
      final shot = await _picker.pickImage(
        source: source,
        maxWidth: 2000,
        imageQuality: 85,
      );
      if (shot == null) return; // user cancelled
      setState(() {
        _photo = shot;
        _result = null;
      });
    } catch (e) {
      // Common causes: camera/gallery permission denied, or no camera on
      // this device/emulator. Surface a friendly message instead of crashing.
      setState(() => _error = AppStrings.t('Could not open ${source == ImageSource.camera ? 'camera' : 'gallery'}. Please check app permissions in device Settings and try again.', 'कैमरा या गैलरी नहीं खुल सकी। कृपया डिवाइस सेटिंग्स में ऐप अनुमतियाँ जाँचें और फिर प्रयास करें।'));
    }
  }

  Future<void> _submit() async {
    final photo = _photo;
    if (photo == null) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final result = await _api.analyzeCropPhoto(File(photo.path));
      if (!mounted) return;
      setState(() => _result = result ?? {'status': 'queued'});
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Upload failed. Check your connection and try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _retake() => setState(() {
        _photo = null;
        _result = null;
        _error = null;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_photo == null ? AppStrings.t('Scan a Crop Photo', 'फसल की फ़ोटो स्कैन करें') : AppStrings.t('Review Photo', 'फ़ोटो की समीक्षा करें'))),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_photo == null) ..._buildCaptureChoice(context) else ..._buildPreview(context),
                  if (_error != null) ...[
                    SizedBox(height: 14),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFFFCEAEA),
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: AppColors.danger, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(_error!, style: TextStyle(color: AppColors.danger, fontSize: 12.5)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  List<Widget> _buildCaptureChoice(BuildContext context) {
    return [
      SizedBox(height: 8),
      EyebrowLabel(text: AppStrings.t('AI Crop Scan', 'AI फसल स्कैन'), icon: Icons.camera_alt_outlined),
      SizedBox(height: 8),
      Text(AppStrings.t('Photograph your crop', 'अपनी फसल की फ़ोटो लें'), style: Theme.of(context).textTheme.displaySmall),
      SizedBox(height: 8),
      Text(
        'Take a clear, well-lit photo of the leaf, fruit or affected area so '
        'we can check for disease, pests or quality issues.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      SizedBox(height: 24),
      AspectRatio(
        aspectRatio: 4 / 3,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.mintTint,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Center(
            child: Icon(Icons.eco_outlined, size: 56, color: AppColors.primary),
          ),
        ),
      ),
      SizedBox(height: 24),
      ElevatedButton.icon(
        onPressed: () => _capture(ImageSource.camera),
        icon: Icon(Icons.camera_alt_outlined),
        label: Text('Take Photo'),
      ),
      SizedBox(height: 10),
      OutlinedButton.icon(
        onPressed: () => _capture(ImageSource.gallery),
        icon: Icon(Icons.photo_library_outlined),
        label: Text(AppStrings.t('Choose from Gallery', 'गैलरी से चुनें')),
      ),
    ];
  }

  List<Widget> _buildPreview(BuildContext context) {
    return [
      ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Image.file(File(_photo!.path), fit: BoxFit.cover),
        ),
      ),
      SizedBox(height: 16),
      if (_result == null) ...[
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _submitting ? null : _retake,
                icon: Icon(Icons.refresh, size: 18),
                label: Text(AppStrings.t('Retake', 'दोबारा लें')),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? SizedBox(
                        width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Icon(Icons.upload_outlined, size: 18),
                label: Text(_submitting ? AppStrings.t('Analyzing…', 'विश्लेषण हो रहा है…') : AppStrings.t('Analyze Photo', 'फ़ोटो का विश्लेषण करें')),
              ),
            ),
          ],
        ),
      ] else ...[
        Container(
          padding: EdgeInsets.all(16),
          decoration: appCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(AppStrings.t('Photo submitted', 'फ़ोटो भेज दी गई'), style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Text(
                // TODO BACKEND API: replace with the real diagnosis text from
                // your analysis endpoint's response payload.
                'Your crop photo has been queued for AI analysis. Results will '
                'appear in AI Insights shortly.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _retake,
          icon: Icon(Icons.camera_alt_outlined, size: 18),
          label: Text('Scan Another'),
        ),
      ],
    ];
  }
}
