// ============================================================
// app_navigator.dart
// Clé de navigation globale + ouverture d'un écran depuis une
// notification (appui sur la notification).
// ============================================================
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Cette clé permet de naviguer sans avoir de BuildContext
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Ouvre l'écran correspondant à la valeur "screen" de la notification
// (dans le payload d'une notification locale ou dans les données d'un message FCM).
void openScreen(String? screen) {
  final nav = navigatorKey.currentState;
  if (nav == null || screen == null) return;

  final isLoggedIn = FirebaseAuth.instance.currentUser != null;

  switch (screen) {
    case 'reservation':
    case 'trips':
      // Ouvre l'onglet "Mes voyages" (index 1) de l'espace voyageur
      if (isLoggedIn) {
        nav.pushNamed('/user_dashboard', arguments: 1);
      } else {
        nav.pushNamed('/login');
      }
      break;
    case 'favoris':
    case 'favorites':
      nav.pushNamed('/favorites');
      break;
    case 'currency':
      nav.pushNamed('/currency');
      break;
    default:
      nav.pushNamed('/home');
  }
}
