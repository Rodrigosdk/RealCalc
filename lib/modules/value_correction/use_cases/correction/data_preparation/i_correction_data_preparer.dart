import 'package:real_calc/core/seed_works/result.dart';

import '../../../../../core/errors/failures.dart';
import '../../../domain/entities/correction_calculation_data.dart';
import '../../../domain/entities/series_point.dart';
import '../../../domain/entities/value_correction.dart';
import '../../../domain/enum/series_kind.dart';

abstract interface class ICorrectionDataPreparer {
  Result<Failure, CorrectionCalculationData> prepare({
    required ValueCorrection params,
    required List<SeriesPoint> series,
    required SeriesKind type,
  });
}
