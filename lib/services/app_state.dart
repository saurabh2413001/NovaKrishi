import 'package:flutter/foundation.dart';

enum AppLanguage { english, hindi }

class AppState extends ChangeNotifier {
  AppLanguage _language = AppLanguage.english;
  Map<String, dynamic>? _user;

  AppLanguage get language => _language;
  bool get isHindi => _language == AppLanguage.hindi;
  Map<String, dynamic>? get user => _user;
  bool get isSignedIn => _user != null;

  void setLanguage(AppLanguage value) { if (_language == value) return; _language = value; notifyListeners(); }
  void setUser(Map<String, dynamic>? value) { _user = value; notifyListeners(); }
}

final appState = AppState();
