import 'package:flutter/material.dart';
import '../../services/localization.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'otp_verification_screen.dart';
import 'role_selection_screen.dart';
import 'google_sign_in_screen.dart';
import '../../widgets/app_shell.dart';
import '../../services/api_service.dart';
import '../../services/app_state.dart';

enum _SignInMode { mobileOtp, password }

class SignInScreen extends StatefulWidget {
  SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  _SignInMode _mode = _SignInMode.mobileOtp;
  bool _rememberMe = true;
  final _mobileCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();

  @override
  void dispose() {
    _mobileCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _authAppBar(context, title: null),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
            Pill(text: AppStrings.t('Direct Agricultural Marketplace', 'सीधा कृषि बाज़ार'), icon: Icons.eco),
            SizedBox(height: 14),
            Text(AppStrings.t('Welcome Back', 'वापसी पर स्वागत है'), style: Theme.of(context).textTheme.displaySmall),
            SizedBox(height: 6),
            Text(
              AppStrings.t('Sign in to access your direct farm-to-market trade account.', 'अपने सीधे खेत-से-बाज़ार व्यापार खाते तक पहुँचने के लिए साइन इन करें।'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 20),
            _ModeToggle(
              mode: _mode,
              onChanged: (m) => setState(() => _mode = m),
            ),
            SizedBox(height: 16),
            if (_mode == _SignInMode.mobileOtp) ...[
              FieldLabel(AppStrings.t('Mobile Number', 'मोबाइल नंबर')),
              TextFormField(
                controller: _mobileCtrl,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                validator: (value) {
                  final v = (value ?? '').trim();
                  return RegExp(r'^\d{10}$').hasMatch(v) ? null : AppStrings.t('Enter exactly 10 digits', 'ठीक 10 अंक दर्ज करें');
                },
                decoration: InputDecoration(
                  hintText: AppStrings.t('Enter your 10-digit number', 'अपना 10 अंकों का नंबर दर्ज करें'),
                  prefixIcon: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    child: Text('🇮🇳 +91', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                  ),
                  prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                ),
              ),
            ] else ...[
              FieldLabel(AppStrings.t('Mobile Number or Email', 'मोबाइल नंबर या ईमेल')),
              TextFormField(
                controller: _mobileCtrl,
                validator: (value) => (value ?? '').trim().isEmpty ? AppStrings.t('Enter mobile number or email', 'मोबाइल नंबर या ईमेल दर्ज करें') : null,
                decoration: InputDecoration(hintText: AppStrings.t('Enter mobile number or email', 'मोबाइल नंबर या ईमेल दर्ज करें')),
              ),
              FieldLabel(AppStrings.t('Password', 'पासवर्ड')),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: InputDecoration(hintText: AppStrings.t('Enter your password', 'अपना पासवर्ड दर्ज करें')),
              ),
            ],
            SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 360;

                final remember = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (v) => setState(() => _rememberMe = v ?? true),
                        activeColor: AppColors.primary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        AppStrings.t('Remember me', 'मुझे याद रखें'),
                        style: TextStyle(fontSize: 12.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );

                final trouble = TextButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(
                        AppStrings.t('Trouble signing in?', 'साइन इन में समस्या?'),
                      ),
                      content: Text(
                        AppStrings.t(
                          'Use the mobile OTP option and make sure the backend and SMS provider are configured.',
                          'मोबाइल OTP विकल्प का उपयोग करें और सुनिश्चित करें कि बैकएंड और SMS सेवा कॉन्फ़िगर है।',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(AppStrings.t('Close', 'बंद करें')),
                        ),
                      ],
                    ),
                  ),
                  child: Text(
                    AppStrings.t('Trouble signing in?', 'साइन इन में समस्या?'),
                    style: TextStyle(fontSize: 12.5),
                    overflow: TextOverflow.ellipsis,
                  ),
                );

                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      remember,
                      Align(
                        alignment: Alignment.centerRight,
                        child: trouble,
                      ),
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: remember),
                    SizedBox(width: 8),
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: trouble,
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                if (_mode == _SignInMode.mobileOtp) {
                  final mobile = _mobileCtrl.text.trim();
                  try {
                    await _api.sendOtp(mobile);
                    if (!mounted) return;
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => OtpVerificationScreen(mobileNumber: mobile),
                    ));
                  } on ApiException catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                  } catch (_) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Unable to reach NovaKrishi server. Check API_BASE_URL.')),
                    );
                  }
                } else {
                  if (_passwordCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.t('Enter your password', 'अपना पासवर्ड दर्ज करें'))));
                    return;
                  }
                  Navigator.of(context).maybePop();
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_mode == _SignInMode.mobileOtp ? AppStrings.t('Send Verification Code', 'सत्यापन कोड भेजें') : AppStrings.t('Log In', 'लॉग इन करें')),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(AppStrings.t('OR CONTINUE WITH', 'या इसके साथ जारी रखें'), style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                ),
                Expanded(child: Divider()),
              ],
            ),
            SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.t('Biometric sign-in requires a supported Kisan e-Pramaan provider.', 'बायोमेट्रिक साइन-इन के लिए समर्थित किसान ई-प्रमाण सेवा आवश्यक है।')))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fingerprint, size: 18, color: AppColors.primary),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      AppStrings.t('Aadhaar / Kisan e-Pramaan', 'आधार / किसान ई-प्रमाण'),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4),
            Center(
              child: Text(
                AppStrings.t('Direct Mandi biometric sign-in', 'सीधा मंडी बायोमेट्रिक साइन-इन'),
                style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
              ),
            ),
            SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GoogleSignInScreen())),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.g_mobiledata, size: 24, color: AppColors.textSecondary),
                  SizedBox(width: 4),
                  Text(AppStrings.t('Continue with Google', 'Google से जारी रखें')),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account? ", style: TextStyle(fontSize: 12.5)),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => RoleSelectionScreen()),
                  ),
                  child: Text(
                    AppStrings.t('Sign Up', 'साइन अप करें'),
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            AuthFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final _SignInMode mode;
  final ValueChanged<_SignInMode> onChanged;
  _ModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.chipUnselected,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Row(
        children: [
          Expanded(child: _segment(context, AppStrings.t('Mobile OTP', 'मोबाइल OTP'), _SignInMode.mobileOtp, Icons.sms_outlined)),
          Expanded(child: _segment(context, AppStrings.t('Password', 'पासवर्ड'), _SignInMode.password, Icons.lock_outline)),
        ],
      ),
    );
  }

  Widget _segment(BuildContext context, String label, _SignInMode value, IconData icon) {
    final selected = mode == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.sm - 2),
          boxShadow: selected
              ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: Offset(0, 2))]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: selected ? AppColors.primaryDark : AppColors.textMuted),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.primaryDark : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared footer used on every auth screen: escrow / encryption assurance
/// copy plus a help link.
class AuthFooter extends StatelessWidget {
  AuthFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_outlined, size: 13, color: AppColors.textMuted),
            SizedBox(width: 4),
            Flexible(
              child: Text(
                '100% Escrow Protected • Zero Broker Commission',
                style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('256-bit Secure Trade', style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
            SizedBox(width: 12),
            GestureDetector(
              onTap: () {},
              child: Text(
                '?  Help',
                style: TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Shared top app bar used across the auth flow: back arrow, brand mark and
/// small language / profile icon buttons.
PreferredSizeWidget _authAppBar(BuildContext context, {String? title}) {
  return AppBar(
    leading: IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => Navigator.of(context).maybePop(),
    ),
    title: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => AppShell()),
            (route) => false,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              BrandMark(size: 28),
              SizedBox(width: 8),
              Text(title ?? AppStrings.t('NovaKrishi', 'NovaKrishi'), style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ],
    ),
    actions: [
      IconButton(
        onPressed: () => appState.setLanguage(
          appState.isHindi ? AppLanguage.english : AppLanguage.hindi,
        ),
        icon: Icon(Icons.translate, size: 20),
        tooltip: AppStrings.t('English / Hindi', 'अंग्रेज़ी / हिन्दी'),
      ),
      IconButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SignInScreen())), icon: Icon(Icons.person_outline, size: 22)),
      SizedBox(width: 4),
    ],
  );
}

PreferredSizeWidget authAppBar(BuildContext context, {String? title}) => _authAppBar(context, title: title);
