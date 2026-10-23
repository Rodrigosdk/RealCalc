import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/themes/extensions/warning_banner_theme.dart';
import 'package:real_calc/core/widgets/warning_banner.dart';

void main() {
  const warningTheme = WarningBannerTheme(
    backgroundColor: Color(0x33224466),
    borderColor: Color(0xFF224466),
    iconColor: Color(0xFFFFAA00),
    textStyle: TextStyle(fontSize: 14, color: Colors.white),
    padding: EdgeInsets.all(16),
    borderRadius: 10,
    iconSize: 20,
    iconTextSpacing: 8,
  );

  Widget buildSut(String message) {
    return MaterialApp(
      theme: ThemeData(extensions: [warningTheme]),
      home: Scaffold(body: WarningBanner(message: message)),
    );
  }

  group('WarningBanner', () {
    testWidgets('mostra a mensagem e o ícone de aviso', (tester) async {
      await tester.pumpWidget(buildSut('Período indisponível'));

      expect(find.text('Período indisponível'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('aplica o tema visual configurado', (tester) async {
      await tester.pumpWidget(buildSut('Aviso de teste'));

      final container = tester.widget<Container>(
        find
            .ancestor(
              of: find.text('Aviso de teste'),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = container.decoration! as BoxDecoration;
      final icon = tester.widget<Icon>(
        find.byIcon(Icons.warning_amber_rounded),
      );
      final text = tester.widget<Text>(find.text('Aviso de teste'));

      expect(container.padding, const EdgeInsets.all(16));
      expect(decoration.color, warningTheme.backgroundColor);
      expect(decoration.borderRadius, BorderRadius.circular(10));
      expect(
        (decoration.border! as Border).top.color,
        warningTheme.borderColor,
      );
      expect(icon.color, warningTheme.iconColor);
      expect(icon.size, 20);
      expect(text.style, warningTheme.textStyle);
    });

    test('WarningBannerTheme suporta copyWith e interpolação', () {
      final copied = warningTheme.copyWith(borderRadius: 14);
      final interpolated = warningTheme.lerp(copied, 0.5);

      expect(copied.borderRadius, 14);
      expect(interpolated.borderRadius, 12);
    });
  });
}
