import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_calc/modules/financial_calculators/domain/entities/financial_calculation.dart';

import '../../../domain/enum/financial_calculation_target.dart';
import '../../../use_case/future_value/i_calculate_future_value.dart';

part 'future_value_state.dart';

class FutureValueCubit extends Cubit<FutureValueState> {
  final ICalculateFutureValue useCase;

  FutureValueCubit(this.useCase) : super(FutureValueInitial());
  
  FinancialCalculationTarget _detectCalculatedField(FinancialCalculation params) {
    if (params.initialValue <= 0) return FinancialCalculationTarget.initialValue;
    if (params.finalValue <= 0) return FinancialCalculationTarget.finalValue;
    if (params.periods <= 0) return FinancialCalculationTarget.periods;
    if (params.rate <= 0) return FinancialCalculationTarget.interestRate;
    return FinancialCalculationTarget.finalValue;
  }

  void calculate(FinancialCalculation params) {
    final calculatedField = _detectCalculatedField(params);
    emit(FutureValueLoading());

    final result = useCase.calculate(params);

    result.fold(
      (failure) => emit(FutureValueError(failure.message.first.message)),
      (value) => emit(FutureValueCalculated(value, calculatedField)),
    );
  }
}
