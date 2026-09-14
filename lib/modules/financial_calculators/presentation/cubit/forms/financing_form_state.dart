

import '../../../domain/enum/financial_calculation_target.dart';
import '../../../domain/enum/input_field_state.dart';

class FinancingFormState {
  final FinancialCalculationTarget? calculatedField;
  final Map<FinancialCalculationTarget, InputFieldState> fieldStates;
  final bool canCalculate;

  const FinancingFormState({
    required this.calculatedField,
    required this.fieldStates,
    required this.canCalculate,
  });

  factory FinancingFormState.initial() {
    return const FinancingFormState(
      calculatedField: null,
      fieldStates: {
        FinancialCalculationTarget.initialValue: InputFieldState.neutral,
        FinancialCalculationTarget.periods: InputFieldState.neutral,
        FinancialCalculationTarget.interestRate: InputFieldState.neutral,
        FinancialCalculationTarget.finalValue: InputFieldState.neutral,
      },
      canCalculate: false,
    );
  }

  InputFieldState stateOf(FinancialCalculationTarget field) =>
      fieldStates[field] ?? InputFieldState.neutral;
}