import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_calc/modules/future_value/domain/entities/future_value.dart';
import 'package:real_calc/modules/future_value/domain/enum/future_value_type.dart';
import 'package:real_calc/modules/future_value/domain/usecase/calculate_compound_interest_use_case.dart';
import 'package:real_calc/modules/future_value/domain/validation/future_value_validator.dart';

part 'future_value_state.dart';

class FutureValueCubit extends Cubit<FutureValueState> {
  final CalculateCompoundInterestUseCase useCase;
  final FutureValueValidator validator;

  FutureValueCubit(this.useCase, this.validator) : super(FutureValueInitial());

  void _resultSpecificResponse({
    required FutureValueType type,
    required FutureValue params,
    required double value,
  }) {
    switch (type) {
      case FutureValueType.finalValue:
        emit(FutureValueCalculated(params.copyWith(finalValue: value)));
        break;
      case FutureValueType.capital:
        emit(FutureValueCalculated(params.copyWith(capital: value)));
        break;
      case FutureValueType.interestRate:
        emit(FutureValueCalculated(params.copyWith(interestRate: value)));
        break;
      case FutureValueType.months:
        emit(FutureValueCalculated(params.copyWith(months: value.toInt())));
        break;
    }
  }

  void calculate(FutureValue params) {
    emit(FutureValueLoading());

    final emptyFields = <String>[];
    if ((params.capital ?? 0) <= 0) emptyFields.add('Capital');
    if ((params.months ?? 0) <= 0) emptyFields.add('Prazo');
    if ((params.interestRate ?? 0) <= 0) emptyFields.add('Taxa de juros');
    if ((params.finalValue ?? 0) <= 0) emptyFields.add('Valor final');

    if (emptyFields.isEmpty) {
      emit(FutureValueError(
        'Todos os campos estão preenchidos. Deixe em branco o campo que deseja descobrir.',
      ));
      return;
    }

    if (emptyFields.length >= 2) {
      emit(FutureValueError(
        'Os seguintes campos não podem ficar vazios: ${emptyFields.join(', ')}.',
      ));
      return;
    }

    final detectedType = validator.detectTypeCalculation(params);

    detectedType.fold(
      (failure) {
        final errorMessage = failure.message.map((e) => e.toString().split('.').last).join(', ');
        emit(FutureValueError(errorMessage));
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
          emit(FutureValueError(errorMessage));
        }
      },
    );
  }
}
