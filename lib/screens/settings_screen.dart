// ============================================================
// settings_screen.dart
// Paramètres : thème clair / sombre, langue (FR / EN / AR),
// notifications et test de notification.
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../services/notification_service.dart';
import '../utils/l10n_ext.dart';
import '../widgets/glass_card.dart';
import '../widgets/travel_background.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _offers = true;

  @override
  void initState() {
    super.initState();
    NotificationService().isOffersEnabled().then((value) {
      if (mounted) setState(() => _offers = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = context.watch<ThemeProvider>();
    final locale = context.watch<LocaleProvider>();

    return TravelBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          title: Text(l.settings),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Apparence : le choix est conservé à la réouverture (SharedPreferences)
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.appearance,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<ThemeMode>(
                          segments: [
                            ButtonSegment(
                                value: ThemeMode.system,
                                icon: const Icon(Icons.phone_android),
                                label: Text(l.themeSystem)),
                            ButtonSegment(
                                value: ThemeMode.light,
                                icon: const Icon(Icons.light_mode),
                                label: Text(l.themeLight)),
                            ButtonSegment(
                                value: ThemeMode.dark,
                                icon: const Icon(Icons.dark_mode),
                                label: Text(l.themeDark)),
                          ],
                          selected: {theme.themeMode},
                          onSelectionChanged: (set) => theme.setTheme(set.first),
                        ),
                      ),
                    ],
                  ),
                ),

                // Langue
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.language,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      RadioGroup<String>(
                        groupValue: locale.locale.languageCode,
                        onChanged: (code) {
                          if (code != null) locale.setLocale(Locale(code));
                        },
                        child: const Column(
                          children: [
                            RadioListTile<String>(value: 'fr', title: Text('Français')),
                            RadioListTile<String>(value: 'en', title: Text('English')),
                            RadioListTile<String>(value: 'ar', title: Text('العربية')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Notifications
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.notifications,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l.offersNotif),
                        value: _offers,
                        onChanged: (value) {
                          setState(() => _offers = value);
                          NotificationService().setOffersEnabled(value);
                        },
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.notifications_active),
                        label: Text(l.testNotification),
                        // Notification locale : un appui ouvre "Mes voyages"
                        onPressed: () => NotificationService().showNotification(
                          title: l.testNotification,
                          body: l.testNotifBody,
                          payload: 'reservation',
                        ),
                      ),
                    ],
                  ),
                ),

                // À propos
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.about,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(l.aboutText),
                      const SizedBox(height: 6),
                      Text('${l.version} 1.0.0'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
