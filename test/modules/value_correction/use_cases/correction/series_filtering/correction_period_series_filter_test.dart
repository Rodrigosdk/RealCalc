import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/modules/value_correction/domain/entites/series_point.dart';
import 'package:real_calc/modules/value_correction/domain/enum/series_kind.dart';
import 'package:real_calc/modules/value_correction/use_cases/correction/series_filtering/correction_period_series_filter.dart';

void main() {
  late CorrectionPeriodSeriesFilter filter;

  setUp(() {
    filter = CorrectionPeriodSeriesFilter();
  });

  group('CorrectionPeriodSeriesFilter', () {
    test('normaliza uma data removendo o horário', () {
      expect(
        filter.normalizeDate(DateTime(2024, 1, 2, 18, 30)),
        DateTime(2024, 1, 2),
      );
    });

    test('inclui início e fim para séries que não são diárias', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 1, 3);
      final series = [
        SeriesPoint(date: DateTime(2023, 12, 31), value: 0),
        SeriesPoint(date: start, value: 1),
        SeriesPoint(date: DateTime(2024, 1, 2), value: 2),
        SeriesPoint(date: end, value: 3),
        SeriesPoint(date: DateTime(2024, 1, 4), value: 4),
      ];

      final filtered = filter.filter(
        series: series,
        start: start,
        end: end,
        type: SeriesKind.monthlyVariation,
      );

      expect(filtered, series.sublist(1, 4));
    });

    test('exclui a data inicial para séries diárias e ignora horários', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 1, 3);
      final series = [
        SeriesPoint(date: DateTime(2024, 1, 1, 23), value: 1),
        SeriesPoint(date: DateTime(2024, 1, 2, 8), value: 2),
        SeriesPoint(date: DateTime(2024, 1, 3, 18), value: 3),
        SeriesPoint(date: DateTime(2024, 1, 4), value: 4),
      ];

      final filtered = filter.filter(
        series: series,
        start: start,
        end: end,
        type: SeriesKind.dailyRate,
      );

      expect(filtered, series.sublist(1, 3));
    });
  });
}
