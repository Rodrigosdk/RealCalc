import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/errors/failures.dart';
import 'package:real_calc/modules/value_correction/domain/entites/correction_calculation_data.dart';
import 'package:real_calc/modules/value_correction/domain/entites/period.dart';
import 'package:real_calc/modules/value_correction/domain/entites/series_point.dart';
import 'package:real_calc/modules/value_correction/domain/entites/value_correction.dart';
import 'package:real_calc/modules/value_correction/domain/enum/correction_index.dart';
import 'package:real_calc/modules/value_correction/domain/enum/series_kind.dart';
import 'package:real_calc/modules/value_correction/domain/validation/value_correction_validation.dart';
import 'package:real_calc/modules/value_correction/use_cases/correction/data_preparation/correction_data_preparer.dart';
import 'package:real_calc/modules/value_correction/use_cases/correction/data_validation/correction_data_validator.dart';
import 'package:real_calc/modules/value_correction/use_cases/correction/rate_calculation/correction_rate_calculator.dart';
import 'package:real_calc/modules/value_correction/use_cases/correction/series_filtering/correction_period_series_filter.dart';
import 'package:real_calc/modules/value_correction/use_cases/correction/series_selection/correction_index_series_selector.dart';

void main() {
  late CorrectionDataPreparer preparer;

  setUp(() {
    final rateCalculator = CorrectionRateCalculator();
    final periodFilter = CorrectionPeriodSeriesFilter();
    preparer = CorrectionDataPreparer(
      CorrectionDataValidator(ValueCorrectionValidation()),
      periodFilter,
      CorrectionIndexSeriesSelector(rateCalculator, periodFilter),
    );
  });

  ValueCorrection buildParams({int? index, DateTime? start, DateTime? end}) {
    final originalValue = 100.0;
    return ValueCorrection(
      index: index ?? CorrectionIndex.ipca.sgsCode,
      period: Period(
        initial: start ?? DateTime(2024, 1, 1),
        end: end ?? DateTime(2024, 2, 1),
      ),
      percentage: 100,
      originalValue: originalValue,
      factor: 1,
      adjustedValue: originalValue,
      variation: 0,
    );
  }

  group('CorrectionDataPreparer', () {
    test('retorna os pontos filtrados e selecionados para cálculo', () {
      final series = [
        SeriesPoint(date: DateTime(2023, 12, 1), value: 9),
        SeriesPoint(date: DateTime(2024, 1, 1), value: 1),
        SeriesPoint(date: DateTime(2024, 2, 1), value: 2),
        SeriesPoint(date: DateTime(2024, 3, 1), value: 9),
      ];

      final result = preparer.prepare(
        params: buildParams(),
        series: series,
        type: SeriesKind.monthlyVariation,
      );

      expect(result.isSuccess, isTrue);
      final data = result.getOrNull();
      expect(data, isA<CorrectionCalculationData>());
      expect(data!.filteredSeries, series.sublist(1, 3));
      expect(data.calculationSeries, data.filteredSeries);
      expect(data.taxaLegalAccumulatedRate, isNull);
    });

    test('propaga falha quando os parâmetros são inválidos', () {
      final result = preparer.prepare(
        params: buildParams(
          start: DateTime(2024, 2, 1),
          end: DateTime(2024, 1, 1),
        ),
        series: const [],
        type: SeriesKind.monthlyVariation,
      );

      expect(result.isError, isTrue);
      expect(result.getErrorOrNull(), isA<ValidationFailure>());
    });

    test('retorna falha quando não há taxas para o período', () {
      final result = preparer.prepare(
        params: buildParams(),
        series: const [],
        type: SeriesKind.monthlyVariation,
      );

      expect(result.isError, isTrue);
      expect(result.getErrorOrNull(), isA<ValidationFailure>());
    });

    test('prepara a série da poupança nos aniversários mensais', () {
      final firstRate = SeriesPoint(
        date: DateTime(2024, 2, 15),
        periodEnd: DateTime(2024, 3, 15),
        value: 0.5,
      );
      final secondRate = SeriesPoint(
        date: DateTime(2024, 3, 15),
        periodEnd: DateTime(2024, 4, 15),
        value: 0.6,
      );
      final series = [firstRate, secondRate];

      final result = preparer.prepare(
        params: buildParams(
          index: CorrectionIndex.poupancaNova.sgsCode,
          start: DateTime(2024, 1, 15),
          end: DateTime(2024, 4, 15),
        ),
        series: series,
        type: SeriesKind.periodRate,
      );

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull()!.calculationSeries, series);
    });

    test('prepara a taxa acumulada da Taxa Legal', () {
      final result = preparer.prepare(
        params: buildParams(
          index: CorrectionIndex.taxaLegal.sgsCode,
          start: DateTime(2024, 1, 1),
          end: DateTime(2024, 2, 1),
        ),
        series: [SeriesPoint(date: DateTime(2024, 1, 1), value: 1)],
        type: SeriesKind.simpleMonthlyRate,
      );

      expect(result.isSuccess, isTrue);
      expect(
        result.getOrNull()!.taxaLegalAccumulatedRate,
        closeTo(0.01, 1e-12),
      );
    });
  });
}
