import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/widgets/result_details/result_summary.dart';
import 'package:real_calc/modules/financial_calculators/domain/entities/financial_calculation.dart';
import 'package:real_calc/modules/financial_calculators/presentation/utils/result_summaries.dart';

void main() {
  group('financingResultSummary', () {
    // R$ 2.500,00 a 2% a.m. em 12 meses: prestação de R$ 236,399 → 236,40.
    final calculation = FinancialCalculation(
      initialValue: 2500,
      rate: 2,
      periods: 12,
      finalValue: 236.3990,
    );

    test('o total sai da prestação arredondada: 236,40 × 12', () {
      final summary = financingResultSummary(calculation);

      expect(summary.title, 'Do total que você vai pagar');
      expect(summary.lines, const [
        ResultDetailLine('Total pago', 'R\$\u00A02.836,80'),
        ResultDetailLine('Total de juros', 'R\$\u00A0336,80'),
        ResultDetailLine('Taxa anual equivalente', '26,82% a.a.'),
      ]);
    });

    test('composição: emprestado 88%, juros 12%', () {
      final composition = financingResultSummary(calculation).composition!;

      expect(composition.own, const ResultSegment('Emprestado', 88));
      expect(composition.other, const ResultSegment('Juros', 12));
      expect(composition.semanticsLabel, 'Emprestado 88%, Juros 12%');
    });
  });

  group('regularDepositsResultSummary', () {
    test('R\$ 100,00 por mês a 1% em 12 meses', () {
      final summary = regularDepositsResultSummary(
        FinancialCalculation(
          initialValue: 100,
          rate: 1,
          periods: 12,
          finalValue: 1280.9328,
        ),
      );

      expect(summary.title, 'Do valor final');
      expect(summary.lines, const [
        ResultDetailLine('Total depositado', 'R\$\u00A01.200,00'),
        ResultDetailLine('Rendimento', 'R\$\u00A080,93'),
        ResultDetailLine('Taxa anual equivalente', '12,68% a.a.'),
      ]);
      expect(summary.composition!.own, const ResultSegment('Depositado', 94));
      expect(summary.composition!.other, const ResultSegment('Rendimento', 6));
    });
  });

  group('futureValueResultSummary', () {
    test('R\$ 1.000,00 a 1% em 12 meses', () {
      final summary = futureValueResultSummary(
        FinancialCalculation(
          initialValue: 1000,
          rate: 1,
          periods: 12,
          finalValue: 1126.8250,
        ),
      );

      expect(summary.lines, const [
        ResultDetailLine('Valor aplicado', 'R\$\u00A01.000,00'),
        ResultDetailLine('Rendimento', 'R\$\u00A0126,83'),
        ResultDetailLine('Taxa anual equivalente', '12,68% a.a.'),
      ]);
      expect(
        summary.composition!.own,
        const ResultSegment('Valor aplicado', 89),
      );
      expect(summary.composition!.other, const ResultSegment('Rendimento', 11));
    });

    test('taxa zero: rendimento 0% e a barra continua somando 100', () {
      final composition = futureValueResultSummary(
        FinancialCalculation(
          initialValue: 1000,
          rate: 0,
          periods: 12,
          finalValue: 1000,
        ),
      ).composition!;

      expect(composition.own.percent, 100);
      expect(composition.other.percent, 0);
    });
  });

  group('ResultComposition', () {
    test('os percentuais sempre somam 100', () {
      for (final (own, other) in [
        (250000, 33680),
        (1, 2),
        (1, 1),
        (333, 667),
        (99950, 50),
        (123456789, 98765),
      ]) {
        final composition = ResultComposition.fromCents(
          ownLabel: 'a',
          ownCents: own,
          otherLabel: 'b',
          otherCents: other,
        )!;
        expect(
          composition.own.percent + composition.other.percent,
          100,
          reason: '$own + $other',
        );
      }
    });

    test('sem total positivo ou com parte negativa, não há barra', () {
      ResultComposition? of(int own, int other) => ResultComposition.fromCents(
        ownLabel: 'a',
        ownCents: own,
        otherLabel: 'b',
        otherCents: other,
      );

      expect(of(0, 0), isNull);
      expect(of(1000, -50), isNull);
      expect(of(-10, 50), isNull);
    });
  });
}
