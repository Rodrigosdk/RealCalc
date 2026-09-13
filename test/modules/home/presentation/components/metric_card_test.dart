import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/themes/extensions/metric_card_theme.dart';
import 'package:real_calc/modules/home/presentation/components/metric_card.dart';

void main() {
  const positiveColor = Color(0xFF6FCF97);
  const negativeColor = Color(0xFFE24B4A);
  const neutralColor = Color(0xFF8B929C);
  const skeletonColor = Color(0xFF12161D);

  MetricCardTheme buildTheme() {
    return const MetricCardTheme(
      backgroundColor: Color(0xFF0E1116),
      borderColor: Color(0x33D4A657),
      labelStyle: TextStyle(fontSize: 12),
      valueStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
      valueUnitStyle: TextStyle(fontSize: 15),
      captionStyle: TextStyle(fontSize: 11),
      variationTextStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      variationPositiveColor: positiveColor,
      variationNegativeColor: negativeColor,
      variationNeutralColor: neutralColor,
      skeletonColor: skeletonColor,
    );
  }

  Widget wrap(Widget card) {
    return MaterialApp(
      theme: ThemeData(extensions: [buildTheme()]),
      home: Scaffold(body: card),
    );
  }

  group('MetricCard — estado data', () {
    testWidgets('renderiza valor formatado, variação e caption',
        (tester) async {
      await tester.pumpWidget(wrap(const MetricCard.data(
        ratePercent: 10.75,
        variationPercent: 0.25,
        sparklineData: [10.2, 10.4, 10.3, 10.6, 10.75],
        caption: 'Atualizada pelo Banco Central hoje',
      )));

      expect(find.textContaining('10,75'), findsOneWidget);
      expect(find.text('+0,25%'), findsOneWidget);
      expect(
        find.text('Atualizada pelo Banco Central hoje'),
        findsOneWidget,
      );
    });

    testWidgets('usa a cor negativa quando a variação é menor que zero',
        (tester) async {
      await tester.pumpWidget(wrap(const MetricCard.data(
        ratePercent: 10.5,
        variationPercent: -0.5,
        sparklineData: [10.9, 10.8, 10.6, 10.5],
        caption: 'Atualizada pelo Banco Central hoje',
      )));

      final badge = tester.widget<Container>(
        find.byKey(const Key('metric_card_variation_badge')),
      );
      final decoration = badge.decoration as BoxDecoration;
      expect(decoration.color, negativeColor.withValues(alpha: 0.12));
    });

    testWidgets('dispara onTap quando fornecido', (tester) async {
      var foiClicado = false;

      await tester.pumpWidget(wrap(MetricCard.data(
        ratePercent: 10.75,
        variationPercent: 0.25,
        sparklineData: const [10.2, 10.4, 10.6, 10.75],
        caption: 'Atualizada pelo Banco Central hoje',
        onTap: () => foiClicado = true,
      )));

      await tester.tap(find.byKey(const Key('metric_card_container')));
      await tester.pump();

      expect(foiClicado, isTrue);
    });

    testWidgets('não quebra quando a sparkline tem menos de 2 pontos',
        (tester) async {
      await tester.pumpWidget(wrap(const MetricCard.data(
        ratePercent: 10.75,
        variationPercent: 0,
        sparklineData: [10.75],
        caption: 'Atualizada pelo Banco Central hoje',
      )));

      expect(tester.takeException(), isNull);
    });
  });

  group('MetricCard — estado loading', () {
    testWidgets('renderiza sem lançar exceção e sem mostrar valor nenhum',
        (tester) async {
      await tester.pumpWidget(wrap(const MetricCard.loading()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      expect(find.textContaining('%'), findsNothing);

      // Encerra a animação em loop antes do fim do teste, senão o
      // pumpWidget seguinte falha por haver um Timer/Ticker pendente.
      await tester.pump(const Duration(seconds: 1));
    });
  });

  group('MetricCard — estado offline', () {
    testWidgets('com cache disponível, mostra o último valor esmaecido',
        (tester) async {
      await tester.pumpWidget(wrap(const MetricCard.offline(
        ratePercent: 10.75,
        variationPercent: 0.25,
        caption: 'Sem conexão · mostrando último valor salvo',
      )));

      expect(find.textContaining('10,75'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(
        find.text('Sem conexão · mostrando último valor salvo'),
        findsOneWidget,
      );
    });

    testWidgets('sem cache disponível, mostra estado vazio com retry',
        (tester) async {
      var tentouNovamente = false;

      await tester.pumpWidget(wrap(MetricCard.offline(
        caption: 'Não foi possível carregar a ',
        onTap: () => tentouNovamente = true,
      )));

      expect(find.text('Não foi possível carregar a '), findsOneWidget);
      expect(find.text('Toque para tentar novamente'), findsOneWidget);
      expect(find.textContaining('%'), findsNothing);

      await tester.tap(find.byKey(const Key('metric_card_container')));
      await tester.pump();

      expect(tentouNovamente, isTrue);
    });

    testWidgets('sem cache e sem onTap, não mostra "tentar novamente"',
        (tester) async {
      await tester.pumpWidget(wrap(const MetricCard.offline(
        caption: 'Não foi possível carregar a ',
      )));

      expect(find.text('Toque para tentar novamente'), findsNothing);
      expect(find.byType(InkWell), findsNothing);
    });
  });
}