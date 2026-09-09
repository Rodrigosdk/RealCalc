import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_calc/modules/financial_calculators/use_case/regular_deposits/i_calculate_deposit.dart';

import '../../../domain/entities/financial_calculation.dart';

part 'regular_deposits_state.dart';

class RegularDepositsCubit extends Cubit<RegularDepositsState> {
  final ICalculateDeposit useCase;

  RegularDepositsCubit(this.useCase) : super(RegularDepositsInitial());

  void calculate(FinancialCalculation params) {
    emit(RegularDepositsLoading());

    useCase.calculate(params).fold(
      (failure) => emit(
        RegularDepositsError(
          failure.message.map((error) => error.message).join(', '),
        ),
      ),
      (value) => emit(RegularDepositsCalculated(value)),
    );
  }
}
