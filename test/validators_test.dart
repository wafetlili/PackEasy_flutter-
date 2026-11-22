// Tests des validateurs de formulaires (messages en français)
import 'package:flutter_test/flutter_test.dart';
import 'package:packeasy/l10n/generated/app_localizations_fr.dart';
import 'package:packeasy/utils/validators.dart';

void main() {
  final l = AppLocalizationsFr();
  final v = Validators(l);

  test('email : valide, vide et invalide', () {
    expect(v.email('test@mail.com'), isNull);
    expect(v.email(''), l.errorRequired);
    expect(v.email('abc'), l.errorEmail);
  });

  test('mot de passe : 6 caractères minimum', () {
    expect(v.password('123456'), isNull);
    expect(v.password('123'), l.errorPassword);
  });

  test('confirmation du mot de passe', () {
    expect(v.confirmPassword('abcdef', 'abcdef'), isNull);
    expect(v.confirmPassword('abcdeg', 'abcdef'), l.errorPasswordMismatch);
  });

  test('nombres positifs', () {
    expect(v.positiveInt('10'), isNull);
    expect(v.positiveInt('0'), l.errorPositive);
    expect(v.positiveNumber('12,5'), isNull);
    expect(v.positiveNumber('abc'), l.errorPositive);
  });

  test('URL facultative', () {
    expect(v.optionalUrl(''), isNull);
    expect(v.optionalUrl('https://site.com/image.jpg'), isNull);
    expect(v.optionalUrl('image.jpg'), l.errorUrl);
  });

  test('dates JJ/MM/AAAA', () {
    expect(v.date('25/12/2026'), isNull);
    expect(v.date('31/02/2026'), l.errorDate);
    expect(v.endDate('01/01/2026', '05/01/2026'), l.errorDateOrder);
    expect(v.endDate('10/01/2026', '05/01/2026'), isNull);
  });
}
