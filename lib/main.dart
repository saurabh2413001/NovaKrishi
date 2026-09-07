import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/auth/sign_in_screen.dart';
import 'services/app_state.dart';

void main() {
  runApp(const NovaKrishiApp());
}

class NovaKrishiApp extends StatelessWidget {
  const NovaKrishiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) => MaterialApp(
      title: 'NovaKrishi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Overflow fix (root cause on many phones): some Android devices ship
      // with system font scale set as high as 130-200% (Settings > Display >
      // Font size), and our fixed-height rows/buttons were sized assuming
      // ~100%. Clamping the scale here means every screen in the app gets a
      // guaranteed safe range instead of us having to guard every Text widget
      // individually. This does NOT stop the user changing their setting —
      // it just stops the *app* from reflowing itself into an overflow.
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final clampedScaler = mediaQuery.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.25);
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: clampedScaler),
          child: child!,
        );
      },
        home: SignInScreen(),
      ),
    );
  }
}
