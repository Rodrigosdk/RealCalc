import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/themes/color_tokens.dart';
import 'package:real_calc/core/themes/extensions/menu_card_theme.dart';
import 'package:real_calc/core/themes/text_styles.dart';
import 'package:real_calc/modules/home/components/menu_card.dart';

void main() {
  group('MenuCard Widget Tests', () {
    const cardColor = Color(0xFF16222F);
    const iconColor = Color(0xFF1E94F6);
    const title = 'Financiamento';
    const description = 'Prestações fixas com juros compostos';

    Widget buildTestableWidget({
      required double height,
      required double width,
      VoidCallback? onTap,
    }) {
      return MaterialApp(
        theme: ThemeData(
          extensions:  [
            MenuCardTheme(
              titleStyle: AppTextStyles.menuCardTitle,
              descriptionStyle: AppTextStyles.menuCardDescription,
              iconContainerColor: ColorTokens.menuCardIconContainer,
            ),
          ],
        ),
        home: Scaffold(
          body: SizedBox(
            height: height,
            width: width,
            child: MenuCard(
              icon: Icons.account_balance,
              cardColor: cardColor,
              iconColor: iconColor,
              title: title,
              description: description,
              onTap: onTap,
            ),
          ),
        ),
      );
    }

    testWidgets('Deve renderizar textos e cores corretamente no tamanho normal', (tester) async {
      await tester.pumpWidget(buildTestableWidget(height: 150, width: 150));

      expect(find.text(title), findsOneWidget);
      expect(find.text(description), findsOneWidget);

      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidget.icon, Icons.account_balance);
      expect(iconWidget.color, iconColor);
      expect(iconWidget.size, 26);

      final containerFinder = find.byType(Container).first;
      final Container containerWidget = tester.widget(containerFinder);
      final BoxDecoration decoration = containerWidget.decoration as BoxDecoration;
      expect(decoration.color, cardColor);
    });

    testWidgets('Deve adaptar fontes e ícone quando a tela for muito pequena (h < 100)', (tester) async {
      await tester.pumpWidget(buildTestableWidget(height: 80, width: 120));

      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidget.size, 20);

      final titleText = tester.widget<Text>(find.text(title));
      expect(titleText.style?.fontSize, 11);

      final descText = tester.widget<Text>(find.text(description));
      expect(descText.style?.fontSize, 9);
    });

    testWidgets('Não deve overflowar quando o card for pequeno', (tester) async {
      await tester.pumpWidget(buildTestableWidget(height: 100, width: 100));

      expect(tester.takeException(), isNull);
    });

    testWidgets('Deve disparar o callback onTap ao ser clicado', (tester) async {
      bool foiClicado = false;

      await tester.pumpWidget(
        buildTestableWidget(
          height: 150,
          width: 150,
          onTap: () => foiClicado = true,
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(foiClicado, isTrue);
    });

    testWidgets('Não deve quebrar ou disparar erro se o onTap for nulo', (tester) async {
      await tester.pumpWidget(buildTestableWidget(height: 150, width: 150, onTap: null));

      await tester.tap(find.byType(InkWell));
      await tester.pump();
    });
  });
}