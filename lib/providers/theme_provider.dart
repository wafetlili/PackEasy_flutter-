// ============================================================
// theme_provider.dart
// Gère le thème clair / sombre de l'application.
// Le choix de l'utilisateur est sauvegardé dans la mémoire du
// téléphone pour être conservé à la réouverture de l'application.
// ============================================================
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  // Clé utilisée pour stocker le choix dans SharedPreferences
  static const String _key = 'theme_mode';

  // Par défaut, l'application suit le thème du système
  ThemeMode _themeMode = ThemeMode.system;

  // Getter pour récupérer le thème actuel
  ThemeMode get themeMode => _themeMode;

  // Raccourci pour savoir si l'application est en mode sombre
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // ------------------------------------------------------------
  // Charge le thème sauvegardé au démarrage de l'application
  // ------------------------------------------------------------
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);

    if (stored == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (stored == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }
    // Notifie l'interface que le thème a changé
    notifyListeners();
  }

  // ------------------------------------------------------------
  // Change le thème et le sauvegarde dans la mémoire du téléphone
  // ------------------------------------------------------------
  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    String value = 'system';
    if (mode == ThemeMode.dark) value = 'dark';
    if (mode == ThemeMode.light) value = 'light';
    
    await prefs.setString(_key, value);
  }

  // ------------------------------------------------------------
  // Bascule entre le mode clair et le mode sombre
  // (Utilisé par le bouton dans l'interface)
  // ------------------------------------------------------------
  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setTheme(newMode);
  }
}