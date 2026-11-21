// ============================================================
// main.dart
// Point d'entrée de l'application PackEasy.
// Initialise Firebase, le thème, et configure les routes.
// ============================================================
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'providers/destination_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/trip_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/user_dashboard.dart';
import 'screens/admin_dashboard.dart';
import 'screens/destination_details_screen.dart';
import 'screens/onboarding_screen.dart';
import 'widgets/plane_route.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialisation des dates en français
  await initializeDateFormatting('fr_FR', null);
  
  // Initialisation de Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Chargement du thème sauvegardé AVANT de lancer l'application
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  runApp(
    MultiProvider(
      providers: [
        // Fournit le thème à toute l'application
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => DestinationProvider()),
        ChangeNotifierProvider(create: (_) => TripProvider()),
      ],
      child: const PackEasyApp(),
    ),
  );
}

// Classe pour permettre de scroller à la souris sur le Web/Desktop
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices =>
      {PointerDeviceKind.touch, PointerDeviceKind.mouse};
}

// Widget racine de l'application
class PackEasyApp extends StatelessWidget {
  const PackEasyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // On écoute le ThemeProvider pour changer le thème en temps réel
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'PackEasy',
      debugShowCheckedModeBanner: false,
      scrollBehavior: AppScrollBehavior(),

      // Configuration du thème clair
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),

      // Configuration du thème sombre
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),

      // Application du thème choisi (clair, sombre ou système)
      themeMode: themeProvider.themeMode,

      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/user_dashboard': (context) => const UserDashboard(),
        '/admin_dashboard': (context) => const AdminDashboard(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
      },

      // Route personnalisée avec l'animation de l'avion
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

// Gate d'authentification (conservé pour usage futur)
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return FutureBuilder<String>(
            future: AuthService().getUserRole(snapshot.data!.uid),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              final role = roleSnapshot.data ?? 'user';
              if (role == 'admin') return const AdminDashboard();
              return const UserDashboard();
            },
          );
        }
        return const HomeScreen();
      },
    );
  }
}