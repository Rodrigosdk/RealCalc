import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/modules/value_correction/domain/entites/series_point.dart';
import 'package:real_calc/modules/value_correction/use_cases/correction/rate_calculation/correction_rate_calculator.dart';

void main() {
  late CorrectionRateCalculator calculator;

  setUp(() {
    calculator = CorrectionRateCalculator();
  });

  group('CorrectionRateCalculator', () {
    test('compõe variações mensais e taxas de período', () {
      final series = [
        SeriesPoint(date: DateTime(2024, 1), value: 2),
        SeriesPoint(date: DateTime(2024, 2), value: 3),
      ];

      expect(
        calculator.calculateMonthlyVariation(series),
        closeTo(1.0506, 1e-12),
      );
      expect(calculator.calculatePeriodRate(series), closeTo(1.0506, 1e-12));
    });

    test('aplica o percentual às taxas diárias antes de compor', () {
      final factor = calculator.calculateDailyRate([
        SeriesPoint(date: DateTime(2024, 1, 1), value: 1),
        SeriesPoint(date: DateTime(2024, 1, 2), value: 2),
      ], 80);

      expect(factor, closeTo(1.024128, 1e-12));
    });

    test(
      'soma taxas simples e usa a taxa legal acumulada quando fornecida',
      () {
        final series = [
          SeriesPoint(date: DateTime(2024, 1), value: 1),
          SeriesPoint(date: DateTime(2024, 2), value: 2),
        ];

        expect(
          calculator.calculateSimpleMonthlyRate(series),
          closeTo(1.03, 1e-12),
        );
        expect(
          calculator.calculateSimpleMonthlyRate(
            series,
            taxaLegalAccumulatedRate: 0.025,
          ),
          closeTo(1.025, 1e-12),
        );
      },
    );

    test(
      'calcula taxa legal proporcional aos dias e retorna null sem um mês',
      () {
        final rate = calculator.calculateTaxaLegalAccumulatedRate(
          [SeriesPoint(date: DateTime(2024, 1, 1), value: 1)],
          DateTime(2024, 1, 16),
          DateTime(2024, 2, 1),
        );
        final missingMonthRate = calculator.calculateTaxaLegalAccumulatedRate(
          [SeriesPoint(date: DateTime(2024, 1, 1), value: 1)],
          DateTime(2024, 1, 16),
          DateTime(2024, 3, 1),
        );

        expect(rate, closeTo(0.00516129, 1e-12));
        expect(missingMonthRate, isNull);
      },
    );

    test('retorna taxa acumulada zero para intervalo sem duração', () {
      expect(
        calculator.calculateTaxaLegalAccumulatedRate(
          const [],
          DateTime(2024, 1, 1),
          DateTime(2024, 1, 1),
        ),
        0,
      );
    });
  });
}
