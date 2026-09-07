import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../screens/auth/sign_in_screen.dart';

enum AppLanguage { english, hindi }

class AppState extends ChangeNotifier {
  AppLanguage _language = AppLanguage.english;
  Map<String, dynamic>? _user;
  KrishiRole _role = KrishiRole.farmer;

  AppLanguage get language => _language;
  bool get isHindi => _language == AppLanguage.hindi;

  Map<String, dynamic>? get user => _user;

  KrishiRole get role => _role;

  bool get isSignedIn => _user != null;


  void setLanguage(AppLanguage value) {
    if (_language == value) return;
    _language = value;
    notifyListeners();
  }


  void setUser(
      Map<String, dynamic>? value, {
        KrishiRole? role,
      }) {
    _user = value;

    if (role != null) {
      _role = role;
    }

    notifyListeners();
  }


  void setRole(KrishiRole value) {
    _role = value;
    notifyListeners();
  }
}


final appState = AppState();