// ============================================================
// auth_scaffold.dart
// Cadre commun des écrans de connexion, d'inscription et de
// mot de passe oublié : fond animé + carte centrale.
// Les couleurs viennent du thème (lisible en clair et en sombre).
// ============================================================
import 'package:flutter/material.dart';
import 'travel_background.dart';

class AuthScaffold extends StatelessWidget {
  final String title;
  final Widget child;

  const AuthScaffold({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return TravelBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: scheme.surface.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 30, spreadRadius: 2),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

// Style commun des champs de saisie des écrans d'authentification
InputDecoration authInputStyle(BuildContext context, String label, IconData icon) {
  final scheme = Theme.of(context).colorScheme;
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 20),
    filled: true,
    fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  );
}
