import '../../../../core/seed_works/error.dart';
import '../../../../core/seed_works/result.dart';
import '../enum/correction_index.dart';
import '../entites/series_point.dart';

abstract class ICorrectionSeriesRepository {
  Future<Result<ErrorMessages, List<SeriesPoint>>> correctionSeries();

  Future<Result<ErrorMessages, List<SeriesPoint>>> getSeries({
    required CorrectionIndex index,
    required DateTime start,
    required DateTime end,
  });
}