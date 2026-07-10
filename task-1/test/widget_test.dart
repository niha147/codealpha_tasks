import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flashmaster/widgets/flip_card.dart';

void main() {
  testWidgets('FlipCardWidget shows front initially and back when flipped', (WidgetTester tester) async {
    const frontText = 'Front Side';
    const backText = 'Back Side';

    // Test initially not flipped
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FlipCardWidget(
            front: Text(frontText),
            back: Text(backText),
            isFlipped: false,
          ),
        ),
      ),
    );

    expect(find.text(frontText), findsOneWidget);

    // Now test flipped state. Because the TweenAnimationBuilder takes 500ms, 
    // we need to wait for it.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FlipCardWidget(
            front: Text(frontText),
            back: Text(backText),
            isFlipped: true,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(backText), findsOneWidget);
  });
}
