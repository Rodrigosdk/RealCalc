import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/financial_calculation.dart';
import '../../../domain/enum/financial_calculation_target.dart';
import '../../../use_case/financing/i_calculate_financing.dart';

part 'financing_state.dart';

class FinancingCubit extends Cubit<FinancingState> {
  final ICalculateFinancing useCase;

  FinancingCubit(this.useCase) : super(FinancingInitial());

  FinancialCalculationTarget _detectCalculatedField(FinancialCalculation params) {
    if (params.initialValue <= 0) return FinancialCalculationTarget.initialValue;
    if (params.finalValue <= 0) return FinancialCalculationTarget.finalValue;
    if (params.periods <= 0) return FinancialCalculationTarget.periods;
    if (params.rate <= 0) return FinancialCalculationTarget.interestRate;
    return FinancialCalculationTarget.finalValue;
  }

  void calculate(FinancialCalculation params) {
    final calculatedField = _detectCalculatedField(params);
    emit(FinancingLoading());

    final result = useCase.calculate(params);

    result.fold(
      (failure) => emit(FinancingError(failure.message.first.message)),
      (value) => emit(FinancingCalculated(value, calculatedField)),
    );
  }
}
