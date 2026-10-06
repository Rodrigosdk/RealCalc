import 'package:real_calc/core/seed_works/result.dart';

import '../../../../core/errors/failures.dart';
import '../entites/value_correction.dart';

abstract interface class IValueCorrectionValidation {
  Result<Failure, Null> validate(ValueCorrection params);
}
