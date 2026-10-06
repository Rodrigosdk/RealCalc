import '../../../../domain/entites/value_correction.dart';
import '../../../../domain/enum/correction_index.dart';
import '../../../../domain/validation/i_value_correction_validation.dart';
import 'i_value_correction_request_validator.dart';

class ValueCorrectionRequestValidator
    implements IValueCorrectionRequestValidator {
  final IValueCorrectionValidation _paramsValidator;

  ValueCorrectionRequestValidator(this._paramsValidator);

  @override
  String? validate({
    required CorrectionIndex index,
    required ValueCorrection params,
  }) {
    if (params.period.initial.isBefore(index.minimumInputDate) ||
        params.period.end.isBefore(index.minimumInputDate)) {
      return index.availabilityMessage;
    }

    final validationFailure = _paramsValidator
        .validate(params)
        .getErrorOrNull();
    if (validationFailure != null) {
      return validationFailure.message.first.message;
    }

    if (params.period.end.isAfter(
      index.latestAllowedEndDate(params.period.initial),
    )) {
      return 'O período entre as datas não pode ser superior a 10 anos exatos.';
    }

    return null;
  }
}
