import 'package:real_calc/core/seed_works/result.dart';

import '../../../core/errors/failures.dart';
import '../domain/entites/series_point.dart';
import '../domain/entites/value_correction.dart';
import '../domain/enum/series_kind.dart';

abstract interface class ICalculateValueCorrection {
  Result<Failure, ValueCorrection> call({
    required ValueCorrection params,
    required List<SeriesPoint> series,
    required SeriesKind type,
  });
}