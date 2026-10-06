import '../../../domain/entites/series_point.dart';
import '../../../domain/enum/series_kind.dart';

abstract interface class ICorrectionIndexSeriesSelector {
  double? selectTaxaLegalRate({
    required int index,
    required List<SeriesPoint> series,
    required DateTime start,
    required DateTime end,
  });

  List<SeriesPoint> selectSavingsRates({
    required int index,
    required List<SeriesPoint> series,
    required DateTime start,
    required DateTime end,
  });

  List<SeriesPoint> selectTrRates({
    required int index,
    required List<SeriesPoint> series,
    required DateTime start,
    required DateTime end,
  });

  List<SeriesPoint> selectCalculationSeries({
    required int index,
    required SeriesKind type,
    required List<SeriesPoint> filteredSeries,
    required List<SeriesPoint> savingsRates,
    required List<SeriesPoint> trRates,
  });
}
