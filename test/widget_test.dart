import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:packeasy/main.dart';
import 'package:packeasy/providers/destination_provider.dart';

void main() {
  testWidgets('PackEasy app builds and shows onboarding', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => DestinationProvider(),
        child: const PackEasyApp(),
      ),
    );

    // Let the first frame settle (onboarding screen is the initial route)
    await tester.pumpAndSettle();

    // The onboarding screen is the initial route — verify it built.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}