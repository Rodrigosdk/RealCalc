import '../../../../core/seed_works/error.dart';
import '../../../../core/seed_works/result.dart';
import '../entites/series_point.dart';

abstract class  ICorrectionSeriesRepository{
  Future<Result<ErrorMessages, List<SeriesPoint>>> correctionSeries();
}