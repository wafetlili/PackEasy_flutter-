// ============================================================
// labels.dart
// Traduit les valeurs stockées dans Firestore (en français) en
// texte affiché dans la langue choisie, et les erreurs en messages.
// ============================================================
import 'package:firebase_auth/firebase_auth.dart';
import '../l10n/generated/app_localizations.dart';
import '../services/auth_service.dart';

// Continents (valeurs utilisées dans les filtres et dans Firestore)
String continentLabel(AppLocalizations l, String value) {
  switch (value) {
    case 'Tous':
      return l.all;
    case 'Afrique':
      return l.africa;
    case 'Europe':
      return l.europe;
    case 'Asie':
      return l.asia;
    case 'Amérique':
      return l.america;
    case 'Océanie':
      return l.oceania;
    default:
      return value; // continent saisi librement par l'admin
  }
}

// Catégories de destinations
String categoryLabel(AppLocalizations l, String value) {
  switch (value) {
    case 'Tous':
      return l.all;
    case 'Plage':
      return l.beach;
    case 'Culture':
      return l.culture;
    case 'Nature':
      return l.nature;
    case 'Ville':
      return l.city;
    default:
      return value;
  }
}

// Catégories de dépenses (codes stables enregistrés dans Firestore)
String expenseLabel(AppLocalizations l, String code) {
  switch (code) {
    case 'transport':
      return l.catTransport;
    case 'lodging':
      return l.catLodging;
    case 'food':
      return l.catFood;
    case 'activities':
      return l.catActivities;
    default:
      return l.catOther;
  }
}

// Types de programmes (créés par l'admin)
String programTypeLabel(AppLocalizations l, String value) {
  switch (value) {
    case 'Seminaire':
      return l.typeSeminar;
    case 'Voyage de groupe':
      return l.typeGroup;
    case 'Tour d Europe':
      return l.typeEurope;
    case 'Aventure':
      return l.typeAdventure;
    case 'Detente':
      return l.typeRelax;
    default:
      return value;
  }
}

// Valeurs stockées pour les types de programmes
const programTypes = [
  'Seminaire',
  'Voyage de groupe',
  'Tour d Europe',
  'Aventure',
  'Detente',
];

// Transforme une erreur (Firebase ou autre) en message clair pour l'utilisateur
String errorMessage(AppLocalizations l, Object error) {
  if (error is AuthCancelledException) return l.authCancelled;
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'invalid-login-credentials':
        return l.authInvalidCredential;
      case 'user-not-found':
        return l.authUserNotFound;
      case 'invalid-email':
        return l.errorEmail;
      case 'email-already-in-use':
        return l.authEmailInUse;
      case 'weak-password':
        return l.authWeakPassword;
      case 'network-request-failed':
        return l.authNetwork;
      case 'too-many-requests':
        return l.authTooMany;
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
        return l.authCancelled;
      default:
        return l.authUnknown;
    }
  }
  final text = error.toString().toLowerCase();
  if (text.contains('timeout') ||
      text.contains('unavailable') ||
      text.contains('socket')) {
    return l.errorNetwork;
  }
  return l.errorGeneric;
}
