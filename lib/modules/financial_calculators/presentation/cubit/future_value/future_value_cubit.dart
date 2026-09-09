import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_calc/modules/financial_calculators/domain/entities/financial_calculation.dart';

import '../../../use_case/future_value/i_calculate_future_value.dart';

part 'future_value_state.dart';

class FutureValueCubit extends Cubit<FutureValueState> {
  final ICalculateFutureValue useCase;

  FutureValueCubit(this.useCase) : super(FutureValueInitial());

  void calculate(FinancialCalculation params) {
    emit(FutureValueLoading());

    final result = useCase.calculate(params);

    result.fold(
      (failure) => emit(FutureValueError(failure.message.first.message)),
      (value) => emit(FutureValueCalculated(value)),
    );
  }
}
