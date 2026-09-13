import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_calc/core/errors/failures.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/core/seed_works/result.dart';
import 'package:real_calc/modules/financial_calculators/domain/entities/financial_calculation.dart';
import 'package:real_calc/modules/financial_calculators/use_case/future_value/i_calculate_future_value.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/future_value/future_value_cubit.dart';

class MockCalculateFutureValue extends Mock implements ICalculateFutureValue {}

void main() {
  late ICalculateFutureValue mockUseCase;
  late FutureValueCubit cubit;

  setUp(() {
    mockUseCase = MockCalculateFutureValue();
    cubit = FutureValueCubit(mockUseCase);
  });

  tearDown(() {
    cubit.close();
  });

  group('FutureValueCubit - Testes Unitários de Cálculo', () {
    final futureWithInvalidParameters = FinancialCalculation(
      initialValue: 5000,
      periods: 12,
      rate: 2.0,
      finalValue: 450,
    );

    blocTest<FutureValueCubit, FutureValueState>(
      'Deve emitir [FutureValueLoading, FutureValueError] quando o useCase retornar uma falha de validação',
      setUp: () {
        when(() => mockUseCase.calculate(futureWithInvalidParameters))
            .thenReturn(
          FailureResult<Failure, FinancialCalculation>(
            ValidationFailure(
              message: [
                FutureValueValidationMessage.unableToDetermineCalculationType,
              ],
            ),
          ),
        );
      },
      build: () => cubit,
      act: (cubit) => cubit.calculate(futureWithInvalidParameters),
      expect: () => [
        isA<FutureValueLoading>(),
        isA<FutureValueError>().having(
          (e) => e.message,
          'message',
          FutureValueValidationMessage.unableToDetermineCalculationType.message,
        ),
      ],
    );

    final futureWithMissingParameters = FinancialCalculation(
      initialValue: 10000,
      periods: 0,
      rate: 0,
      finalValue: 0,
    );

    blocTest<FutureValueCubit, FutureValueState>(
      'Deve emitir [FutureValueLoading, FutureValueError] quando faltarem parâmetros para o cálculo',
      setUp: () {
        when(() => mockUseCase.calculate(futureWithMissingParameters))
            .thenReturn(
          FailureResult<Failure, FinancialCalculation>(
            ValidationFailure(
              message: [
                FutureValueValidationMessage.unableToDetermineCalculationType,
              ],
            ),
          ),
        );
      },
      build: () => cubit,
      act: (cubit) => cubit.calculate(futureWithMissingParameters),
      expect: () => [
        isA<FutureValueLoading>(),
        isA<FutureValueError>().having(
          (e) => e.message,
          'message',
          FutureValueValidationMessage.unableToDetermineCalculationType.message,
        ),
      ],
    );

    final futureForFinalValue = FinancialCalculation(initialValue: 10000, periods: 12, rate: 1.5, finalValue: 0);

    blocTest<FutureValueCubit, FutureValueState>(
      'Deve emitir [FutureValueLoading, FutureValueCalculated] com o finalValue atualizado quando o useCase calcular com sucesso',
      setUp: () {
        when(() => mockUseCase.calculate(futureForFinalValue)).thenReturn(
          SuccessResult<Failure, FinancialCalculation>(futureForFinalValue.copyWith(finalValue: 1180.50)),
        );
      },
      build: () => cubit,
      act: (cubit) => cubit.calculate(futureForFinalValue),
      expect: () => [
        isA<FutureValueLoading>(),
        isA<FutureValueCalculated>().having((s) => s.value.finalValue, 'finalValue', 1180.50),
      ],
    );

    final futureForMonths = FinancialCalculation(initialValue: 5000, periods: 0, rate: 2.0, finalValue: 6000);

    blocTest<FutureValueCubit, FutureValueState>(
      'Deve emitir [FutureValueLoading, FutureValueCalculated] convertendo o retorno double do UseCase para int quando calcular meses',
      setUp: () {
        when(() => mockUseCase.calculate(futureForMonths)).thenReturn(
          SuccessResult<Failure, FinancialCalculation>(futureForMonths.copyWith(periods: 9)),
        );
      },
      build: () => cubit,
      act: (cubit) => cubit.calculate(futureForMonths),
      expect: () => [
        isA<FutureValueLoading>(),
        isA<FutureValueCalculated>().having((s) => s.value.periods, 'periods', 9),
      ],
    );

    blocTest<FutureValueCubit, FutureValueState>(
      'Deve emitir [FutureValueLoading, FutureValueError] mapeando os erros caso o UseCase retorne uma falha',
      setUp: () {
        when(() => mockUseCase.calculate(futureForFinalValue)).thenReturn(
          FailureResult<Failure, FinancialCalculation>(
            ValidationFailure(message: [FutureValueValidationMessage.unableToDetermineCalculationType]),
          ),
        );
      },
      build: () => cubit,
      act: (cubit) => cubit.calculate(futureForFinalValue),
      expect: () => [
        isA<FutureValueLoading>(),
        isA<FutureValueError>(),
      ],
    );
  });
}
