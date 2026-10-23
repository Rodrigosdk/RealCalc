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
  final String warningBannerMessage;
  final Map<ValueCorrectionField, String?> fieldErrors;

  const ValueCorrectionFormState({
    required this.index,
    required this.dateGranularity,
    required this.showsPercentage,
    required this.canCalculate,
    required this.warningBannerMessage,
    required this.fieldErrors,
  });

  factory ValueCorrectionFormState.initial() {
    return const ValueCorrectionFormState(
      index: null,
      dateGranularity: DateGranularity.month,
      showsPercentage: false,
      canCalculate: false,
      warningBannerMessage: '',
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
    String? warningBannerMessage,
    Map<ValueCorrectionField, String?>? fieldErrors,
  }) {
    return ValueCorrectionFormState(
      index: index ?? this.index,
      dateGranularity: dateGranularity ?? this.dateGranularity,
      showsPercentage: showsPercentage ?? this.showsPercentage,
      canCalculate: canCalculate ?? this.canCalculate,
      warningBannerMessage: warningBannerMessage ?? this.warningBannerMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }
}
