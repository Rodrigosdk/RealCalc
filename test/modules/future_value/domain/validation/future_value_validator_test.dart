import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/modules/future_value/domain/entities/future_value.dart';
import 'package:real_calc/modules/future_value/domain/enum/future_value_type.dart';
import 'package:real_calc/modules/future_value/domain/validation/future_value_validator.dart';

void main() {
  late FutureValueValidator validator;

  setUp(() {
    validator = FutureValueValidator();
  });

  FutureValue buildEntity({
    double? capital,
    double? finalValue,
    double? interestRate,
    int? months,
  }) {
    return FutureValue(
      capital: capital ?? 1000.0,
      finalValue: finalValue ?? 1100.0,
      interestRate: interestRate ?? 0.1,
      months: months ?? 12,
    );
  }

  group('FutureValueValidator', () {
    group('validateForCapital', () {
      test('Deve retornar sucesso quando finalValue, interestRate e months forem válidos', () {
        final entity = buildEntity(capital: 0);
        final result = validator.validateForCapital(entity);

        expect(result.isSuccess, isTrue);
        expect(result.getOrNull()?.finalValue, 1100.0);
      });

      test('Deve retornar erro quando finalValue for inválido', () {
        final entity = FutureValue(capital: 1000, finalValue: 0, interestRate: 0.1, months: 12);
        final result = validator.validateForCapital(entity);

        expect(result.isError, isTrue);
        expect(
          result.getErrorOrNull()?.message,
          contains(FutureValueValidationMessage.positiveFinalValue),
        );
      });
    });

    group('validateForFinalValue', () {
      test('Deve retornar sucesso quando capital, interestRate e months forem válidos', () {
        final entity = buildEntity(finalValue: 0);
        final result = validator.validateForFinalValue(entity);

        expect(result.isSuccess, isTrue);
        expect(result.getOrNull()?.capital, 1000.0);
      });

      test('Deve retornar erro quando capital for inválido', () {
        final entity = FutureValue(capital: 0, finalValue: 1100, interestRate: 0.1, months: 12);
        final result = validator.validateForFinalValue(entity);

        expect(result.isError, isTrue);
        expect(
          result.getErrorOrNull()?.message,
          contains(FutureValueValidationMessage.positiveCapital),
        );
      });
    });

    group('validateForInterestRate', () {
      test('Deve retornar sucesso quando capital, finalValue e months forem válidos', () {
        final entity = buildEntity(interestRate: 0);
        final result = validator.validateForInterestRate(entity);

        expect(result.isSuccess, isTrue);
        expect(result.getOrNull()?.months, 12);
      });

      test('Deve retornar erro quando finalValue for inválido', () {
        final entity = FutureValue(capital: 1000, finalValue: 0, interestRate: 0.1, months: 12);
        final result = validator.validateForInterestRate(entity);

        expect(result.isError, isTrue);
        expect(
          result.getErrorOrNull()?.message,
          contains(FutureValueValidationMessage.positiveFinalValue),
        );
      });
    });

    group('validateForMonths', () {
      test('Deve retornar sucesso quando capital, finalValue e interestRate forem válidos', () {
        final entity = buildEntity(months: 0);
        final result = validator.validateForMonths(entity);

        expect(result.isSuccess, isTrue);
        expect(result.getOrNull()?.interestRate, 0.1);
      });

      test('Deve retornar erro quando interestRate for inválido', () {
        final entity = FutureValue(capital: 1000, finalValue: 1100, interestRate: 0, months: 12);
        final result = validator.validateForMonths(entity);

        expect(result.isError, isTrue);
        expect(
          result.getErrorOrNull()?.message,
          contains(FutureValueValidationMessage.positiveInterestRate),
        );
      });
    });

    group('detectTypeCalculation', () {
      test('Deve detectar cálculo de capital quando capital estiver faltando', () {
        final entity = buildEntity(capital: 0);
        final result = validator.detectTypeCalculation(entity);

        expect(result.isSuccess, isTrue);
        expect(result.getOrNull(), FutureValueType.capital);
      });

      test('Deve detectar cálculo de interestRate quando interestRate estiver faltando', () {
        final entity = buildEntity(interestRate: 0);
        final result = validator.detectTypeCalculation(entity);

        expect(result.isSuccess, isTrue);
        expect(result.getOrNull(), FutureValueType.interestRate);
      });

      test('Deve detectar cálculo de months quando months estiver faltando', () {
        final entity = buildEntity(months: 0);
        final result = validator.detectTypeCalculation(entity);

        expect(result.isSuccess, isTrue);
        expect(result.getOrNull(), FutureValueType.months);
      });

      test('Deve detectar cálculo de finalValue quando finalValue estiver faltando', () {
        final entity = buildEntity(finalValue: 0);
        final result = validator.detectTypeCalculation(entity);

        expect(result.isSuccess, isTrue);
        expect(result.getOrNull(), FutureValueType.finalValue);
      });

      test('Deve retornar erro quando os parâmetros forem inválidos', () {
        final entity = FutureValue();
        final result = validator.detectTypeCalculation(entity);

        expect(result.isError, isTrue);
        expect(
          result.getErrorOrNull()?.message,
          contains(FutureValueValidationMessage.unableToDetermineCalculationType),
        );
      });
    });
  });
}
