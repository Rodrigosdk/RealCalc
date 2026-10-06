import '../../../domain/entites/series_point.dart';
import 'i_correction_rate_calculator.dart';

class CorrectionRateCalculator implements ICorrectionRateCalculator {
  @override
  double calculateMonthlyVariation(List<SeriesPoint> series) {
    var factor = 1.0;
    for (final point in series) {
      factor *= 1 + (point.value / 100);
    }
    return factor;
  }

  @override
  double calculateDailyRate(List<SeriesPoint> series, double percentage) {
    var factor = 1.0;
    final appliedPercentage = percentage / 100;
    for (final point in series) {
      factor *= 1 + ((point.value / 100) * appliedPercentage);
    }
    return factor;
  }

  @override
  double calculatePeriodRate(List<SeriesPoint> series) {
    var factor = 1.0;
    for (final point in series) {
      factor *= 1 + (point.value / 100);
    }
    return factor;
  }

  @override
  double calculateSimpleMonthlyRate(
    List<SeriesPoint> series, {
    double? taxaLegalAccumulatedRate,
  }) {
    if (taxaLegalAccumulatedRate != null) {
      return 1 + taxaLegalAccumulatedRate;
    }

    final accumulatedRate = series.fold<double>(
      0,
      (total, point) => total + point.value / 100,
    );
    return 1 + accumulatedRate;
  }

  @override
  double? calculateTaxaLegalAccumulatedRate(
    List<SeriesPoint> series,
    DateTime start,
    DateTime end,
  ) {
    if (!start.isBefore(end)) return 0;

    var accumulatedRate = 0.0;
    var monthStart = DateTime(start.year, start.month);

    while (monthStart.isBefore(end)) {
      final nextMonth = DateTime(monthStart.year, monthStart.month + 1);
      final overlapStart = start.isAfter(monthStart) ? start : monthStart;
      final overlapEnd = end.isBefore(nextMonth) ? end : nextMonth;
      final elapsedDays = overlapEnd.difference(overlapStart).inDays;

      if (elapsedDays > 0) {
        final monthRates = series.where((point) {
          return point.date.year == monthStart.year &&
              point.date.month == monthStart.month;
        });
        if (monthRates.isEmpty) return null;

        final daysInMonth = nextMonth.difference(monthStart).inDays;
        final proratedRatePercent =
            (monthRates.first.value * elapsedDays / daysInMonth * 1000000)
                .round() /
            1000000;
        accumulatedRate += proratedRatePercent / 100;
      }

      monthStart = nextMonth;
    }

    return accumulatedRate;
  }
}
