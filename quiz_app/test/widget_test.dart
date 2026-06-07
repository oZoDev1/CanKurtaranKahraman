import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cankurtaran_kahraman/app.dart';

void main() {
  testWidgets('Home screen loads and shows start button smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: QuizApp(),
      ),
    );

    // Verify that our start button is displayed.
    expect(find.text("Quiz'e Başla!"), findsOneWidget);
  });
}

