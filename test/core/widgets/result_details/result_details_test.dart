import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/themes/app_colors.dart';
import 'package:real_calc/core/themes/app_theme.dart';
import 'package:real_calc/core/themes/calculator_palette.dart';
import 'package:real_calc/core/themes/calculator_scope.dart';
import 'package:real_calc/core/widgets/result_details/result_details.dart';
import 'package:real_calc/core/widgets/result_details/result_summary.dart';
import 'package:real_calc/modules/financial_calculators/domain/entities/financial_calculation.dart';
import 'package:real_calc/modules/financial_calculators/presentation/utils/result_summaries.dart';
import 'package:real_calc/modules/value_correction/domain/entites/period.dart';
import 'package:real_calc/modules/value_correction/domain/entites/value_correction.dart';
import 'package:real_calc/modules/value_correction/presentation/utils/correction_result_summary.dart';

final financing = financingResultSummary(
  FinancialCalculation(
    initialValue: 2500,
    rate: 2,
    periods: 12,
    finalValue: 236.3990,
  ),
);

final correction = correctionResultSummary(
  ValueCorrection(
    index: 433,
    period: Period(initial: DateTime(2022), end: DateTime(2025)),
    percentage: 100,
    originalValue: 1000,
    factor: 1.2345678,
    adjustedValue: 1234.5678,
    variation: 23.45678,
  ),
)!;

/// Carrega a Manrope para os goldens mostrarem o texto de verdade, e não os
/// blocos da fonte padrão de teste.
Future<void> loadManrope() async {
  final loader = FontLoader('Manrope');
  for (final weight in ['Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
    loader.addFont(rootBundle.load('assets/fonts/Manrope-$weight.ttf'));
  }
  await loader.load();
}

void main() {
  setUpAll(loadManrope);

  Future<void> pump(
    WidgetTester tester,
    ResultSummary summary, {
    CalculatorKind kind = CalculatorKind.financing,
    Brightness brightness = Brightness.light,
    double width = 360,
  }) async {
    tester.view.physicalSize = Size(width, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: brightness == Brightness.light
            ? AppTheme.lightTheme
            : AppTheme.darkTheme,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: CalculatorScope(
              kind: kind,
              child: Align(
                alignment: Alignment.topCenter,
                child: ResultDetails(summary: summary),
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('ResultDetails', () {
    testWidgets('mostra título, legenda e linhas de detalhe', (tester) async {
      await pump(tester, financing);

      expect(find.text('Do total que você vai pagar'), findsOneWidget);
      expect(find.text('Emprestado 88%'), findsOneWidget);
      expect(find.text('Juros 12%'), findsOneWidget);
      for (final line in financing.lines) {
        expect(find.text(line.label), findsOneWidget);
        expect(find.text(line.value), findsOneWidget);
      }
      expect(find.text(financing.lines.first.value), findsOneWidget);
      expect(financing.lines.first.value, contains('2.836,80'));
    });

    testWidgets('barra de 6px com a cor da pessoa e a da calculadora', (
      tester,
    ) async {
      await pump(tester, financing);

      final boxes = tester
          .widgetList<ColoredBox>(
            find.descendant(
              of: find.byType(ResultDetails),
              matching: find.byType(ColoredBox),
            ),
          )
          .map((box) => box.color)
          .toList();
      expect(boxes, [
        AppColors.light.textPrimary,
        CalculatorPalette.of(CalculatorKind.financing).solid,
      ]);

      final bar = find.descendant(
        of: find.byType(ResultDetails),
        matching: find.byType(ClipRRect),
      );
      expect(tester.getSize(bar).height, ResultDetails.barHeight);
      // Cada segmento ocupa a altura toda da barra, na proporção 88/12.
      final segments = find.descendant(
        of: bar,
        matching: find.byType(ColoredBox),
      );
      final own = tester.getSize(segments.at(0));
      final other = tester.getSize(segments.at(1));
      expect(own.height, ResultDetails.barHeight);
      expect(other.height, ResultDetails.barHeight);
      expect(own.width / (own.width + other.width), closeTo(0.88, 0.01));
    });

    testWidgets('linhas de detalhe têm pelo menos 32px', (tester) async {
      await pump(tester, financing);

      final row = find
          .ancestor(
            of: find.text('Total pago'),
            matching: find.byType(ConstrainedBox),
          )
          .first;
      expect(
        tester.getSize(row).height,
        greaterThanOrEqualTo(ResultDetails.lineHeight),
      );
    });

    testWidgets('a barra tem Semantics com a composição', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, financing);

      expect(
        find.bySemanticsLabel('Emprestado 88%, Juros 12%'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('sem composição, mostra só título e linhas', (tester) async {
      await pump(
        tester,
        const ResultSummary(
          title: 'Do valor corrigido',
          composition: null,
          lines: [ResultDetailLine('Fator de correção', '0,9900000')],
        ),
      );

      expect(
        find.descendant(
          of: find.byType(ResultDetails),
          matching: find.byType(ClipRRect),
        ),
        findsNothing,
      );
      expect(find.text('Fator de correção'), findsOneWidget);
    });

    testWidgets('valores com 7 dígitos cabem em 360dp', (tester) async {
      final summary = financingResultSummary(
        FinancialCalculation(
          initialValue: 1500000,
          rate: 1.5,
          periods: 360,
          finalValue: 22839.53,
        ),
      );
      expect(summary.lines.first.value, contains('8.222.230,80'));

      await pump(tester, summary);

      expect(tester.takeException(), isNull);
      for (final line in summary.lines) {
        final value = tester.getRect(find.text(line.value));
        expect(value.right, lessThanOrEqualTo(360 - 24));
      }
    });
  });

  group('goldens', () {
    for (final brightness in Brightness.values) {
      testWidgets('financiamento no tema ${brightness.name}', (tester) async {
        await pump(tester, financing, brightness: brightness);
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile('goldens/financing_${brightness.name}.png'),
        );
      });

      testWidgets('correção no tema ${brightness.name}', (tester) async {
        await pump(
          tester,
          correction,
          kind: CalculatorKind.correction,
          brightness: brightness,
        );
        expect(find.text('Valor original 81%'), findsOneWidget);
        expect(find.text('Correção 19%'), findsOneWidget);
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile('goldens/correction_${brightness.name}.png'),
        );
      });
    }
  });
}
