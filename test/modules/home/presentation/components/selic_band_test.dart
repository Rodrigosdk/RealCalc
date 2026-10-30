import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/core/themes/app_theme.dart';
import 'package:real_calc/modules/home/presentation/components/selic_band.dart';
import 'package:real_calc/modules/home/presentation/components/sparkline_painter.dart';
import 'package:real_calc/modules/home/presentation/cubit/selic_cubit.dart';
import 'package:real_calc/modules/metrics/domain/entites/metric.dart';
import 'package:real_calc/modules/metrics/domain/enum/selic_period.dart';

final today = DateTime(2026, 11, 3);

Metric fakeMetric({double variation = 0.25}) {
  final dates = [
    for (var i = 60; i >= 0; i--) DateTime(today.year, today.month - i, 3),
  ];
  return Metric(
    anualRate: 13.75,
    variationPercent: variation,
    sparklineData: [for (var i = 0; i < dates.length; i++) 10 + i / 10],
    sparklineDates: dates,
    lastDate: today,
  );
}

void main() {
  late int retries;
  late List<SelicPeriod> periods;

  setUp(() {
    retries = 0;
    periods = [];
  });

  Future<void> pump(
    WidgetTester tester,
    SelicState state, {
    double width = 400,
    double textScale = 1,
    bool disableAnimations = false,
    DateTime? now,
  }) async {
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(width, 800),
            textScaler: TextScaler.linear(textScale),
            disableAnimations: disableAnimations,
          ),
          child: Scaffold(
            backgroundColor: const Color(0xFF221F2E),
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: SelicBand(
                state: state,
                onRetry: () => retries++,
                onPeriodChanged: periods.add,
                now: () => now ?? today,
              ),
            ),
          ),
        ),
      ),
    );
  }

  SparklinePainter painter(WidgetTester tester) =>
      tester
              .widget<CustomPaint>(
                find.descendant(
                  of: find.byType(SelicBand),
                  matching: find.byType(CustomPaint),
                ),
              )
              .painter!
          as SparklinePainter;

  group('SelicBand', () {
    testWidgets('com dados: taxa, variação, gráfico e fonte', (tester) async {
      await pump(tester, SelicLoaded(fakeMetric()));

      expect(find.text('Taxa Selic hoje'), findsOneWidget);
      expect(find.text('13,75%'), findsOneWidget);
      expect(find.text('ao ano'), findsOneWidget);
      expect(find.text('0,25 ponto em relação à anterior'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
      expect(
        find.text('Fonte: Banco Central, atualizada hoje.'),
        findsOneWidget,
      );
      expect(painter(tester).strokeWidth, 1.75);
      expect(painter(tester).color, Colors.white);
      expect(
        tester.getSize(find.byType(CustomPaint).last).height,
        SelicBand.chartHeight,
      );
    });

    testWidgets('queda mostra a seta para baixo', (tester) async {
      await pump(tester, SelicLoaded(fakeMetric(variation: -0.5)));

      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
      expect(find.text('0,50 ponto em relação à anterior'), findsOneWidget);
    });

    testWidgets('fonte mostra a data quando não é de hoje', (tester) async {
      await pump(tester, SelicLoaded(fakeMetric()), now: DateTime(2026, 11, 5));

      expect(
        find.text('Fonte: Banco Central, atualizada em 03/11.'),
        findsOneWidget,
      );
    });

    testWidgets('a fonte usa a data em que o valor foi salvo', (tester) async {
      await pump(
        tester,
        SelicLoaded(fakeMetric().copyWith(updatedAt: DateTime(2026, 10, 21))),
      );

      expect(
        find.text('Fonte: Banco Central, atualizada em 21/10.'),
        findsOneWidget,
      );
    });

    testWidgets('tocar no período avisa quem controla a faixa', (tester) async {
      await pump(tester, SelicLoaded(fakeMetric()));

      expect(
        find.bySemanticsLabel(
          'Gráfico da Selic nos últimos 12 meses, valor atual 13,75% ao ano',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('5 anos'));
      expect(periods, [SelicPeriod.years5]);
    });

    testWidgets('desenha a série do período recebido', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, SelicLoaded(fakeMetric(), SelicPeriod.years5));

      expect(painter(tester).data, hasLength(61));
      expect(
        find.bySemanticsLabel(
          'Gráfico da Selic nos últimos 5 anos, valor atual 13,75% ao ano',
        ),
        findsOneWidget,
      );
      expect(
        tester.getSemantics(find.text('5 anos')),
        isSemantics(isButton: true, isSelected: true),
      );
      handle.dispose();
    });

    testWidgets('carregando: esqueleto com shimmer', (tester) async {
      await pump(tester, const SelicLoading());

      expect(find.text('13,75%'), findsNothing);
      expect(find.bySemanticsLabel('Carregando a taxa Selic'), findsOneWidget);
      expect(tester.hasRunningAnimations, isTrue);
    });

    testWidgets('o shimmer para com "reduzir movimento"', (tester) async {
      await pump(tester, const SelicInitial(), disableAnimations: true);

      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('sem conexão com o último valor', (tester) async {
      await pump(
        tester,
        SelicError(ServerErrorMessages.connectionError, fakeMetric()),
      );

      expect(find.text('sem conexão'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.text('12 meses'), findsOneWidget);
      expect(find.text('Último valor salvo, atualizada hoje.'), findsOneWidget);
      final opacity = tester.widget<Opacity>(
        find.ancestor(of: find.text('13,75%'), matching: find.byType(Opacity)),
      );
      expect(opacity.opacity, 0.5);

      await tester.tap(find.text('Atualizar'));
      expect(retries, 1);
    });

    testWidgets('valor do cache aparece como sem conexão, com a data', (
      tester,
    ) async {
      await pump(
        tester,
        SelicLoaded(
          fakeMetric().copyWith(
            offline: true,
            updatedAt: DateTime(2026, 10, 21),
          ),
        ),
      );

      expect(find.text('sem conexão'), findsOneWidget);
      expect(
        find.text('Último valor salvo, atualizada em 21/10.'),
        findsOneWidget,
      );
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('5 anos sem cache: só o gráfico fica indisponível', (
      tester,
    ) async {
      await pump(
        tester,
        SelicError(
          ServerErrorMessages.connectionError,
          fakeMetric(),
          SelicPeriod.years5,
          true,
        ),
      );

      expect(find.text('13,75%'), findsOneWidget);
      expect(
        find.text('Gráfico de 5 anos indisponível sem conexão.'),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(SelicBand),
          matching: find.byWidgetPredicate(
            (w) => w is CustomPaint && w.painter is SparklinePainter,
          ),
        ),
        findsNothing,
      );
      expect(find.text('Selic indisponível'), findsNothing);
    });

    testWidgets('sem conexão e sem dados', (tester) async {
      await pump(tester, SelicError(ServerErrorMessages.connectionError));

      expect(find.text('Selic indisponível'), findsOneWidget);
      expect(find.text('Sem conexão com o Banco Central.'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);

      await tester.tap(find.text('Tentar de novo'));
      expect(retries, 1);
    });

    testWidgets('em 360dp e fonte em 130%, título e períodos não se '
        'sobrepõem e o número não é cortado', (tester) async {
      await pump(tester, SelicLoaded(fakeMetric()), width: 360, textScale: 1.3);

      expect(tester.takeException(), isNull);
      final title = tester.getRect(find.text('Taxa Selic hoje'));
      final periods = tester.getRect(find.text('12 meses'));
      expect(title.overlaps(periods), isFalse);

      final band = tester.getRect(find.byType(SelicBand));
      final rate = tester.getRect(find.text('13,75%'));
      expect(rate.left, greaterThanOrEqualTo(band.left));
      expect(rate.right, lessThanOrEqualTo(band.right));
    });
  });
}
