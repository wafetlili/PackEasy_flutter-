// ============================================================
// l10n_ext.dart
// Raccourci : context.l10n au lieu de AppLocalizations.of(context)!
// ============================================================
import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
