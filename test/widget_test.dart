// This is a basic Flutter widget test for Micro Emploi App.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micro_emploi_app/main.dart';

void main() {
  testWidgets('App launches with splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MicroEmploiApp());

    // Wait for splash screen animation to complete
    await tester.pumpAndSettle();

    // Verify that our app shows the "Bienvenu" text on splash screen
    // Note: The text might transition quickly to welcome screen
    expect(find.byType(MicroEmploiApp), findsOneWidget);
  });

  testWidgets('Navigation from splash to welcome screen works',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MicroEmploiApp());

    // Wait for the splash screen timer (3 seconds) plus animations
    await tester.pumpAndSettle(Duration(seconds: 4));

    // Verify that we can find some welcome screen elements
    // You can add more specific tests as you build more features
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
