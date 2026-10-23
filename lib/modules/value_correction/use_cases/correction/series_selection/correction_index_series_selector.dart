import '../../../domain/entites/series_point.dart';
import '../../../domain/enum/correction_index.dart';
import '../../../domain/enum/series_kind.dart';
import '../rate_calculation/i_correction_rate_calculator.dart';
import '../series_filtering/i_correction_period_series_filter.dart';
import 'i_correction_index_series_selector.dart';

class CorrectionIndexSeriesSelector implements ICorrectionIndexSeriesSelector {
  final ICorrectionRateCalculator _rateCalculator;
  final ICorrectionPeriodSeriesFilter _periodSeriesFilter;

  CorrectionIndexSeriesSelector(this._rateCalculator, this._periodSeriesFilter);

  @override
  double? selectTaxaLegalRate({
    required int index,
    required List<SeriesPoint> series,
    required DateTime start,
    required DateTime end,
  }) {
    if (index != CorrectionIndex.taxaLegal.sgsCode) return null;
    return _rateCalculator.calculateTaxaLegalAccumulatedRate(
      series,
      start,
      end,
    );
  }

  @override
  List<SeriesPoint> selectSavingsRates({
    required int index,
    required List<SeriesPoint> series,
    required DateTime start,
    required DateTime end,
  }) {
    if (!_isSavings(index)) return const <SeriesPoint>[];

    final isOldSavings = index == CorrectionIndex.poupancaVelha.sgsCode;
    return series.where((point) {
      final pointDate = _periodSeriesFilter.normalizeDate(point.date);
      final isInSavingsPeriod = isOldSavings
          ? !pointDate.isBefore(start)
          : pointDate.isAfter(start);
      return isInSavingsPeriod &&
          pointDate.isBefore(end) &&
          pointDate.day == start.day &&
          point.periodEnd != null &&
          _sameDate(point.periodEnd!, _nextMonthlyAnniversary(pointDate));
    }).toList();
  }

  @override
  List<SeriesPoint> selectTrRates({
    required int index,
    required List<SeriesPoint> series,
    required DateTime start,
    required DateTime end,
  }) {
    if (index != CorrectionIndex.tr.sgsCode) return const <SeriesPoint>[];
    return _selectTrPeriods(series, start, end);
  }

  @override
  List<SeriesPoint> selectCalculationSeries({
    required int index,
    required SeriesKind type,
    required List<SeriesPoint> filteredSeries,
    required List<SeriesPoint> savingsRates,
    required List<SeriesPoint> trRates,
  }) {
    if (type != SeriesKind.periodRate) return filteredSeries;
    if (index == CorrectionIndex.tr.sgsCode) return trRates;
    if (_isSavings(index)) return savingsRates;
    return filteredSeries;
  }

  List<SeriesPoint> _selectTrPeriods(
    List<SeriesPoint> series,
    DateTime start,
    DateTime end,
  ) {
    final rates = <SeriesPoint>[];
    var cursor = start;

    while (cursor.isBefore(end)) {
      final nextAnniversary = _nextMonthlyAnniversary(cursor);
      if (nextAnniversary.isAfter(end)) break;

      final candidates =
          series
              .where(
                (point) =>
                    _sameDate(point.date, cursor) && point.periodEnd != null,
              )
              .toList()
            ..sort((a, b) => a.periodEnd!.compareTo(b.periodEnd!));

      if (candidates.isEmpty) break;

      final selected = cursor.day == 1
          ? candidates.first
          : candidates.firstWhere(
              (point) => _sameDate(point.periodEnd!, nextAnniversary),
              orElse: () => candidates.last,
            );
      rates.add(selected);
      cursor = selected.periodEnd!;
      if (cursor.day == DateTime(cursor.year, cursor.month + 1, 0).day) {
        cursor = cursor.add(const Duration(days: 1));
      }
    }

    if (rates.isEmpty) return const <SeriesPoint>[];

    if (!_sameDate(cursor, end)) {
      final finalDateRate = series.where((point) {
        return _sameDate(point.date, end);
      }).toList();
      if (finalDateRate.isEmpty) return const <SeriesPoint>[];
      rates.add(finalDateRate.first);
    }

    return rates;
  }

  DateTime _nextMonthlyAnniversary(DateTime date) {
    final monthStart = DateTime(date.year, date.month + 1, 1);
    final lastDay = DateTime(monthStart.year, monthStart.month + 1, 0).day;
    return DateTime(
      monthStart.year,
      monthStart.month,
      date.day > lastDay ? lastDay : date.day,
    );
  }

  bool _isSavings(int index) =>
      index == CorrectionIndex.poupancaNova.sgsCode ||
      index == CorrectionIndex.poupancaVelha.sgsCode;

  bool _sameDate(DateTime left, DateTime right) =>
      left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}
