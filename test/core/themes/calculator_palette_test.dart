import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/themes/calculator_palette.dart';
import 'package:real_calc/core/themes/calculator_scope.dart';

void main() {
  group('CalculatorPalette', () {
    test('defines the expected colors for light and dark themes', () {
      const expected = {
        CalculatorKind.financing: (0xFF364FC7, 0xFF364FC7, 0xFF91A7FF),
        CalculatorKind.deposits: (0xFF087F5B, 0xFF0A6E50, 0xFF63E6BE),
        CalculatorKind.futureValue: (0xFF6741D9, 0xFF6741D9, 0xFFB197FC),
        CalculatorKind.correction: (0xFFB85300, 0xFFA04600, 0xFFFFA94D),
      };

      for (final entry in expected.entries) {
        final light = CalculatorPalette.of(
          entry.key,
          brightness: Brightness.light,
        );
        final dark = CalculatorPalette.of(
          entry.key,
          brightness: Brightness.dark,
        );
        expect(light.solid.toARGB32(), entry.value.$1);
        expect(light.text.toARGB32(), entry.value.$2);
        expect(dark.solid, light.solid);
        expect(dark.text.toARGB32(), entry.value.$3);
        expect(light.onSolid, Colors.white);
        expect(dark.onSolid, Colors.white);
      }
    });

    test('compares palettes by value', () {
      expect(
        CalculatorPalette.of(CalculatorKind.deposits),
        CalculatorPalette.of(CalculatorKind.deposits),
      );
      expect(
        CalculatorPalette.of(CalculatorKind.deposits).hashCode,
        CalculatorPalette.of(CalculatorKind.deposits).hashCode,
      );
      expect(
        CalculatorPalette.of(CalculatorKind.deposits),
        isNot(
          CalculatorPalette.of(
            CalculatorKind.deposits,
            brightness: Brightness.dark,
          ),
        ),
      );
    });

    test('white text has at least 4.5:1 contrast on every solid color', () {
      for (final kind in CalculatorKind.values) {
        final palette = CalculatorPalette.of(kind);
        expect(
          (palette.onSolid.computeLuminance() + 0.05) /
              (palette.solid.computeLuminance() + 0.05),
          greaterThanOrEqualTo(4.5),
          reason: '$kind must meet WCAG AA contrast',
        );
      }
    });
  });

  testWidgets('correction scope applies its solid color to the text cursor', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: const CalculatorScope(
          kind: CalculatorKind.correction,
          child: Scaffold(body: TextField()),
        ),
      ),
    );

    final editableText = tester.widget<EditableText>(find.byType(EditableText));
    expect(editableText.cursorColor, const Color(0xFFB85300));
    expect(
      CalculatorScope.of(tester.element(find.byType(TextField))).text,
      const Color(0xFFA04600),
    );
  });
}
