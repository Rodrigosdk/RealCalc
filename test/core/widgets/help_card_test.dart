import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/themes/extensions/help_card_theme.dart';
import 'package:real_calc/core/themes/color_tokens.dart';
import 'package:real_calc/core/themes/text_styles.dart';
import 'package:real_calc/core/widgets/help_card.dart';

void main() {
  group('HelpCard', () {
    const testMessage = 'Esta é uma mensagem de dica ou ajuda importante.';

    Widget createSut() {
      return MaterialApp(
        theme: ThemeData(
          extensions: [
            HelpCardTheme(
              messageStyle: AppTextStyles.helpCardMessage,
              backgroundColor: ColorTokens.surface,
              borderColor: ColorTokens.accentAmber,
              iconBackgroundColor: ColorTokens.surface,
              iconColor: Colors.white,
            ),
          ],
        ),
        home: const Scaffold(
          body: HelpCard(message: testMessage),
        ),
      );
    }

    test('HelpCardTheme deve ter os estilos corretos', () {
      final theme = HelpCardTheme(
        messageStyle: AppTextStyles.helpCardMessage,
        backgroundColor: ColorTokens.surface,
        borderColor: ColorTokens.accentAmber,
        iconBackgroundColor: ColorTokens.accentAmber,
        iconColor: Colors.white,
      );

      expect(theme.messageStyle.color, ColorTokens.textPrimary);
      expect(theme.messageStyle.fontSize, 14);
      expect(theme.messageStyle.fontWeight, FontWeight.w400);
    });

    testWidgets('Deve exibir o texto da mensagem e o ícone de lâmpada', (tester) async {
      await tester.pumpWidget(createSut());

      expect(find.text(testMessage), findsOneWidget);

      final textFinder = find.text(testMessage);
      final RenderParagraph renderObject = tester.renderObject<RenderParagraph>(textFinder);
      final resolvedStyle = renderObject.text.style;

      expect(resolvedStyle?.color, ColorTokens.textPrimary);
      expect(resolvedStyle?.fontSize, 14);
      expect(resolvedStyle?.fontWeight, FontWeight.w400);

      expect(find.byIcon(Icons.lightbulb), findsOneWidget);
    });

    testWidgets('Deve validar a decoração e estilos do container principal', (tester) async {
      await tester.pumpWidget(createSut());

      final containerFinder = find.byType(Container);
      final Container mainContainer = tester.widget(containerFinder.first);
      final mainDecoration = mainContainer.decoration as BoxDecoration?;

      expect(mainDecoration, isNotNull);
      expect(mainDecoration!.color, ColorTokens.surface);
      expect(mainDecoration.borderRadius, BorderRadius.circular(18));

      final border = mainDecoration.border as Border?;
      expect(border, isNotNull);
      expect(border!.top.color, ColorTokens.accentAmber.withValues(alpha: 0.4));
    });

    testWidgets('Deve validar a decoração do container menor que envolve o ícone', (tester) async {
      await tester.pumpWidget(createSut());

      final containerFinder = find.byType(Container);
      final Container iconContainer = tester.widget(containerFinder.at(1));
      final iconDecoration = iconContainer.decoration as BoxDecoration?;

      expect(iconDecoration, isNotNull);
      expect(iconDecoration!.borderRadius, BorderRadius.circular(12));
      expect(iconContainer.constraints?.maxWidth, 40);
      expect(iconContainer.constraints?.maxHeight, 40);
    });
  });
}