// ============================================================
// ui.dart
// Petites fonctions d'interface réutilisées dans l'application :
// SnackBar, formatage des dates.
// ============================================================
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Affiche un message en bas de l'écran (rouge si c'est une erreur)
void showMessage(
  BuildContext context,
  String text, {
  bool error = false,
  SnackBarAction? action,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(text),
      backgroundColor: error ? Colors.red.shade700 : null,
      action: action,
    ),
  );
}

// Formate une date dans la langue actuelle de l'application
String formatDate(BuildContext context, DateTime date,
    {String pattern = 'd MMM yyyy'}) {
  final lang = Localizations.localeOf(context).languageCode;
  return DateFormat(pattern, lang).format(date);
}
