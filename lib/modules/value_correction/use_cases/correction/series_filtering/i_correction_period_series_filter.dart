import '../../../domain/entites/series_point.dart';
import '../../../domain/enum/series_kind.dart';

abstract interface class ICorrectionPeriodSeriesFilter {
  DateTime normalizeDate(DateTime date);

  List<SeriesPoint> filter({
    required List<SeriesPoint> series,
    required DateTime start,
    required DateTime end,
    required SeriesKind type,
  });
}
