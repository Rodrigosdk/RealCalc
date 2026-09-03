import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/themes/color_tokens.dart';
import 'package:real_calc/core/themes/extensions/highlight_card_theme.dart';
import 'package:real_calc/core/themes/text_styles.dart';
import 'package:real_calc/modules/home/components/highlight_card.dart';

void main() {
  group('HighlightCard Widget Tests', () {
    Widget buildTestableWidget({VoidCallback? onTap}) {
      return MaterialApp(
        theme: ThemeData(
          extensions:  [
            HighlightCardTheme(
              gradientColors: [
                ColorTokens.surface,
                ColorTokens.accentAmber.withValues(alpha: 0.32),
              ],
              titleStyle: AppTextStyles.menuCardTitleFeatured,
              subtitleStyle: AppTextStyles.menuCardDescriptionFeatured,
              buttonBackgroundColor: Colors.white,
              buttonForegroundColor: Colors.white,
              buttonTextStyle: AppTextStyles.menuCardDescriptionFeatured,
            ),
          ],
        ),
        home: Scaffold(
          body: HighlightCard(onTap: onTap),
        ),
      );
    }

    testWidgets('Deve renderizar todos os textos corretamente', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('Selic e Índices'), findsOneWidget);
      expect(
        find.text('Acompanhe as taxas oficiais atualizadas diariamente pelo Banco Central.'),
        findsOneWidget,
      );
      expect(find.text('CONSULTAR TAXAS'), findsOneWidget);
    });

    testWidgets('Deve conter as decorações visuais corretas (Container e Gradiente)', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      final containerFinder = find.byType(Container);
      final Container containerWidget = tester.widget(containerFinder);
      final BoxDecoration decoration = containerWidget.decoration as BoxDecoration;

      expect(decoration.borderRadius, BorderRadius.circular(20));

      final LinearGradient gradient = decoration.gradient as LinearGradient;

      expect(gradient.colors.length, greaterThanOrEqualTo(2));
      expect(gradient.colors.first, ColorTokens.surface);
      expect(gradient.colors.last, ColorTokens.accentAmber.withValues(alpha: 0.32));
      expect(gradient.begin, Alignment.topLeft);
      expect(gradient.end, Alignment.bottomRight);
    });

    testWidgets('Deve aplicar a tipografia e cores corretas aos textos', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      final titleText = tester.widget<Text>(find.text('Selic e Índices'));
      expect(titleText.style, AppTextStyles.menuCardTitleFeatured);

      final descText = tester.widget<Text>(
        find.text('Acompanhe as taxas oficiais atualizadas diariamente pelo Banco Central.'),
      );
      expect(descText.style?.fontSize, AppTextStyles.menuCardDescriptionFeatured.fontSize);
      expect(descText.style?.fontWeight, AppTextStyles.menuCardDescriptionFeatured.fontWeight);
      expect(
        descText.style?.color,
        AppTextStyles.menuCardDescriptionFeatured.color?.withValues(alpha: 0.8),
      );
    });

    testWidgets('Deve conter o botão com o estilo correto e permitir clique', (tester) async {
      bool wasTapped = false;
      await tester.pumpWidget(buildTestableWidget(onTap: () => wasTapped = true));

      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsOneWidget);

      final ElevatedButton buttonWidget = tester.widget(buttonFinder);
      final ButtonStyle? buttonStyle = buttonWidget.style;

      expect(
        buttonStyle?.backgroundColor?.resolve({}),
        Colors.white.withValues(alpha: 0.2),
      );
      expect(
        buttonStyle?.foregroundColor?.resolve({}),
        Colors.white,
      );
      expect(buttonStyle?.elevation?.resolve({}), 0);

      await tester.tap(buttonFinder);
      await tester.pump();

      expect(wasTapped, true);
    });
  });
}