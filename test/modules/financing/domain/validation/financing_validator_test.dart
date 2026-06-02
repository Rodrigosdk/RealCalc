import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/modules/financing/domain/entities/financing.dart';
import 'package:real_calc/modules/financing/domain/enum/calculate_financing_type.dart';
import 'package:real_calc/modules/financing/domain/validation/financing_validator.dart';

void main() {
  late FinancingValidator validator;

  setUp(() {
    validator = FinancingValidator();
  });

  Financing buildFinancingValido({
    double? initialValue,
    double? finalValue,
    double? rate,
    int? months,
  }) {
    return Financing(
      initialValue: initialValue ?? 1000,
      finalValue: finalValue ?? 1200,
      rate: rate ?? 5,
      months: months ?? 12,
    );
  }

  group('FinancingValidator', () {
    group('validateForFinalValue', () {
      test(
        'Deve retornar sucesso quando initialValue, rate e months forem válidos',
        () {
          final financing = buildFinancingValido(finalValue: 0);
          final result = validator.validateForFinalValue(financing);

          expect(result.isSuccess, isTrue);
          expect(result.getOrNull()?.initialValue, 1000);
        },
      );

      test(
        'Deve retornar erro quando campos obrigatórios estiverem inválidos',
        () {
          final financing = Financing(
            initialValue: 0,
            finalValue: 1000,
            rate: 0,
            months: 0,
          );

          final result = validator.validateForFinalValue(financing);

          expect(result.isError, isTrue);
          expect(
            result.getErrorOrNull()?.message,
            containsAll([
              FinancingValidationMessage.positiveInitialValue,
              FinancingValidationMessage.positiveRate,
              FinancingValidationMessage.positiveMonths,
            ]),
          );
        },
      );
    });

    group('validateForRate', () {
      test(
        'Deve retornar sucesso quando initialValue, finalValue e months forem válidos',
        () {
          final financing = buildFinancingValido(rate: 0);
          final result = validator.validateForRate(financing);

          expect(result.isSuccess, isTrue);
          expect(result.getOrNull()?.finalValue, 1200);
        },
      );

      test('Deve retornar erro quando finalValue for inválido', () {
        final financing = Financing(
          initialValue: 1000,
          finalValue: 0,
          rate: 5,
          months: 12,
        );

        final result = validator.validateForRate(financing);

        expect(result.isError, isTrue);
        expect(
          result.getErrorOrNull()?.message,
          contains(FinancingValidationMessage.positiveFinalValue),
        );
      });
    });

    group('validateForMonths', () {
      test(
        'Deve retornar sucesso quando initialValue, finalValue e rate forem válidos',
        () {
          final financing = buildFinancingValido(months: 0);
          final result = validator.validateForMonths(financing);

          expect(result.isSuccess, isTrue);
          expect(result.getOrNull()?.rate, 5);
        },
      );

      test('Deve retornar erro quando rate for inválido', () {
        final financing = Financing(
          initialValue: 1000,
          finalValue: 1200,
          rate: 0,
          months: 12,
        );

        final result = validator.validateForMonths(financing);

        expect(result.isError, isTrue);
        expect(
          result.getErrorOrNull()?.message,
          contains(FinancingValidationMessage.positiveRate),
        );
      });
    });

    group('validateForInitialValue', () {
      test(
        'Deve retornar sucesso quando finalValue, rate e months forem válidos',
        () {
          final financing = buildFinancingValido(initialValue: 0);
          final result = validator.validateForInitialValue(financing);

          expect(result.isSuccess, isTrue);
          expect(result.getOrNull()?.months, 12);
        },
      );

      test('Deve retornar erro quando finalValue for inválido', () {
        final financing = Financing(
          initialValue: 1000,
          finalValue: 0,
          rate: 5,
          months: 12,
        );

        final result = validator.validateForInitialValue(financing);

        expect(result.isError, isTrue);
        expect(
          result.getErrorOrNull()?.message,
          contains(FinancingValidationMessage.positiveFinalValue),
        );
      });
    });

    group('detectTypeCalculation', () {
      test(
        'Deve retornar o tipo de cálculo correto quando os parâmetros forem válidos',
        () {
          final financing = buildFinancingValido(finalValue: 0);
          final result = validator.detectTypeCalculation(financing);

          expect(result.isSuccess, isTrue);
          expect(result.getOrNull(), CalculateFinancingType.finalValue);
        },
      );
      test('Deve retornar erro quando os parâmetros forem inválidos', () {
        final financing = Financing();
        final result = validator.detectTypeCalculation(financing);

        expect(result.isError, isTrue);
        expect(
          result.getErrorOrNull()?.message,
          contains(FinancingValidationMessage.unableToDetermineCalculationType),
        );
      });
    });
  });
}
