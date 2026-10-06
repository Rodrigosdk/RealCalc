import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/modules/value_correction/domain/entites/series_point.dart';
import 'package:real_calc/modules/value_correction/domain/enum/correction_index.dart';
import 'package:real_calc/modules/value_correction/domain/enum/series_kind.dart';
import 'package:real_calc/modules/value_correction/use_cases/correction/rate_calculation/correction_rate_calculator.dart';
import 'package:real_calc/modules/value_correction/use_cases/correction/series_filtering/correction_period_series_filter.dart';
import 'package:real_calc/modules/value_correction/use_cases/correction/series_selection/correction_index_series_selector.dart';

void main() {
  late CorrectionIndexSeriesSelector selector;

  setUp(() {
    selector = CorrectionIndexSeriesSelector(
      CorrectionRateCalculator(),
      CorrectionPeriodSeriesFilter(),
    );
  });

  group('CorrectionIndexSeriesSelector', () {
    test('calcula taxa legal apenas para o índice Taxa Legal', () {
      final series = [SeriesPoint(date: DateTime(2024, 1, 1), value: 1)];

      expect(
        selector.selectTaxaLegalRate(
          index: CorrectionIndex.ipca.sgsCode,
          series: series,
          start: DateTime(2024, 1, 1),
          end: DateTime(2024, 2, 1),
        ),
        isNull,
      );
      expect(
        selector.selectTaxaLegalRate(
          index: CorrectionIndex.taxaLegal.sgsCode,
          series: series,
          start: DateTime(2024, 1, 1),
          end: DateTime(2024, 2, 1),
        ),
        closeTo(0.01, 1e-12),
      );
    });

    test('seleciona aniversários de poupança com limites diferentes', () {
      final initialAnniversary = SeriesPoint(
        date: DateTime(2024, 1, 15),
        periodEnd: DateTime(2024, 2, 15),
        value: 1,
      );
      final nextAnniversary = SeriesPoint(
        date: DateTime(2024, 2, 15),
        periodEnd: DateTime(2024, 3, 15),
        value: 2,
      );
      final lastAnniversary = SeriesPoint(
        date: DateTime(2024, 3, 15),
        periodEnd: DateTime(2024, 4, 15),
        value: 3,
      );
      final series = [initialAnniversary, nextAnniversary, lastAnniversary];

      final newSavings = selector.selectSavingsRates(
        index: CorrectionIndex.poupancaNova.sgsCode,
        series: series,
        start: DateTime(2024, 1, 15),
        end: DateTime(2024, 4, 15),
      );
      final oldSavings = selector.selectSavingsRates(
        index: CorrectionIndex.poupancaVelha.sgsCode,
        series: series,
        start: DateTime(2024, 1, 15),
        end: DateTime(2024, 4, 15),
      );

      expect(newSavings, [nextAnniversary, lastAnniversary]);
      expect(oldSavings, series);
      expect(
        selector.selectSavingsRates(
          index: CorrectionIndex.ipca.sgsCode,
          series: series,
          start: DateTime(2024, 1, 15),
          end: DateTime(2024, 4, 15),
        ),
        isEmpty,
      );
    });

    test('seleciona os períodos TR consecutivos até a data final', () {
      final firstPeriod = SeriesPoint(
        date: DateTime(2025, 8, 1),
        periodEnd: DateTime(2025, 8, 31),
        value: 0.1,
      );
      final secondPeriod = SeriesPoint(
        date: DateTime(2025, 9, 1),
        periodEnd: DateTime(2025, 10, 1),
        value: 0.2,
      );
      final series = [firstPeriod, secondPeriod];

      expect(
        selector.selectTrRates(
          index: CorrectionIndex.tr.sgsCode,
          series: series,
          start: DateTime(2025, 8, 1),
          end: DateTime(2025, 10, 1),
        ),
        series,
      );
      expect(
        selector.selectTrRates(
          index: CorrectionIndex.ipca.sgsCode,
          series: series,
          start: DateTime(2025, 8, 1),
          end: DateTime(2025, 10, 1),
        ),
        isEmpty,
      );
    });

    test('escolhe a série de cálculo por tipo e índice', () {
      final filtered = [SeriesPoint(date: DateTime(2024, 1, 1), value: 1)];
      final savings = [SeriesPoint(date: DateTime(2024, 2, 1), value: 2)];
      final tr = [SeriesPoint(date: DateTime(2024, 3, 1), value: 3)];

      expect(
        selector.selectCalculationSeries(
          index: CorrectionIndex.tr.sgsCode,
          type: SeriesKind.periodRate,
          filteredSeries: filtered,
          savingsRates: savings,
          trRates: tr,
        ),
        tr,
      );
      expect(
        selector.selectCalculationSeries(
          index: CorrectionIndex.poupancaNova.sgsCode,
          type: SeriesKind.periodRate,
          filteredSeries: filtered,
          savingsRates: savings,
          trRates: tr,
        ),
        savings,
      );
      expect(
        selector.selectCalculationSeries(
          index: CorrectionIndex.ipca.sgsCode,
          type: SeriesKind.monthlyVariation,
          filteredSeries: filtered,
          savingsRates: savings,
          trRates: tr,
        ),
        filtered,
      );
    });
  });
}
