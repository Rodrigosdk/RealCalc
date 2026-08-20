import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_calc/core/errors/failures.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/core/seed_works/result.dart';
import 'package:real_calc/modules/regular_deposits/domain/entities/regular_deposit.dart';
import 'package:real_calc/modules/regular_deposits/domain/enum/calculate_regular_deposit_type.dart';
import 'package:real_calc/modules/regular_deposits/domain/usecase/deposit_calculator.dart';
import 'package:real_calc/modules/regular_deposits/domain/validation/regular_deposits_validator.dart';
import 'package:real_calc/modules/regular_deposits/presentation/cubit/regular_deposits_cubit.dart';

class MockDepositCalculatorUseCase extends Mock implements DepositCalculatorUseCase {}
class MockRegularDepositsValidator extends Mock implements RegularDepositsValidator {}

void main() {
  late DepositCalculatorUseCase mockUseCase;
  late RegularDepositsValidator mockValidator;
  late RegularDepositsCubit cubit;

  setUp(() {
    mockUseCase = MockDepositCalculatorUseCase();
    mockValidator = MockRegularDepositsValidator();
    cubit = RegularDepositsCubit(mockUseCase, mockValidator);
  });

  tearDown(() {
    cubit.close();
  });

  group('RegularDepositsCubit', () {
    blocTest<RegularDepositsCubit, RegularDepositsState>(
      'Deve emitir [RegularDepositsLoading, RegularDepositsError] quando todos os campos possuem valor maior que zero',
      build: () => cubit,
      act: (cubit) => cubit.calculate(RegularDeposit(
        depositAmount: 100,
        months: 12,
        rate: 1.5,
        finalValue: 1500,
      )),
      expect: () => [
        isA<RegularDepositsLoading>(),
        isA<RegularDepositsError>().having(
          (e) => e.message,
          'message',
          'Todos os campos estão preenchidos. Deixe em branco o campo que deseja descobrir.',
        ),
      ],
    );

    final paramsForFinalValue = RegularDeposit(
      depositAmount: 100,
      months: 12,
      rate: 1.5,
      finalValue: 0,
    );

    blocTest<RegularDepositsCubit, RegularDepositsState>(
      'Deve emitir [RegularDepositsLoading, RegularDepositsCalculated] ao calcular o valor final com sucesso',
      setUp: () {
        when(() => mockValidator.detectTypeCalculation(paramsForFinalValue)).thenReturn(
          SuccessResult<Failure, CalculateRegularDepositType>(CalculateRegularDepositType.finalValue),
        );
        when(() => mockUseCase.calculateFinalValue(paramsForFinalValue)).thenReturn(
          SuccessResult<Failure, double>(1580.50),
        );
      },
      build: () => cubit,
      act: (cubit) => cubit.calculate(paramsForFinalValue),
      expect: () => [
        isA<RegularDepositsLoading>(),
        isA<RegularDepositsCalculated>().having(
          (state) => state.value.finalValue,
          'finalValue',
          1580.50,
        ),
      ],
    );

    blocTest<RegularDepositsCubit, RegularDepositsState>(
      'Deve emitir [RegularDepositsLoading, RegularDepositsError] quando o caso de uso falhar',
      setUp: () {
        when(() => mockValidator.detectTypeCalculation(paramsForFinalValue)).thenReturn(
          SuccessResult<Failure, CalculateRegularDepositType>(CalculateRegularDepositType.finalValue),
        );
        when(() => mockUseCase.calculateFinalValue(paramsForFinalValue)).thenReturn(
          FailureResult<Failure, double>(
            ValidationFailure(message: [RegularDepositsValidationMessage.unableToDetermineCalculationType]),
          ),
        );
      },
      build: () => cubit,
      act: (cubit) => cubit.calculate(paramsForFinalValue),
      expect: () => [
        isA<RegularDepositsLoading>(),
        isA<RegularDepositsError>(),
      ],
    );
  });
}
