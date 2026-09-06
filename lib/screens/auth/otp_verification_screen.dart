import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/localization.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/app_shell.dart';
import 'sign_in_screen.dart';
import '../../services/api_service.dart';
import '../../services/app_state.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String mobileNumber;
  OtpVerificationScreen({super.key, required this.mobileNumber});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const int _codeLength = 6;
  final List<String> _digits = List.filled(_codeLength, '');
  int _secondsLeft = 45;
  Timer? _timer;
  double _gap = 8.0;
  final _api = ApiService();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int get _nextEmptyIndex => _digits.indexOf('');

  void _onKeyTap(String key) {
    setState(() {
      if (key == 'back') {
        for (var i = _codeLength - 1; i >= 0; i--) {
          if (_digits[i].isNotEmpty) {
            _digits[i] = '';
            break;
          }
        }
        return;
      }
      final idx = _nextEmptyIndex;
      if (idx != -1) _digits[idx] = key;
    });
  }

  String get _timerLabel {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  bool get _isComplete => _digits.every((d) => d.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: authAppBar(context),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
          children: [
            ProgressHeader(eyebrow: 'Verify identity', step: AppStrings.t('STEP 2 OF 2', 'चरण 2 / 2'), progress: 1),
            SizedBox(height: 20),
            Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(color: AppColors.mintTint, shape: BoxShape.circle),
                child: Icon(Icons.lock_outline, color: AppColors.primary, size: 28),
              ),
            ),
            SizedBox(height: 14),
            Text(AppStrings.t('Verify Mobile Number', 'मोबाइल नंबर सत्यापित करें'), textAlign: TextAlign.center, style: Theme.of(context).textTheme.displaySmall),
            SizedBox(height: 8),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(text: 'We have sent a 6-digit code via SMS to\n'),
                  TextSpan(
                    text: '+91 ${widget.mobileNumber}  ',
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  TextSpan(
                    text: AppStrings.t('Change', 'बदलें'),
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                    recognizer: null,
                  ),
                ],
              ),
            ),
            SizedBox(height: 22),
            // Overflow fix: 6 boxes x 42px + 5 x 8px gaps needs ~292px, which
            // does not fit inside the padded width of small/older phones
            // (e.g. 320-360dp screens). LayoutBuilder now sizes each box off
            // the real available width instead of a hardcoded value, so the
            // row always fits — it shrinks gracefully on small screens
            // instead of overflowing.
            LayoutBuilder(builder: (context, constraints) {
              _gap = 8.0;
              final totalGap = _gap * (_codeLength - 1);
              final rawBoxSize = (constraints.maxWidth - totalGap) / _codeLength;
              final boxSize = rawBoxSize.clamp(38.0, 48.0);
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _codeLength; i++) ...[
                    _OtpBox(value: _digits[i], active: i == _nextEmptyIndex, size: boxSize),
                    if (i != _codeLength - 1) SizedBox(width: _gap),
                  ],
                ],
              );
            }),
            SizedBox(height: 14),
            Center(
              child: Text(
                _secondsLeft > 0 ? 'Resend code in $_timerLabel' : "Didn't get it?",
                style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
              ),
            ),
            SizedBox(height: 6),
            Center(
              child: TextButton.icon(
                onPressed: _secondsLeft == 0
                    ? () async {
                        try {
                          await _api.sendOtp(widget.mobileNumber.replaceAll(' ', ''));
                          if (!mounted) return;
                          setState(() {
                            _secondsLeft = 45;
                            _digits.fillRange(0, _digits.length, '');
                            _startTimer();
                          });
                       } on ApiException catch (e) {
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                        }
                      }
                    : null,
                icon: Icon(Icons.sms_outlined, size: 15),
                label: Text(AppStrings.t('Resend OTP by SMS', 'SMS से OTP फिर भेजें'), style: TextStyle(fontSize: 12.5)),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: !_isComplete ? null : () async {
                try {
                  final result = await _api.verifyOtp(
  widget.mobileNumber.replaceAll(' ', ''),
  _digits.join(),
);

final user = result['user'];
if (user is Map) {
  appState.setUser(Map<String, dynamic>.from(user));
}

if (!mounted) return;
Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => AppShell()),
                    (route) => false,
                  );
                } on ApiException catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.message)),
                  );
                } catch (_) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Unable to connect to NovaKrishi server. Check your API URL.')),
                  );
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppStrings.t('Verify & Continue', 'सत्यापित करें और जारी रखें')),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
            SizedBox(height: 18),
            _NumericKeypad(onKeyTap: _onKeyTap),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shield_outlined, size: 13, color: AppColors.textMuted),
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    AppStrings.t('Protected by 256-bit bank-grade encryption. Never share your OTP with anyone.', '256-बिट बैंक-स्तरीय एन्क्रिप्शन से सुरक्षित। अपना OTP किसी से साझा न करें।'),
                    style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            AuthFooter(),
          ],
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final String value;
  final bool active;
  final double size;
  _OtpBox({required this.value, required this.active, this.size = 42});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size + 8,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: active ? AppColors.primary : AppColors.border, width: active ? 1.6 : 1),
      ),
      child: value.isEmpty
          ? (active
              ? _BlinkingCursor()
              : SizedBox.shrink())
          : Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  _BlinkingCursor();
  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: Duration(milliseconds: 800))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _c,
      child: Container(width: 2, height: 22, color: AppColors.primary),
    );
  }
}

class _NumericKeypad extends StatelessWidget {
  final ValueChanged<String> onKeyTap;

  const _NumericKeypad({required this.onKeyTap});

  static const List<List<String>> _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['', '0', 'back'],
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        // Keep the keypad compact on narrow screens while still
        // providing comfortable touch targets on larger phones/tablets.
        final keyWidth = ((availableWidth - 32) / 3).clamp(48.0, 72.0);

        // In landscape/short screens, reduce the key height automatically.
        final keyHeight = MediaQuery.sizeOf(context).height < 650 ? 46.0 : 52.0;
        final rowGap = MediaQuery.sizeOf(context).height < 650 ? 5.0 : 8.0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var rowIndex = 0; rowIndex < _rows.length; rowIndex++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: rowIndex == _rows.length - 1 ? 0 : rowGap,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < _rows[rowIndex].length; i++) ...[
                      _KeypadButton(
                        label: _rows[rowIndex][i],
                        onTap: onKeyTap,
                        width: keyWidth,
                        height: keyHeight,
                      ),
                      if (i != _rows[rowIndex].length - 1)
                        SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String label;
  final ValueChanged<String> onTap;
  final double width;
  final double height;

  const _KeypadButton({
    required this.label,
    required this.onTap,
    this.width = 64,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) {
      return SizedBox(width: width, height: height);
    }

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          onTap: () => onTap(label),
          child: Center(
            child: label == 'back'
                ? Icon(
                    Icons.backspace_outlined,
                    size: height < 50 ? 17 : 18,
                    color: AppColors.textSecondary,
                  )
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: height < 50 ? 17 : 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
