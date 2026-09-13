import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_calc/core/errors/failures.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/core/seed_works/result.dart';
import 'package:real_calc/modules/financial_calculators/domain/entities/financial_calculation.dart';
import 'package:real_calc/modules/financial_calculators/domain/enum/financial_calculation_target.dart';
import 'package:real_calc/modules/financial_calculators/use_case/financing/i_calculate_financing.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/financing/financing_cubit.dart'; // Ajuste o import do seu cubit

class MockCalculateFinancing extends Mock implements ICalculateFinancing {}

void main() {
  late ICalculateFinancing mockUseCase;
  late FinancingCubit cubit;

  setUp(() {
    mockUseCase = MockCalculateFinancing();
    cubit = FinancingCubit(mockUseCase);
  });

  tearDown(() {
    cubit.close();
  });

  group('FinancingCubit - Testes Unitários de Cálculo', () {
    
    final financingWithInvalidParameters = FinancialCalculation(
      initialValue: 5000,
      periods: 12,
      rate: 2.0,
      finalValue: 450,
    );

    blocTest<FinancingCubit, FinancingState>(
      'Deve emitir [FinancingLoading, FinancingError] quando o useCase retornar uma falha de validação',
      setUp: () {
        when(() => mockUseCase.calculate(financingWithInvalidParameters))
            .thenReturn(
          FailureResult<Failure, FinancialCalculation>(
            ValidationFailure(
              message: [
                FinancingValidationMessage.unableToDetermineCalculationType,
              ],
            ),
          ),
        );
      },
      build: () => cubit,
      act: (cubit) => cubit.calculate(financingWithInvalidParameters),
      expect: () => [
        isA<FinancingLoading>(),
        isA<FinancingError>().having(
          (e) => e.message,
          'message',
          FinancingValidationMessage.unableToDetermineCalculationType.message,
        ),
      ],
    );

    final financingWithMissingParameters = FinancialCalculation(
      initialValue: 10000,
      periods: 0,
      rate: 0,
      finalValue: 0,
    );

    blocTest<FinancingCubit, FinancingState>(
      'Deve emitir [FinancingLoading, FinancingError] quando faltarem parâmetros para o cálculo',
      setUp: () {
        when(() => mockUseCase.calculate(financingWithMissingParameters))
            .thenReturn(
          FailureResult<Failure, FinancialCalculation>(
            ValidationFailure(
              message: [
                FinancingValidationMessage.unableToDetermineCalculationType,
              ],
            ),
          ),
        );
      },
      build: () => cubit,
      act: (cubit) => cubit.calculate(financingWithMissingParameters),
      expect: () => [
        isA<FinancingLoading>(),
        isA<FinancingError>().having(
          (e) => e.message,
          'message',
          FinancingValidationMessage.unableToDetermineCalculationType.message,
        ),
      ],
    );

    final financingForFinalValue = FinancialCalculation(initialValue: 10000, periods: 12, rate: 1.5, finalValue: 0);
    
    blocTest<FinancingCubit, FinancingState>(
      'Deve emitir [FinancingLoading, FinancingCalculated] com o finalValue atualizado quando o useCase calcular com sucesso',
      setUp: () {
        when(() => mockUseCase.calculate(financingForFinalValue)).thenReturn(
          SuccessResult<Failure, FinancialCalculation>(financingForFinalValue.copyWith(finalValue: 1180.50)),
        );
      },
      build: () => cubit,
      act: (cubit) => cubit.calculate(financingForFinalValue),
      expect: () => [
        isA<FinancingLoading>(),
        isA<FinancingCalculated>().having(
          (s) => s.value.finalValue,
          'finalValue',
          1180.50,
        ).having(
          (s) => s.calculatedField,
          'calculatedField',
          FinancialCalculationTarget.finalValue,
        ),
      ],
    );

    final financingForMonths = FinancialCalculation(initialValue: 5000, periods: 0, rate: 2.0, finalValue: 6000);
    
    blocTest<FinancingCubit, FinancingState>(
      'Deve emitir [FinancingLoading, FinancingCalculated] convertendo o retorno double do UseCase para int quando calcular meses',
      setUp: () {
        when(() => mockUseCase.calculate(financingForMonths)).thenReturn(
          SuccessResult<Failure, FinancialCalculation>(financingForMonths.copyWith(periods: 9)),
        );
      },
      build: () => cubit,
      act: (cubit) => cubit.calculate(financingForMonths),
      expect: () => [
        isA<FinancingLoading>(),
        isA<FinancingCalculated>().having(
          (s) => s.value.periods,
          'periods',
          9, // Verifica se o .toInt() do switch funcionou
        ).having(
          (s) => s.calculatedField,
          'calculatedField',
          FinancialCalculationTarget.periods,
        ),
      ],
    );

    blocTest<FinancingCubit, FinancingState>(
      'Deve emitir [FinancingLoading, FinancingError] mapeando os erros caso o UseCase retorne uma falha',
      setUp: () {
        when(() => mockUseCase.calculate(financingForFinalValue)).thenReturn(
          FailureResult<Failure, FinancialCalculation>(
            ValidationFailure(message: [FinancingValidationMessage.unableToDetermineCalculationType]),
          ),
        );
      },
      build: () => cubit,
      act: (cubit) => cubit.calculate(financingForFinalValue),
      expect: () => [
        isA<FinancingLoading>(),
        isA<FinancingError>(),
      ],
    );
  });
}
