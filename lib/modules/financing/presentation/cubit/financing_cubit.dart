import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_calc/modules/financing/domain/entities/financing.dart';
import 'package:real_calc/modules/financing/domain/enum/calculate_financing_type.dart';
import 'package:real_calc/modules/financing/domain/usecases/calculate_compound_interest_use_case.dart';
import 'package:real_calc/modules/financing/domain/validation/financing_validator.dart';

part 'financing_state.dart';

class FinancingCubit extends Cubit<FinancingState> {
  final CalculateCompoundInterestUseCase useCase;
  final FinancingValidator validator;

  FinancingCubit(this.useCase, this.validator) : super(FinancingInitial());

  void _resultSpecificResponse({
    required CalculateFinancingType type,
    required Financing params,
    required double value,
  }) {
    switch (type) {
      case CalculateFinancingType.finalValue:
        emit(FinancingCalculated(params.copyWith(finalValue: value)));
        break;
      case CalculateFinancingType.initialValue:
        emit(FinancingCalculated(params.copyWith(initialValue: value)));
        break;
      case CalculateFinancingType.rate:
        emit(FinancingCalculated(params.copyWith(rate: value)));
        break;
      case CalculateFinancingType.months:
        emit(FinancingCalculated(params.copyWith(months: value.toInt())));
        break;
    }
  }

  void calculate(Financing params) {
    emit(FinancingLoading());

    // 1. Mapeia quais campos estão vazios baseado nos valores recebidos da UI
    final emptyFields = <String>[];
    if (params.initialValue <= 0) emptyFields.add('Valor financiado');
    if (params.months <= 0) emptyFields.add('Prazo');
    if (params.rate <= 0) emptyFields.add('Taxa de juros');
    if (params.finalValue <= 0) emptyFields.add('Valor da prestação');

    if (emptyFields.isEmpty) {
      emit(FinancingError(
        'Todos os campos estão preenchidos. Deixe em branco o campo que deseja descobrir.',
      ));
      return;
    }

    if (emptyFields.length >= 2) {
      emit(FinancingError(
        'Os seguintes campos não podem ficar vazios: ${emptyFields.join(', ')}.',
      ));
      return;
    }

    final detectedTypeToCalculate = validator.detectTypeCalculation(params);

    detectedTypeToCalculate.fold(
      (failure) {
        final errorMessage = failure.message.map((e) => e.toString().split('.').last).join(', ');
        emit(FinancingError(errorMessage));
      },
      (calculationType) {
        final result = useCase.calculate(params);

        if (result.isSuccess) {
          _resultSpecificResponse(
            type: calculationType,
            value: result.getOrNull()!,
            params: params,
          );
        } else {
          final failure = result.getErrorOrNull();
          final errorMessage = failure?.message.map((e) => e.message).join(', ') ?? 'Erro ao calcular';
          emit(FinancingError(errorMessage));
        }
      },
    );
  }
}
