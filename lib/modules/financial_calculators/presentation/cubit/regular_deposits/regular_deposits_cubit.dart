import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_calc/modules/financial_calculators/use_case/regular_deposits/i_calculate_deposit.dart';

import '../../../domain/entities/financial_calculation.dart';
import '../../../domain/enum/financial_calculation_target.dart';

part 'regular_deposits_state.dart';

class RegularDepositsCubit extends Cubit<RegularDepositsState> {
  final ICalculateDeposit useCase;

  RegularDepositsCubit(this.useCase) : super(RegularDepositsInitial());

  FinancialCalculationTarget _detectCalculatedField(FinancialCalculation params) {
    if (params.initialValue <= 0) return FinancialCalculationTarget.initialValue;
    if (params.finalValue <= 0) return FinancialCalculationTarget.finalValue;
    if (params.periods <= 0) return FinancialCalculationTarget.periods;
    if (params.rate <= 0) return FinancialCalculationTarget.interestRate;
    return FinancialCalculationTarget.finalValue;
  }


  void calculate(FinancialCalculation params) {
    final calculatedField = _detectCalculatedField(params);
    emit(RegularDepositsLoading());

    useCase.calculate(params).fold(
      (failure) => emit(
        RegularDepositsError(
          failure.message.map((error) => error.message).join(', '),
        ),
      ),
      (value) => emit(RegularDepositsCalculated(value, calculatedField)),
    );
  }
}
