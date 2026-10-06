import '../../../../domain/enum/correction_index.dart';
import '../value_correction_form_state.dart';
import 'correction_form_validation_result.dart';

abstract interface class ICorrectionFormValidator {
  CorrectionFormValidationResult validate({
    required CorrectionIndex? index,
    required String initialDate,
    required String finalDate,
    required String percentage,
    required ValueCorrectionField? lastEditedDateField,
  });
}
