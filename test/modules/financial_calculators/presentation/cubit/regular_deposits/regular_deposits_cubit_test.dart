import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_calc/core/errors/failures.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/core/seed_works/result.dart';
import 'package:real_calc/modules/financial_calculators/domain/entities/financial_calculation.dart';
import 'package:real_calc/modules/financial_calculators/use_case/regular_deposits/i_calculate_deposit.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/regular_deposits/regular_deposits_cubit.dart';

class MockCalculateDeposit extends Mock implements ICalculateDeposit {}

void main() {
  late ICalculateDeposit mockUseCase;
  late RegularDepositsCubit cubit;

  setUp(() {
    mockUseCase = MockCalculateDeposit();
    cubit = RegularDepositsCubit(mockUseCase);
  });

  tearDown(() {
    cubit.close();
  });

  group('RegularDepositsCubit', () {
    final invalidParameters = FinancialCalculation(
      initialValue: 1,
      periods: 100,
      rate: 1.5,
      finalValue: 1500,
    );

    blocTest<RegularDepositsCubit, RegularDepositsState>(
      'Deve emitir [RegularDepositsLoading, RegularDepositsError] quando o useCase retornar uma falha de validação',
      setUp: () {
        when(() => mockUseCase.calculate(invalidParameters)).thenReturn(
          FailureResult<Failure, FinancialCalculation>(
            ValidationFailure(
              message: [
                RegularDepositsValidationMessage.unableToDetermineCalculationType,
              ],
            ),
          ),
        );
      },
      build: () => cubit,
      act: (cubit) => cubit.calculate(invalidParameters),
      expect: () => [
        isA<RegularDepositsLoading>(),
        isA<RegularDepositsError>().having(
          (e) => e.message,
          'message',
          RegularDepositsValidationMessage.unableToDetermineCalculationType.message,
        ),
      ],
    );

    final paramsForFinalValue = FinancialCalculation(
      initialValue: 100,
      periods: 12,
      rate: 1.5,
      finalValue: 0,
    );

    blocTest<RegularDepositsCubit, RegularDepositsState>(
      'Deve emitir [RegularDepositsLoading, RegularDepositsCalculated] ao calcular o valor final com sucesso',
      setUp: () {
        when(() => mockUseCase.calculate(paramsForFinalValue)).thenReturn(
          SuccessResult<Failure, FinancialCalculation>(paramsForFinalValue.copyWith(finalValue: 1580.50)),
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
        when(() => mockUseCase.calculate(paramsForFinalValue)).thenReturn(
          FailureResult<Failure, FinancialCalculation>(
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
