import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/themes/extensions/menu_card_theme.dart';
import 'package:real_calc/modules/home/domain/enum/menu_card_variant.dart';
import 'package:real_calc/modules/home/presentation/components/menu_card.dart';

void main() {
  const cardColor = Color(0xFF16222F);
  const iconColor = Color(0xFFD4A657);
  const title = 'Financiamento';
  const description = 'Prestações fixas com juros compostos';

  // Valores explícitos usados tanto na construção do tema quanto nas
  // asserções — se o widget mudar esses números no futuro, o teste
  // aponta exatamente qual constante divergiu, em vez de um número cru.
  const double borderRadius = 16;
  const double heightThreshold = 100;
  const double normalIconSize = 24;
  const double compactIconSize = 20;
  const double compactTitleFontSize = 11;
  const double compactDescriptionFontSize = 9;
  const featuredBorderColor = Color(0xFFD4A657);
  const disabledLabelColor = Color(0xFF6C7480);
  const titleStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
  const descriptionStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  const titleStyleCompact = TextStyle(fontSize: 11, fontWeight: FontWeight.w500);
  const descriptionStyleCompact = TextStyle(fontSize: 9, fontWeight: FontWeight.w600);
  const titleStyleFeatured = TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
  const descriptionStyleFeatured = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  const disabledTextStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: disabledLabelColor);


  MenuCardTheme buildTheme() {
    return const MenuCardTheme(
          titleStyle: titleStyle,
          descriptionStyle: descriptionStyle,
          titleStyleCompact: titleStyleCompact,
          descriptionStyleCompact: descriptionStyleCompact,
          titleStyleFeatured: titleStyleFeatured,
          descriptionStyleFeatured: descriptionStyleFeatured,
          featuredBorderColor: featuredBorderColor,
          disabledLabelColor: disabledLabelColor,
          disabledTextStyle: disabledTextStyle,
          borderRadius: borderRadius,
    );
  }

  Widget buildTestableWidget({
    required MenuCardVariant variant,
    double height = 150,
    double width = 150,
    VoidCallback? onTap,
  }) {
    return MaterialApp(
      theme: ThemeData(extensions: [buildTheme()]),
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
            variant: variant,
          ),
        ),
      ),
    );
  }

  group('MenuCard — variante standard', () {
    testWidgets('renderiza textos, ícone e cor de fundo corretamente',
        (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(variant: MenuCardVariant.standard),
      );

      expect(find.text(title), findsOneWidget);
      expect(find.text(description), findsOneWidget);

      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidget.icon, Icons.account_balance);
      expect(iconWidget.color, iconColor);
      expect(iconWidget.size, normalIconSize);

      final container = tester.widget<Container>(
        find.byKey(const Key('menu_card_container')),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, cardColor);
    });

    testWidgets(
        'adapta fontes e ícone quando a altura é menor que heightThreshold',
        (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          variant: MenuCardVariant.standard,
          height: heightThreshold - 20,
          width: 120,
        ),
      );

      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidget.size, compactIconSize);

      final titleText = tester.widget<Text>(find.text(title));
      expect(titleText.style?.fontSize, compactTitleFontSize);

      final descText = tester.widget<Text>(find.text(description));
      expect(descText.style?.fontSize, compactDescriptionFontSize);
    });

    testWidgets('não usa o layout compacto quando a altura é igual ao threshold',
        (tester) async {
      // Fronteira exata: define se a comparação no widget é `<` ou `<=`.
      await tester.pumpWidget(
        buildTestableWidget(
          variant: MenuCardVariant.standard,
          height: heightThreshold,
          width: 120,
        ),
      );

      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidget.size, normalIconSize);
    });

    testWidgets('não sofre overflow em tamanhos pequenos', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          variant: MenuCardVariant.standard,
          height: heightThreshold - 30,
          width: 90,
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('dispara onTap ao ser tocado', (tester) async {
      var foiClicado = false;

      await tester.pumpWidget(
        buildTestableWidget(
          variant: MenuCardVariant.standard,
          onTap: () => foiClicado = true,
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(foiClicado, isTrue);
    });
  });

  group('MenuCard — variante featured', () {
    testWidgets('renderiza em layout horizontal com borda de destaque',
        (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(variant: MenuCardVariant.featured, height: 90),
      );

      expect(find.text(title), findsOneWidget);
      expect(find.text(description), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);

      final container = tester.widget<Container>(
        find.byKey(const Key('menu_card_container')),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isA<Border>());
      final border = decoration.border as Border;
      expect(border.left.color, featuredBorderColor);
    });

    testWidgets('dispara onTap ao ser tocado', (tester) async {
      var foiClicado = false;

      await tester.pumpWidget(
        buildTestableWidget(
          variant: MenuCardVariant.featured,
          height: 90,
          onTap: () => foiClicado = true,
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(foiClicado, isTrue);
    });
  });

  group('MenuCard — variante disabled', () {
    testWidgets('exibe "em breve" e não possui InkWell/onTap',
        (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(variant: MenuCardVariant.disabled, height: 70),
      );

      expect(find.textContaining('em breve'), findsOneWidget);
      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('não dispara nenhuma ação ao ser tocado', (tester) async {
      // Não há callback pra checar (a variante disabled nem aceita onTap),
      // então a asserção é a ausência de exceção e de área tocável.
      await tester.pumpWidget(
        buildTestableWidget(variant: MenuCardVariant.disabled, height: 70),
      );

      await tester.tap(find.byKey(const Key('menu_card_container')));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}