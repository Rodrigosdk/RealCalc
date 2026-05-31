import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/modules/financing/domain/entities/financing.dart';
import 'package:real_calc/modules/financing/domain/validation/financing_validator.dart';

void main() {
  late FinancingValidator validator;

  setUp(() {
    validator = FinancingValidator();
  });

  Financing buildFinancingValido() {
    return Financing(
      initialValue: 1000,
      finalValue: 1200,
      rate: 5,
      months: 12,
    );
  }

  group('FinancingValidator', () {
    group('validateForFinalValue', () {
      test('Deve retornar sucesso quando initialValue, rate e months forem válidos', () {
        final financing = buildFinancingValido();
        final result = validator.validateForFinalValue(financing);

        expect(result.isSuccess, isTrue);
        expect(result.fold((_) => null, (value) => value.initialValue), 1000);
      });

      test('Deve retornar erro quando campos obrigatórios estiverem inválidos', () {
        final financing = Financing(
          initialValue: 0,
          finalValue: 1000,
          rate: 0,
          months: 0,
        );

        final result = validator.validateForFinalValue(financing);

        expect(result.isError, isTrue);
        result.fold(
          (failure) {
            expect(
              failure.errors,
              containsAll([
                'O valor inicial deve ser maior que zero',
                'O valor da taxa deve ser maior que zero',
                'A quantidade de meses deve ser maior que zero',
              ]),
            );
          },
          (_) => fail('Esperava validação falhar.'),
        );
      });
    });

    group('validateForRate', () {
      test('Deve retornar sucesso quando initialValue, finalValue e months forem válidos', () {
        final financing = buildFinancingValido();
        final result = validator.validateForRate(financing);

        expect(result.isSuccess, isTrue);
        expect(result.fold((_) => null, (value) => value.finalValue), 1200);
      });

      test('Deve retornar erro quando finalValue for inválido', () {
        final financing = Financing(
          initialValue: 1000,
          finalValue: 0,
          rate: 5,
          months: 12,
        );

        final result = validator.validateForRate(financing);

        expect(result.isError, isTrue);
        result.fold(
          (failure) {
            expect(failure.errors, contains('O valor final deve ser maior que zero'));
          },
          (_) => fail('Esperava validação falhar.'),
        );
      });
    });

    group('validateForMonths', () {
      test('Deve retornar sucesso quando initialValue, finalValue e rate forem válidos', () {
        final financing = buildFinancingValido();
        final result = validator.validateForMonths(financing);

        expect(result.isSuccess, isTrue);
        expect(result.fold((_) => null, (value) => value.rate), 5);
      });

      test('Deve retornar erro quando rate for inválido', () {
        final financing = Financing(
          initialValue: 1000,
          finalValue: 1200,
          rate: 0,
          months: 12,
        );

        final result = validator.validateForMonths(financing);

        expect(result.isError, isTrue);
        result.fold(
          (failure) {
            expect(failure.errors, contains('O valor da taxa deve ser maior que zero'));
          },
          (_) => fail('Esperava validação falhar.'),
        );
      });
    });

    group('validateForInitialValue', () {
      test('Deve retornar sucesso quando finalValue, rate e months forem válidos', () {
        final financing = buildFinancingValido();
        final result = validator.validateForInitialValue(financing);

        expect(result.isSuccess, isTrue);
        expect(result.fold((_) => null, (value) => value.months), 12);
      });

      test('Deve retornar erro quando finalValue for inválido', () {
        final financing = Financing(
          initialValue: 1000,
          finalValue: 0,
          rate: 5,
          months: 12,
        );

        final result = validator.validateForInitialValue(financing);

        expect(result.isError, isTrue);
        result.fold(
          (failure) {
            expect(failure.errors, contains('O valor final deve ser maior que zero'));
          },
          (_) => fail('Esperava validação falhar.'),
        );
      });
    });
  });
}
