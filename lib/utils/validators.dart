// ============================================================
// validators.dart
// Validateurs des formulaires (TextFormField).
// Chaque validateur renvoie null si la valeur est correcte,
// sinon le message d'erreur (traduit) à afficher sous le champ.
// ============================================================
import '../l10n/generated/app_localizations.dart';

class Validators {
  final AppLocalizations l;
  const Validators(this.l);

  // Champ obligatoire
  String? required(String? v) {
    if (v == null || v.trim().isEmpty) return l.errorRequired;
    return null;
  }

  // Nombre de caractères minimum
  String? minLength(String? v, int min) {
    if (v == null || v.trim().isEmpty) return l.errorRequired;
    if (v.trim().length < min) return l.errorMinLength(min);
    return null;
  }

  // Adresse email valide
  String? email(String? v) {
    if (v == null || v.trim().isEmpty) return l.errorRequired;
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(v.trim())) return l.errorEmail;
    return null;
  }

  // Mot de passe : 6 caractères minimum
  String? password(String? v) {
    if (v == null || v.isEmpty) return l.errorRequired;
    if (v.length < 6) return l.errorPassword;
    return null;
  }

  // Confirmation du mot de passe : doit être identique à l'original
  String? confirmPassword(String? v, String original) {
    if (v == null || v.isEmpty) return l.errorRequired;
    if (v != original) return l.errorPasswordMismatch;
    return null;
  }

  // Nombre entier strictement positif (obligatoire)
  String? positiveInt(String? v, {String? message}) {
    final n = int.tryParse((v ?? '').trim());
    if (n == null || n <= 0) return message ?? l.errorPositive;
    return null;
  }

  // Nombre décimal strictement positif (la virgule est acceptée)
  String? positiveNumber(String? v, {String? message}) {
    final n = double.tryParse((v ?? '').trim().replaceAll(',', '.'));
    if (n == null || n <= 0) return message ?? l.errorPositive;
    return null;
  }

  // URL d'image (facultative) : si elle est remplie, elle doit être valide
  String? optionalUrl(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final uri = Uri.tryParse(v.trim());
    final ok = uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    return ok ? null : l.errorUrl;
  }

  // Date au format JJ/MM/AAAA
  String? date(String? v) {
    if (v == null || v.trim().isEmpty) return l.errorRequired;
    return parseDate(v) == null ? l.errorDate : null;
  }

  // Date de fin : valide et après la date de début
  String? endDate(String? v, String start) {
    final basic = date(v);
    if (basic != null) return basic;
    final s = parseDate(start);
    final e = parseDate(v!);
    if (s != null && e != null && e.isBefore(s)) return l.errorDateOrder;
    return null;
  }
}

// Transforme "25/12/2026" en DateTime (null si le format est faux)
DateTime? parseDate(String text) {
  final parts = text.trim().split('/');
  if (parts.length != 3) return null;
  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) return null;
  if (year < 1900 || month < 1 || month > 12 || day < 1 || day > 31) return null;
  final result = DateTime(year, month, day);
  // Refuse les dates impossibles (ex : 31/02/2026)
  if (result.day != day || result.month != month) return null;
  return result;
}
