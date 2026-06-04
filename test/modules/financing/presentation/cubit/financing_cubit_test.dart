import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_calc/core/errors/failures.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/core/seed_works/result.dart';
import 'package:real_calc/modules/financing/domain/entities/financing.dart';
import 'package:real_calc/modules/financing/domain/enum/calculate_financing_type.dart';
import 'package:real_calc/modules/financing/domain/usecases/calculate_compound_interest_use_case.dart';
import 'package:real_calc/modules/financing/domain/validation/financing_validator.dart';
import 'package:real_calc/modules/financing/presentation/cubit/financing_cubit.dart'; // Ajuste o import do seu cubit

class MockCalculateCompoundInterestUseCase extends Mock implements CalculateCompoundInterestUseCase {}
class MockFinancingValidator extends Mock implements FinancingValidator {}

void main() {
  late CalculateCompoundInterestUseCase mockUseCase;
  late FinancingValidator mockValidator;
  late FinancingCubit cubit;

  setUp(() {
    mockUseCase = MockCalculateCompoundInterestUseCase();
    mockValidator = MockFinancingValidator();
    cubit = FinancingCubit(mockUseCase, mockValidator);
  });

  tearDown(() {
    cubit.close();
  });

  group('FinancingCubit - Testes Unitários de Cálculo', () {
    
    blocTest<FinancingCubit, FinancingState>(
      'Deve emitir [FinancingLoading, FinancingError] quando todos os campos possuem valor maior que zero',
      build: () => cubit,
      act: (cubit) => cubit.calculate(Financing(
        initialValue: 5000,
        months: 12,
        rate: 2.0,
        finalValue: 450,
      )),
      expect: () => [
        isA<FinancingLoading>(),
        isA<FinancingError>().having(
          (e) => e.message,
          'message',
          'Todos os campos estão preenchidos. Deixe em branco o campo que deseja descobrir.',
        ),
      ],
    );

    blocTest<FinancingCubit, FinancingState>(
      'Deve emitir [FinancingLoading, FinancingError] listando os campos que faltam quando 2 ou mais estão vazios',
      build: () => cubit,
      act: (cubit) => cubit.calculate(Financing(
        initialValue: 10000,
        months: 0,
        rate: 0,
        finalValue: 0,
      )),
      expect: () => [
        isA<FinancingLoading>(),
        isA<FinancingError>().having(
          (e) => e.message,
          'message',
          'Os seguintes campos não podem ficar vazios: Prazo, Taxa de juros, Valor da prestação.',
        ),
      ],
    );

    final financingForFinalValue = Financing(initialValue: 10000, months: 12, rate: 1.5, finalValue: 0);
    
    blocTest<FinancingCubit, FinancingState>(
      'Deve emitir [FinancingLoading, FinancingCalculated] com o finalValue atualizado quando o useCase calcular com sucesso',
      setUp: () {
        when(() => mockValidator.detectTypeCalculation(financingForFinalValue)).thenReturn(
          SuccessResult<Failure, CalculateFinancingType>(CalculateFinancingType.finalValue),
        );
        when(() => mockUseCase.calculate(financingForFinalValue)).thenReturn(
          SuccessResult<Failure, double>(1180.50),
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
        ),
      ],
    );

    final financingForMonths = Financing(initialValue: 5000, months: 0, rate: 2.0, finalValue: 6000);
    
    blocTest<FinancingCubit, FinancingState>(
      'Deve emitir [FinancingLoading, FinancingCalculated] convertendo o retorno double do UseCase para int quando calcular meses',
      setUp: () {
        when(() => mockValidator.detectTypeCalculation(financingForMonths)).thenReturn(
          SuccessResult<Failure, CalculateFinancingType>(CalculateFinancingType.months),
        );
        when(() => mockUseCase.calculate(financingForMonths)).thenReturn(
          SuccessResult<Failure, double>(9.2), // O UseCase matemático retorna double
        );
      },
      build: () => cubit,
      act: (cubit) => cubit.calculate(financingForMonths),
      expect: () => [
        isA<FinancingLoading>(),
        isA<FinancingCalculated>().having(
          (s) => s.value.months,
          'months',
          9, // Verifica se o .toInt() do switch funcionou
        ),
      ],
    );

    blocTest<FinancingCubit, FinancingState>(
      'Deve emitir [FinancingLoading, FinancingError] mapeando os erros caso o UseCase retorne uma falha',
      setUp: () {
        when(() => mockValidator.detectTypeCalculation(financingForFinalValue)).thenReturn(
          SuccessResult<Failure, CalculateFinancingType>(CalculateFinancingType.finalValue),
        );
        when(() => mockUseCase.calculate(financingForFinalValue)).thenReturn(
          FailureResult<Failure, double>(
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
