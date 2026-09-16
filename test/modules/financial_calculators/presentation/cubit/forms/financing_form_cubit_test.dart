import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/modules/financial_calculators/domain/entities/financial_calculation.dart';
import 'package:real_calc/modules/financial_calculators/domain/enum/financial_calculation_target.dart';
import 'package:real_calc/modules/financial_calculators/domain/enum/input_field_state.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/forms/financing_form_cubit.dart';

void main() {
  late FinancingFormCubit cubit;

  setUp(() {
    cubit = FinancingFormCubit();
  });

  tearDown(() async {
    await cubit.close();
  });

  test('remove o estado calculado quando o usuario apaga a taxa', () {
    cubit.applyResult(
      FinancialCalculation(
        initialValue: 5000,
        periods: 12,
        rate: 2,
        finalValue: 500,
      ),
      FinancialCalculationTarget.finalValue,
    );

    expect(cubit.state.calculatedField, FinancialCalculationTarget.finalValue);
    expect(
      cubit.state.stateOf(FinancialCalculationTarget.finalValue),
      InputFieldState.calculated,
    );

    cubit.rate.clear();

    expect(cubit.state.calculatedField, isNull);
    expect(
      cubit.state.stateOf(FinancialCalculationTarget.finalValue),
      InputFieldState.neutral,
    );
    expect(
      cubit.state.stateOf(FinancialCalculationTarget.interestRate),
      InputFieldState.highlighted,
    );
  });
}
