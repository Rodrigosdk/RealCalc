import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_calc/core/errors/failures.dart';
import 'package:real_calc/core/seed_works/result.dart';
import 'package:real_calc/modules/regular_deposits/domain/entities/regular_deposit.dart';
import 'package:real_calc/modules/regular_deposits/domain/enum/calculate_regular_deposit_type.dart';
import 'package:real_calc/modules/regular_deposits/domain/usecase/deposit_calculator.dart';
import 'package:real_calc/modules/regular_deposits/domain/validation/regular_deposits_validator.dart';

part 'regular_deposits_state.dart';

class RegularDepositsCubit extends Cubit<RegularDepositsState> {
  final DepositCalculatorUseCase useCase;
  final RegularDepositsValidator validator;

  RegularDepositsCubit(this.useCase, this.validator)
      : super(RegularDepositsInitial());

  void _resultSpecificResponse({
    required CalculateRegularDepositType type,
    required RegularDeposit params,
    required double value,
  }) {
    switch (type) {
      case CalculateRegularDepositType.finalValue:
        emit(RegularDepositsCalculated(params.copyWith(finalValue: value)));
        break;
      case CalculateRegularDepositType.depositAmount:
        emit(RegularDepositsCalculated(params.copyWith(depositAmount: value)));
        break;
      case CalculateRegularDepositType.rate:
        emit(RegularDepositsCalculated(params.copyWith(rate: value)));
        break;
      case CalculateRegularDepositType.months:
        emit(RegularDepositsCalculated(params.copyWith(months: value.toInt())));
        break;
    }
  }

  void calculate(RegularDeposit params) {
    emit(RegularDepositsLoading());

    final emptyFields = <String>[];
    if (params.depositAmount <= 0) emptyFields.add('Valor do depósito');
    if (params.months <= 0) emptyFields.add('Prazo');
    if (params.rate <= 0) emptyFields.add('Taxa de juros');
    if (params.finalValue <= 0) emptyFields.add('Valor final');

    if (emptyFields.isEmpty) {
      emit(RegularDepositsError(
        'Todos os campos estão preenchidos. Deixe em branco o campo que deseja descobrir.',
      ));
      return;
    }

    if (emptyFields.length >= 2) {
      emit(RegularDepositsError(
        'Os seguintes campos não podem ficar vazios: ${emptyFields.join(', ')}.',
      ));
      return;
    }

    final detectedTypeToCalculate = validator.detectTypeCalculation(params);

    detectedTypeToCalculate.fold(
      (failure) {
        final errorMessage = failure.message
            .map((e) => e.toString().split('.').last)
            .join(', ');
        emit(RegularDepositsError(errorMessage));
      },
      (calculationType) {
        late Result<Failure, double> result;

        switch (calculationType) {
          case CalculateRegularDepositType.finalValue:
            result = useCase.calculateFinalValue(params);
            break;
          case CalculateRegularDepositType.depositAmount:
            result = useCase.calculateDepositAmount(params);
            break;
          case CalculateRegularDepositType.rate:
            result = useCase.calculateInterestRate(params);
            break;
          case CalculateRegularDepositType.months:
            result = useCase.calculateNumberOfMonths(params).map(
              (value) => value.toDouble(),
            );
            break;
        }

        if (result.isSuccess) {
          _resultSpecificResponse(
            type: calculationType,
            value: result.getOrNull()!,
            params: params,
          );
        } else {
          final failure = result.getErrorOrNull();
          final errorMessage = failure?.message.map((e) => e.message).join(', ') ??
              'Erro ao calcular';
          emit(RegularDepositsError(errorMessage));
        }
      },
    );
  }
}
