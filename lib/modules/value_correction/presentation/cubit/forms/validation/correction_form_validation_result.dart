import '../value_correction_form_state.dart';

class CorrectionFormValidationResult {
  final bool canCalculate;
  final String warningBannerMessage;
  final Map<ValueCorrectionField, String?> fieldErrors;

  const CorrectionFormValidationResult({
    required this.canCalculate,
    required this.warningBannerMessage,
    required this.fieldErrors,
  });
}
