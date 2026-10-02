import '../../../domain/enum/correction_index.dart';
import '../../../domain/enum/date_granularity.dart';

enum ValueCorrectionField {
  selectedIndex,
  initialDate,
  finalDate,
  percentage,
  value,
}

class ValueCorrectionFormState {
  final CorrectionIndex? index;
  final DateGranularity dateGranularity;
  final bool showsPercentage;
  final bool canCalculate;
  final bool showsCurrencyWarning;
  final Map<ValueCorrectionField, String?> fieldErrors;

  const ValueCorrectionFormState({
    required this.index,
    required this.dateGranularity,
    required this.showsPercentage,
    required this.canCalculate,
    required this.showsCurrencyWarning,
    required this.fieldErrors,
  });

  factory ValueCorrectionFormState.initial() {
    return const ValueCorrectionFormState(
      index: null,
      dateGranularity: DateGranularity.month,
      showsPercentage: false,
      canCalculate: false,
      showsCurrencyWarning: false,
      fieldErrors: {
        ValueCorrectionField.selectedIndex: null,
        ValueCorrectionField.initialDate: null,
        ValueCorrectionField.finalDate: null,
        ValueCorrectionField.percentage: null,
        ValueCorrectionField.value: null,
      },
    );
  }

  ValueCorrectionFormState copyWith({
    CorrectionIndex? index,
    DateGranularity? dateGranularity,
    bool? showsPercentage,
    bool? canCalculate,
    bool? showsCurrencyWarning,
    Map<ValueCorrectionField, String?>? fieldErrors,
  }) {
    return ValueCorrectionFormState(
      index: index ?? this.index,
      dateGranularity: dateGranularity ?? this.dateGranularity,
      showsPercentage: showsPercentage ?? this.showsPercentage,
      canCalculate: canCalculate ?? this.canCalculate,
      showsCurrencyWarning: showsCurrencyWarning ?? this.showsCurrencyWarning,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }
}
