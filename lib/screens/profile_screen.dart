import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../services/app_state.dart';
import '../services/localization.dart';
import '../services/api_service.dart';
import 'auth/sign_in_screen.dart';
import 'order_history_screen.dart';
import 'help_support_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) => Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: BrandWordmark(
                    subtitle: AppStrings.t(
                      'YOUR PROFILE',
                      'आपकी प्रोफ़ाइल',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SettingsScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.settings_outlined),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                appState.isSignedIn
                    ? _signedInCard(context)
                    : _signedOutCard(context),
                const SizedBox(height: 16),
                _ProfileAction(
                  icon: Icons.receipt_long_outlined,
                  title: AppStrings.t(
                    'Order History',
                    'ऑर्डर इतिहास',
                  ),
                  subtitle: AppStrings.t(
                    'Track past and ongoing purchases',
                    'पुराने और चल रहे ऑर्डर ट्रैक करें',
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OrderHistoryScreen(),
                    ),
                  ),
                ),
                _ProfileAction(
                  icon: Icons.support_agent_outlined,
                  title: AppStrings.t(
                    'Help & Support',
                    'सहायता और सपोर्ट',
                  ),
                  subtitle: AppStrings.t(
                    'Get help with orders, payments and account',
                    'ऑर्डर, भुगतान और अकाउंट में सहायता पाएँ',
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => HelpSupportScreen(),
                    ),
                  ),
                ),
                _ProfileAction(
                  icon: Icons.settings_outlined,
                  title: AppStrings.t(
                    'Settings',
                    'सेटिंग्स',
                  ),
                  subtitle: AppStrings.t(
                    'Language, notifications & security',
                    'भाषा, सूचनाएँ और सुरक्षा',
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SettingsScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _signedOutCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: appCardDecoration(),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 32,
            child: Icon(Icons.person, size: 34),
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.t(
              'You are not signed in',
              'आप साइन इन नहीं हैं',
            ),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SignInScreen(),
                ),
              ),
              child: Text(
                AppStrings.t(
                  'Sign In',
                  'साइन इन',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _signedInCard(BuildContext context) {
    final u = appState.user!;
    final name =
        (u['name'] ?? u['displayName'] ?? 'NovaKrishi User').toString();
    final email = (u['email'] ?? '').toString();
    final photo =
        (u['profileImage'] ?? u['photoUrl'] ?? '').toString();

    return _ProfileCard(
      name: name,
      email: email,
      networkPhoto: photo,
    );
  }
}

class _ProfileCard extends StatefulWidget {
  final String name;
  final String email;
  final String networkPhoto;

  const _ProfileCard({
    required this.name,
    required this.email,
    required this.networkPhoto,
  });

  @override
  State<_ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<_ProfileCard> {
  static const String _photoKey = 'novakrishi_profile_photo';

  String? _localPhotoPath;
  bool _loadingPhoto = true;

  @override
  void initState() {
    super.initState();
    _loadSavedPhoto();
  }

  Future<void> _loadSavedPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_photoKey);

    if (!mounted) return;

    setState(() {
      _localPhotoPath = path;
      _loadingPhoto = false;
    });
  }

  Future<void> _changePhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();

      final XFile? picked = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (picked == null) return;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_photoKey, picked.path);

      if (!mounted) return;

      setState(() {
        _localPhotoPath = picked.path;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.t(
              'Profile photo updated',
              'प्रोफ़ाइल फोटो अपडेट हो गई',
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.t(
              'Could not select photo',
              'फोटो चुनने में समस्या हुई',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _removePhoto() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_photoKey);

    if (!mounted) return;

    setState(() {
      _localPhotoPath = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppStrings.t(
            'Profile photo removed',
            'प्रोफ़ाइल फोटो हटा दी गई',
          ),
        ),
      ),
    );
  }

  void _showPhotoOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(
                  AppStrings.t(
                    'Choose from Gallery',
                    'गैलरी से चुनें',
                  ),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _changePhoto(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(
                  AppStrings.t(
                    'Take a Photo',
                    'कैमरा से फोटो लें',
                  ),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _changePhoto(ImageSource.camera);
                },
              ),
              if (_localPhotoPath != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: Text(
                    AppStrings.t(
                      'Remove Profile Photo',
                      'प्रोफ़ाइल फोटो हटाएँ',
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _removePhoto();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _photoWidget({double radius = 46}) {
    if (_localPhotoPath != null &&
        _localPhotoPath!.isNotEmpty &&
        File(_localPhotoPath!).existsSync()) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: FileImage(
          File(_localPhotoPath!),
        ),
      );
    }

    if (widget.networkPhoto.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(widget.networkPhoto),
      );
    }

    return CircleAvatar(
      radius: radius,
      child: Icon(
        Icons.person,
        size: radius * 0.85,
      ),
    );
  }

  void _openFullPhoto() {
    final hasLocalPhoto = _localPhotoPath != null &&
        _localPhotoPath!.isNotEmpty &&
        File(_localPhotoPath!).existsSync();

    final hasNetworkPhoto = widget.networkPhoto.isNotEmpty;

    if (!hasLocalPhoto && !hasNetworkPhoto) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullScreenPhotoViewer(
          localPath: hasLocalPhoto ? _localPhotoPath : null,
          networkUrl: hasNetworkPhoto ? widget.networkPhoto : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: appCardDecoration(),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              GestureDetector(
                onTap: _openFullPhoto,
                child: Hero(
                  tag: 'novakrishi-profile-photo',
                  child: _loadingPhoto
                      ? const CircleAvatar(
                          radius: 46,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : _photoWidget(),
                ),
              ),
              Material(
                color: Theme.of(context).colorScheme.primary,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _showPhotoOptions,
                  child: const Padding(
                    padding: EdgeInsets.all(9),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            widget.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (widget.email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              widget.email,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _showPhotoOptions,
            icon: const Icon(Icons.photo_camera_outlined),
            label: Text(
              AppStrings.t(
                'Change Profile Photo',
                'प्रोफ़ाइल फोटो बदलें',
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () async {
              await ApiService().logout();
              appState.setUser(null);
            },
            icon: const Icon(Icons.logout),
            label: Text(
              AppStrings.t(
                'Sign Out',
                'साइन आउट',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullScreenPhotoViewer extends StatelessWidget {
  final String? localPath;
  final String? networkUrl;

  const _FullScreenPhotoViewer({
    this.localPath,
    this.networkUrl,
  });

  @override
  Widget build(BuildContext context) {
    final bool useLocal =
        localPath != null &&
        localPath!.isNotEmpty &&
        File(localPath!).existsSync();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          AppStrings.t(
            'Profile Photo',
            'प्रोफ़ाइल फोटो',
          ),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 4.0,
          panEnabled: true,
          scaleEnabled: true,
          child: Hero(
            tag: 'novakrishi-profile-photo',
            child: useLocal
                ? Image.file(
                    File(localPath!),
                    fit: BoxFit.contain,
                  )
                : Image.network(
                    networkUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white,
                      size: 80,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _ProfileAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
