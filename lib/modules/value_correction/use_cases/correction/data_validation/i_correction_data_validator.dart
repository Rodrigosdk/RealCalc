import '../../../../../core/errors/failures.dart';
import '../../../domain/entites/series_point.dart';
import '../../../domain/entites/value_correction.dart';
import '../../../domain/enum/series_kind.dart';

abstract interface class ICorrectionDataValidator {
  Failure? validateParams(ValueCorrection params);

  Failure? validateSeriesAvailability({
    required int index,
    required SeriesKind type,
    required List<SeriesPoint> filteredSeries,
    required List<SeriesPoint> savingsRates,
    required List<SeriesPoint> trPeriods,
    required double? taxaLegalAccumulatedRate,
  });
}
