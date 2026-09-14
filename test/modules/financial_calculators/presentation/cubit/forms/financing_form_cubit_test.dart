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

  test('preserva tres casas na taxa ao aplicar o resultado', () {
    cubit.applyResult(
      FinancialCalculation(
        initialValue: 5000,
        periods: 12,
        rate: 0.137,
        finalValue: 5082.5,
      ),
      FinancialCalculationTarget.finalValue,
    );

    expect(cubit.rate.text, '0,137');
    expect(cubit.finalValue.text, '5.082,50');
  });

  test('preserva quatro casas na taxa ao aplicar o resultado', () {
    cubit.applyResult(
      FinancialCalculation(
        initialValue: 5000,
        periods: 12,
        rate: 0.0137,
        finalValue: 5000.82,
      ),
      FinancialCalculationTarget.finalValue,
    );

    expect(cubit.rate.text, '0,0137');
    expect(cubit.finalValue.text, '5.000,82');
  });
}
