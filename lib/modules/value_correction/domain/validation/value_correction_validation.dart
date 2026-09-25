import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/core/seed_works/error.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/seed_works/result.dart';
import '../entites/value_correction.dart';

class ValueCorrectionValidation {
  Result<Failure, Null> validate(ValueCorrection params) {
    final List<ErrorMessages> erros = [];

    if (params.period.initial.isAfter(params.period.end)) {
      erros.add(ValueCorrectionValidationMessage.invalidPeriod);
    }

    if (params.percentage < 0) {
      erros.add(ValueCorrectionValidationMessage.invalidPercentage);
    }

    if (params.originalValue != null && params.originalValue! < 0) {
      erros.add(ValueCorrectionValidationMessage.invalidValue);
    }

    if (erros.isNotEmpty) {
      return FailureResult<Failure, Null>(ValidationFailure(message: erros));
    }

    return SuccessResult<Failure, Null>(null);
  }
}
