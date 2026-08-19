import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/modules/regular_deposits/domain/entities/regular_deposit.dart';
import 'package:real_calc/modules/regular_deposits/domain/enum/calculate_regular_deposit_type.dart';
import 'package:real_calc/modules/regular_deposits/domain/validation/regular_deposits_validator.dart';

void main() {
  late RegularDepositsValidator validator;

  setUp(() {
    validator = RegularDepositsValidator();
  });

  RegularDeposit buildRegularDeposit({
    double? depositAmount,
    double? finalValue,
    double? rate,
    int? months,
  }) {
    return RegularDeposit(
      depositAmount: depositAmount ?? 1000,
      finalValue: finalValue ?? 1200,
      rate: rate ?? 5,
      months: months ?? 12,
    );
  }

  group('RegularDepositsValidator', () {
    group('validateForFinalValue', () {
      test(
        'Deve retornar sucesso quando depositAmount, rate e months forem válidos',
        () {
          final regularDeposit = buildRegularDeposit(finalValue: 0);
          final result = validator.validateForFinalValue(regularDeposit);

          expect(result.isSuccess, isTrue);
          expect(result.getOrNull()?.depositAmount, 1000);
        },
      );

      test(
        'Deve retornar erro quando campos obrigatórios estiverem inválidos',
        () {
          final regularDeposit = RegularDeposit(
            depositAmount: 0,
            finalValue: 1000,
            rate: 0,
            months: 0,
          );

          final result = validator.validateForFinalValue(regularDeposit);

          expect(result.isError, isTrue);
          expect(
            result.getErrorOrNull()?.message,
            containsAll([
              RegularDepositsValidationMessage.positiveDepositValue,
              RegularDepositsValidationMessage.positiveRate,
              RegularDepositsValidationMessage.positiveMonths,
            ]),
          );
        },
      );
    });

    group('validateForRate', () {
      test(
        'Deve retornar sucesso quando depositAmount, finalValue e months forem válidos',
        () {
          final regularDeposit = buildRegularDeposit(rate: 0);
          final result = validator.validateForRate(regularDeposit);

          expect(result.isSuccess, isTrue);
          expect(result.getOrNull()?.finalValue, 1200);
        },
      );

      test('Deve retornar erro quando finalValue for inválido', () {
        final regularDeposit = RegularDeposit(
          depositAmount: 1000,
          finalValue: 0,
          rate: 5,
          months: 12,
        );

        final result = validator.validateForRate(regularDeposit);

        expect(result.isError, isTrue);
        expect(
          result.getErrorOrNull()?.message,
          contains(RegularDepositsValidationMessage.positiveFinalValue),
        );
      });
    });

    group('validateForMonths', () {
      test(
        'Deve retornar sucesso quando depositAmount, finalValue e rate forem válidos',
        () {
          final regularDeposit = buildRegularDeposit(months: 0);
          final result = validator.validateForMonths(regularDeposit);

          expect(result.isSuccess, isTrue);
          expect(result.getOrNull()?.rate, 5);
        },
      );

      test('Deve retornar erro quando rate for inválido', () {
        final regularDeposit = RegularDeposit(
          depositAmount: 1000,
          finalValue: 1200,
          rate: 0,
          months: 12,
        );

        final result = validator.validateForMonths(regularDeposit);

        expect(result.isError, isTrue);
        expect(
          result.getErrorOrNull()?.message,
          contains(RegularDepositsValidationMessage.positiveRate),
        );
      });
    });

    group('validateForDepositAmount', () {
      test(
        'Deve retornar sucesso quando finalValue, rate e months forem válidos',
        () {
          final regularDeposit = buildRegularDeposit(depositAmount: 0);
          final result = validator.validateForDepositAmount(regularDeposit);

          expect(result.isSuccess, isTrue);
          expect(result.getOrNull()?.months, 12);
        },
      );

      test('Deve retornar erro quando finalValue for inválido', () {
        final regularDeposit = RegularDeposit(
          depositAmount: 1000,
          finalValue: 0,
          rate: 5,
          months: 12,
        );

        final result = validator.validateForDepositAmount(regularDeposit);

        expect(result.isError, isTrue);
        expect(
          result.getErrorOrNull()?.message,
          contains(RegularDepositsValidationMessage.positiveFinalValue),
        );
      });
    });

    group('detectTypeCalculation', () {
      test(
        'Deve retornar o tipo de cálculo correto quando os parâmetros forem válidos',
        () {
          final regularDeposit = buildRegularDeposit(finalValue: 0);
          final result = validator.detectTypeCalculation(regularDeposit);

          expect(result.isSuccess, isTrue);
          expect(result.getOrNull(), CalculateRegularDepositType.finalValue);
        },
      );

      test('Deve retornar erro quando os parâmetros forem inválidos', () {
        final regularDeposit = RegularDeposit();
        final result = validator.detectTypeCalculation(regularDeposit);

        expect(result.isError, isTrue);
        expect(
          result.getErrorOrNull()?.message,
          contains(RegularDepositsValidationMessage.unableToDetermineCalculationType),
        );
      });
    });
  });
}