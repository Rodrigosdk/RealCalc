import '../../../../domain/entites/value_correction.dart';
import '../../../../domain/enum/correction_index.dart';

abstract interface class IValueCorrectionRequestParser {
  ValueCorrection? parse({
    required CorrectionIndex index,
    required String initialDate,
    required String finalDate,
    required String percentage,
    required String value,
  });
}
