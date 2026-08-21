import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_calc/core/errors/failures.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/core/seed_works/result.dart';
import 'package:real_calc/modules/future_value/domain/entities/future_value.dart';
import 'package:real_calc/modules/future_value/domain/enum/future_value_type.dart';
import 'package:real_calc/modules/future_value/domain/usecase/calculate_compound_interest_use_case.dart';
import 'package:real_calc/modules/future_value/domain/validation/future_value_validator.dart';
import 'package:real_calc/modules/future_value/presentation/cubit/future_value_cubit.dart';

class MockCalculateCompoundInterestUseCase extends Mock implements CalculateCompoundInterestUseCase {}
class MockFutureValueValidator extends Mock implements FutureValueValidator {}

void main() {
  late CalculateCompoundInterestUseCase mockUseCase;
  late FutureValueValidator mockValidator;
  late FutureValueCubit cubit;

  setUp(() {
    mockUseCase = MockCalculateCompoundInterestUseCase();
    mockValidator = MockFutureValueValidator();
    cubit = FutureValueCubit(mockUseCase, mockValidator);
  });

  tearDown(() {
    cubit.close();
  });

  group('FutureValueCubit - Testes Unitários de Cálculo', () {
    blocTest<FutureValueCubit, FutureValueState>(
      'Deve emitir [FutureValueLoading, FutureValueError] quando todos os campos possuem valor maior que zero',
      build: () => cubit,
      act: (cubit) => cubit.calculate(FutureValue(capital: 5000, months: 12, interestRate: 2.0, finalValue: 450)),
      expect: () => [
        isA<FutureValueLoading>(),
        isA<FutureValueError>().having((e) => e.message, 'message', 'Todos os campos estão preenchidos. Deixe em branco o campo que deseja descobrir.'),
      ],
    );

    blocTest<FutureValueCubit, FutureValueState>(
      'Deve emitir [FutureValueLoading, FutureValueError] listando os campos que faltam quando 2 ou mais estão vazios',
      build: () => cubit,
      act: (cubit) => cubit.calculate(FutureValue(capital: 10000, months: 0, interestRate: 0, finalValue: 0)),
      expect: () => [
        isA<FutureValueLoading>(),
        isA<FutureValueError>().having((e) => e.message, 'message', 'Os seguintes campos não podem ficar vazios: Prazo, Taxa de juros, Valor final.'),
      ],
    );

    final futureForFinalValue = FutureValue(capital: 10000, months: 12, interestRate: 1.5, finalValue: 0);

    blocTest<FutureValueCubit, FutureValueState>(
      'Deve emitir [FutureValueLoading, FutureValueCalculated] com o finalValue atualizado quando o useCase calcular com sucesso',
      setUp: () {
        when(() => mockValidator.detectTypeCalculation(futureForFinalValue)).thenReturn(
          SuccessResult<Failure, FutureValueType>(FutureValueType.finalValue),
        );
        when(() => mockUseCase.calculate(futureForFinalValue)).thenReturn(
          SuccessResult<Failure, double>(1180.50),
        );
      },
      build: () => cubit,
      act: (cubit) => cubit.calculate(futureForFinalValue),
      expect: () => [
        isA<FutureValueLoading>(),
        isA<FutureValueCalculated>().having((s) => s.value.finalValue, 'finalValue', 1180.50),
      ],
    );

    final futureForMonths = FutureValue(capital: 5000, months: 0, interestRate: 2.0, finalValue: 6000);

    blocTest<FutureValueCubit, FutureValueState>(
      'Deve emitir [FutureValueLoading, FutureValueCalculated] convertendo o retorno double do UseCase para int quando calcular meses',
      setUp: () {
        when(() => mockValidator.detectTypeCalculation(futureForMonths)).thenReturn(
          SuccessResult<Failure, FutureValueType>(FutureValueType.months),
        );
        when(() => mockUseCase.calculate(futureForMonths)).thenReturn(
          SuccessResult<Failure, double>(9.2),
        );
      },
      build: () => cubit,
      act: (cubit) => cubit.calculate(futureForMonths),
      expect: () => [
        isA<FutureValueLoading>(),
        isA<FutureValueCalculated>().having((s) => s.value.months, 'months', 9),
      ],
    );

    blocTest<FutureValueCubit, FutureValueState>(
      'Deve emitir [FutureValueLoading, FutureValueError] mapeando os erros caso o UseCase retorne uma falha',
      setUp: () {
        when(() => mockValidator.detectTypeCalculation(futureForFinalValue)).thenReturn(
          SuccessResult<Failure, FutureValueType>(FutureValueType.finalValue),
        );
        when(() => mockUseCase.calculate(futureForFinalValue)).thenReturn(
          FailureResult<Failure, double>(
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
