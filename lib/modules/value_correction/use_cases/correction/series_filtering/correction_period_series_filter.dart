import '../../../domain/entites/series_point.dart';
import '../../../domain/enum/series_kind.dart';
import 'i_correction_period_series_filter.dart';

class CorrectionPeriodSeriesFilter implements ICorrectionPeriodSeriesFilter {
  @override
  DateTime normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  @override
  List<SeriesPoint> filter({
    required List<SeriesPoint> series,
    required DateTime start,
    required DateTime end,
    required SeriesKind type,
  }) {
    return series.where((point) {
      final pointDate = normalizeDate(point.date);
      final isAfterStart = type == SeriesKind.dailyRate
          ? pointDate.isAfter(start)
          : !pointDate.isBefore(start);
      return isAfterStart && !pointDate.isAfter(end);
    }).toList();
  }
}
