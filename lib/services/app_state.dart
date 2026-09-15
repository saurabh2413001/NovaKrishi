import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import 'api_service.dart';

enum AppLanguage { english, hindi }

class AppState extends ChangeNotifier {
  static const String _userKey = 'novakrishi_session_user';
  static const String _tokenKey = 'novakrishi_session_token';
  static const String _roleKey = 'novakrishi_session_role';
  static const String _languageKey = 'novakrishi_language';

  AppLanguage _language = AppLanguage.english;
  Map<String, dynamic>? _user;
  KrishiRole _role = KrishiRole.farmer;

  AppLanguage get language => _language;
  bool get isHindi => _language == AppLanguage.hindi;

  Map<String, dynamic>? get user => _user;

  KrishiRole get role => _role;

  bool get isSignedIn => _user != null;

  /// Restores the previous login session when the app starts.
  Future<void> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedToken = prefs.getString(_tokenKey);
      final savedUser = prefs.getString(_userKey);
      final savedRole = prefs.getString(_roleKey);
      final savedLanguage = prefs.getString(_languageKey);

      if (savedLanguage == AppLanguage.hindi.name) {
        _language = AppLanguage.hindi;
      } else {
        _language = AppLanguage.english;
      }

      if (savedRole != null) {
        _role = KrishiRole.values.firstWhere(
          (value) => value.name == savedRole,
          orElse: () => KrishiRole.farmer,
        );
      }

      if (savedToken != null && savedToken.isNotEmpty) {
        ApiService.setToken(savedToken);
      }

      if (savedUser != null && savedUser.isNotEmpty) {
        final decoded = jsonDecode(savedUser);

        if (decoded is Map) {
          _user = Map<String, dynamic>.from(decoded);
        }
      }

      notifyListeners();
    } catch (error) {
      debugPrint('NOVAKRISHI SESSION RESTORE ERROR: $error');

      // If stored session data is corrupted, clear only the bad session.
      await clearSession();
    }
  }

  Future<void> _saveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = ApiService.token;

      if (token != null && token.isNotEmpty && _user != null) {
        await prefs.setString(_tokenKey, token);
        await prefs.setString(
          _userKey,
          jsonEncode(_user),
        );
        await prefs.setString(
          _roleKey,
          _role.name,
        );
      }
    } catch (error) {
      debugPrint('NOVAKRISHI SESSION SAVE ERROR: $error');
    }
  }

  Future<void> setLanguage(AppLanguage value) async {
    if (_language == value) return;

    _language = value;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _languageKey,
        value.name,
      );
    } catch (error) {
      debugPrint('NOVAKRISHI LANGUAGE SAVE ERROR: $error');
    }

    notifyListeners();
  }

  Future<void> setUser(
    Map<String, dynamic>? value, {
    KrishiRole? role,
  }) async {
    _user = value;

    if (role != null) {
      _role = role;
    }

    if (value == null) {
      await clearSession();
      return;
    }

    await _saveSession();
    notifyListeners();
  }

  Future<void> setRole(KrishiRole value) async {
    _role = value;

    if (_user != null) {
      await _saveSession();
    }

    notifyListeners();
  }

  Future<void> clearSession() async {
    _user = null;
    ApiService.setToken(null);

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      await prefs.remove(_roleKey);
    } catch (error) {
      debugPrint('NOVAKRISHI SESSION CLEAR ERROR: $error');
    }

    notifyListeners();
  }
}

final appState = AppState();
