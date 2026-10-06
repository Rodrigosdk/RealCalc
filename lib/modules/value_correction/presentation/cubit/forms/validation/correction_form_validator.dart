import '../../../../domain/enum/correction_index.dart';
import '../../../../domain/enum/date_granularity.dart';
import '../value_correction_form_state.dart';
import '../date_parsing/i_correction_form_date_parser.dart';
import 'correction_form_validation_result.dart';
import 'i_correction_form_validator.dart';

class CorrectionFormValidator implements ICorrectionFormValidator {
  final ICorrectionFormDateParser _dateParser;

  CorrectionFormValidator(this._dateParser);

  @override
  CorrectionFormValidationResult validate({
    required CorrectionIndex? index,
    required String initialDate,
    required String finalDate,
    required String percentage,
    required ValueCorrectionField? lastEditedDateField,
  }) {
    final dateGranularity = index?.granularity ?? DateGranularity.month;
    final showsPercentage = index == CorrectionIndex.cdi;
    final hasInitialDate = initialDate.trim().isNotEmpty;
    final hasFinalDate = finalDate.trim().isNotEmpty;
    final hasPercentage = percentage.trim().isNotEmpty;

    final errors = <ValueCorrectionField, String?>{
      ValueCorrectionField.selectedIndex: null,
      ValueCorrectionField.initialDate: null,
      ValueCorrectionField.finalDate: null,
      ValueCorrectionField.percentage: null,
      ValueCorrectionField.value: null,
    };

    if (index == null) {
      errors[ValueCorrectionField.selectedIndex] = 'Selecione um índice';
    }

    final initialDateValue = _dateParser.parse(initialDate, dateGranularity);
    final finalDateValue = _dateParser.parse(finalDate, dateGranularity);
    final initialBeforeAvailability =
        index != null &&
        hasInitialDate &&
        initialDateValue != null &&
        initialDateValue.isBefore(index.minimumInputDate);
    final finalBeforeAvailability =
        index != null &&
        hasFinalDate &&
        finalDateValue != null &&
        finalDateValue.isBefore(index.minimumInputDate);

    if (hasInitialDate && initialDateValue == null) {
      errors[ValueCorrectionField.initialDate] = 'Data inicial inválida';
    } else if (hasInitialDate &&
        _dateParser.isFutureDate(initialDate, dateGranularity)) {
      errors[ValueCorrectionField.initialDate] =
          'A data inicial não pode ser superior à data atual.';
    }

    if (hasFinalDate && finalDateValue == null) {
      errors[ValueCorrectionField.finalDate] = 'Data final inválida';
    } else if (hasFinalDate &&
        _dateParser.isFutureDate(finalDate, dateGranularity)) {
      errors[ValueCorrectionField.finalDate] =
          'A data final não pode ser superior à data atual.';
    }

    final hasValidInitialDate =
        hasInitialDate &&
        !initialBeforeAvailability &&
        errors[ValueCorrectionField.initialDate] == null;
    final hasValidFinalDate =
        hasFinalDate &&
        !finalBeforeAvailability &&
        errors[ValueCorrectionField.finalDate] == null;
    var exceedsMaximumPeriod = false;
    var warningBannerMessage = '';

    if (initialBeforeAvailability || finalBeforeAvailability) {
      warningBannerMessage = index.availabilityMessage;
    }

    if (hasValidInitialDate && hasValidFinalDate) {
      if (initialDateValue!.isAfter(finalDateValue!)) {
        final targetField =
            lastEditedDateField ?? ValueCorrectionField.finalDate;
        if (targetField == ValueCorrectionField.finalDate) {
          errors[ValueCorrectionField.finalDate] =
              'A data final deve ser posterior ou igual à data inicial.';
          errors[ValueCorrectionField.initialDate] = null;
        } else {
          errors[ValueCorrectionField.initialDate] =
              'A data inicial deve ser anterior ou igual à data final.';
          errors[ValueCorrectionField.finalDate] = null;
        }
      } else if (index != null &&
          finalDateValue.isAfter(
            index.latestAllowedEndDate(initialDateValue),
          )) {
        exceedsMaximumPeriod = true;
        warningBannerMessage =
            'O período entre as datas não pode ser superior a 10 anos exatos.';
      }
    }

    if (showsPercentage && !hasPercentage) {
      errors[ValueCorrectionField.percentage] = 'Informe o percentual';
    }

    final canCalculate =
        index != null &&
        hasInitialDate &&
        hasFinalDate &&
        !initialBeforeAvailability &&
        !finalBeforeAvailability &&
        !exceedsMaximumPeriod &&
        errors[ValueCorrectionField.initialDate] == null &&
        errors[ValueCorrectionField.finalDate] == null &&
        (!showsPercentage ||
            (hasPercentage && errors[ValueCorrectionField.percentage] == null));

    return CorrectionFormValidationResult(
      canCalculate: canCalculate,
      warningBannerMessage: warningBannerMessage,
      fieldErrors: errors,
    );
  }
}
