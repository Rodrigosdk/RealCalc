import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/themes/extensions/help_card_theme.dart';
import 'package:real_calc/core/themes/color_tokens.dart';
import 'package:real_calc/core/themes/text_styles.dart';
import 'package:real_calc/modules/financing/presentation/widgets/help_card.dart';

void main() {
  group('HelpCard', () {
    const testMessage = 'Esta é uma mensagem de dica ou ajuda importante.';

    Widget createSut() {
      return MaterialApp(
        theme: ThemeData(
          extensions: const [
            HelpCardTheme(
              messageStyle: AppTextStyles.helpCardMessage,
              backgroundColor: ColorTokens.helpCardBackground,
              borderColor: ColorTokens.helpCardBorder,
              iconBackgroundColor: ColorTokens.helpCardIconBackground,
              iconColor: ColorTokens.helpCardIcon,
            ),
          ],
        ),
        home: const Scaffold(
          body: HelpCard(menssage: testMessage),
        ),
      );
    }

    testWidgets('Deve exibir o texto da mensagem e o ícone de lâmpada', (tester) async {
      await tester.pumpWidget(createSut());

      final textFinder = find.text(testMessage);
      expect(textFinder, findsOneWidget);

      final Text textWidget = tester.widget(textFinder);
      expect(textWidget.style?.color, ColorTokens.textPrimary);
      expect(textWidget.style?.fontSize, 14);
      expect(textWidget.style?.fontWeight, FontWeight.w400);

      expect(find.byIcon(Icons.lightbulb), findsOneWidget);
    });

    testWidgets('Deve validar a decoração e estilos do container principal', (tester) async {
      await tester.pumpWidget(createSut());

      final containerFinder = find.byType(Container);
      final Container mainContainer = tester.widget(containerFinder.first);
      final mainDecoration = mainContainer.decoration as BoxDecoration?;

      expect(mainDecoration, isNotNull);
      expect(mainDecoration!.color, ColorTokens.helpCardBackground);
      expect(mainDecoration.borderRadius, BorderRadius.circular(18));

      final border = mainDecoration.border as Border?;
      expect(border, isNotNull);
      expect(border!.top.color, ColorTokens.helpCardBorder.withValues(alpha: 0.4));
    });

    testWidgets('Deve validar a decoração do container menor que envolve o ícone', (tester) async {
      await tester.pumpWidget(createSut());

      final containerFinder = find.byType(Container);
      final Container iconContainer = tester.widget(containerFinder.at(1));
      final iconDecoration = iconContainer.decoration as BoxDecoration?;

      expect(iconDecoration, isNotNull);
      expect(iconDecoration!.color, ColorTokens.helpCardIconBackground);
      expect(iconDecoration.borderRadius, BorderRadius.circular(12));
      expect(iconContainer.constraints?.maxWidth, 40);
      expect(iconContainer.constraints?.maxHeight, 40);
    });
  });
}