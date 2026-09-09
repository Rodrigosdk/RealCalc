import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/financial_calculation.dart';
import '../../../use_case/financing/i_calculate_financing.dart';

part 'financing_state.dart';

class FinancingCubit extends Cubit<FinancingState> {
  final ICalculateFinancing useCase;

  FinancingCubit(this.useCase) : super(FinancingInitial());

  void calculate(FinancialCalculation params) {
    emit(FinancingLoading());

    final result = useCase.calculate(params);

    result.fold(
      (failure) => emit(FinancingError(failure.message.first.message)),
      (value) => emit(FinancingCalculated(value)),
    );
  }
}
