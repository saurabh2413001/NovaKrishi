import 'app_state.dart';

class AppStrings {
  static String t(String en, [String? hi]) =>
      appState.isHindi ? (hi ?? en) : en;
}
