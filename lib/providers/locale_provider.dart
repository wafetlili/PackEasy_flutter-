// ============================================================
// locale_provider.dart
// Gère la langue de l'application et sa persistance.
// ============================================================
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _key = 'locale_code';

  // Par défaut : français
  Locale _locale = const Locale('fr');

  Locale get locale => _locale;

  // Charge la langue sauvegardée au démarrage
  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  // Change la langue et la sauvegarde
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }
}