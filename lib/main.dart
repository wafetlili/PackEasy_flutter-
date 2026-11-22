// ============================================================
// main.dart
// Point d'entrée de l'application PackEasy.
// Initialise Firebase, les notifications, les publicités, le thème,
// la langue, puis déclare les routes nommées.
// ============================================================
import 'dart:ui' show PointerDeviceKind;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'l10n/generated/app_localizations.dart';
import 'providers/destination_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/trip_provider.dart';
import 'screens/admin_dashboard.dart';
import 'screens/currency_screen.dart';
import 'screens/destination_details_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/user_dashboard.dart';
import 'services/ad_service.dart';
import 'services/notification_service.dart';
import 'utils/app_navigator.dart';
import 'widgets/plane_route.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Formats de dates pour toutes les langues (français, anglais, arabe)
  await initializeDateFormatting();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Publicités (Android et iOS seulement) : on n'attend pas la fin du chargement
  AdService.instance.init();

  // Notifications : un appui sur une notification ouvre l'écran concerné
  final notificationService = NotificationService();
  await notificationService.init(onOpenScreen: openScreen);

  // Quand un utilisateur se connecte, on enregistre le jeton de son appareil
  FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user != null) notificationService.saveTokenForUser(user.uid);
  });

  // Chargement du thème et de la langue enregistrés
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();
  final localeProvider = LocaleProvider();
  await localeProvider.loadLocale();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider(create: (_) => DestinationProvider()),
        ChangeNotifierProvider(create: (_) => TripProvider()),
      ],
      child: const PackEasyApp(),
    ),
  );

  // Demande l'autorisation d'envoyer des notifications (sans bloquer le démarrage)
  notificationService.requestPermission();
}

// Permet de scroller à la souris sur le web et le bureau
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices =>
      {PointerDeviceKind.touch, PointerDeviceKind.mouse};
}

// Widget racine de l'application
class PackEasyApp extends StatefulWidget {
  const PackEasyApp({super.key});

  @override
  State<PackEasyApp> createState() => _PackEasyAppState();
}

class _PackEasyAppState extends State<PackEasyApp> {
  @override
  void initState() {
    super.initState();
    // Si l'application a été ouverte depuis une notification (application fermée),
    // on ouvre l'écran concerné dès que la navigation est prête.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final screen = await NotificationService().getLaunchScreen();
      openScreen(screen);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'PackEasy',
      debugShowCheckedModeBanner: false,
      scrollBehavior: AppScrollBehavior(),

      // Thèmes clair et sombre
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: themeProvider.themeMode,

      // Langue : en arabe, Flutter passe automatiquement en écriture droite -> gauche (RTL)
      locale: localeProvider.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Routes nommées
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/user_dashboard': (context) => const UserDashboard(),
        '/admin_dashboard': (context) => const AdminDashboard(),
        '/favorites': (context) => const FavoritesScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/currency': (context) => const CurrencyScreen(),
      },

      // Route avec animation d'avion : la destination est passée en argument
      onGenerateRoute: (settings) {
        if (settings.name == '/details') {
          return PlaneRoute(
            settings: settings,
            page: const DestinationDetailsScreen(),
          );
        }
        return null;
      },
    );
  }
}
