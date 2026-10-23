import '../../../../domain/entites/value_correction.dart';
import '../../../../domain/enum/correction_index.dart';

abstract interface class IValueCorrectionRequestValidator {
  String? validate({
    required CorrectionIndex index,
    required ValueCorrection params,
  });
}
