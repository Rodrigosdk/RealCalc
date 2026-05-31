import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/modules/financing/domain/entities/financing.dart';
import 'package:real_calc/modules/financing/domain/usecases/calculate_compound_interest_use_case.dart';
import 'package:real_calc/modules/financing/domain/validation/financing_validator.dart';

void main() {
  late double initialValue;
  late double rate;
  late int months;
  late double finalValue;

  late CalculateCompoundInterestUseCase useCase;

  setUp(() {
    initialValue = 50000.0;
    rate = 1.5;
    months = 48;
    finalValue = 102173.91;

    useCase = CalculateCompoundInterestUseCase(FinancingValidator());
  });

  group('CalculateCompoundInterestUseCase', () {
    test('Deve calcular o montante final de um regime de Juros Compostos', () {
      final result = useCase.calculateFinalValue(
        Financing(initialValue: initialValue, rate: rate, months: months),
      );

      expect(result.isSuccess, isTrue);
      expect(
        result.fold((_) => null, (value) => value),
        closeTo(finalValue, 0.01),
      );
    });

    test('Deve calcular o valor inicial de um regime de Juros Compostos', () {
      final result = useCase.calculateInitialValue(
        Financing(rate: rate, months: months, finalValue: finalValue),
      );

      expect(result.isSuccess, isTrue);
      expect(
        result.fold((_) => null, (value) => value),
        closeTo(initialValue, 0.01),
      );
    });

    test('Deve calcular a taxa de juros de um regime de Juros Compostos', () {
      final result = useCase.calculateRate(
        Financing(
          initialValue: initialValue,
          months: months,
          finalValue: finalValue,
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(
        result.fold((_) => null, (value) => value),
        closeTo(rate, 0.01),
      );
    });

    test('Deve calcular o número de meses de um regime de Juros Compostos', () {
      final result = useCase.calculateMonths(
        Financing(
          initialValue: initialValue,
          rate: rate,
          finalValue: finalValue,
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(
        result.fold((_) => null, (value) => value.toDouble()),
        closeTo(months.toDouble(), 0.01),
      );
    });
  });

  group("CalculateCompoundInterestUseCase - validate", () {
    test('Deve retornar erro quando o valor inicial for inválido', () {
      final result = useCase.calculateFinalValue(Financing());

      expect(result.isError, isTrue);
      result.fold(
        (failure) => expect(
          failure.errors,
          contains('O valor inicial deve ser maior que zero'),
        ),
        (_) => fail('Esperava validação falhar.'),
      );
    });

    test('Deve retornar erro quando o valor final for inválido', () {
      final result = useCase.calculateInitialValue(Financing());

      expect(result.isError, isTrue);
      result.fold(
        (failure) => expect(
          failure.errors,
          contains('O valor final deve ser maior que zero'),
        ),
        (_) => fail('Esperava validação falhar.'),
      );
    });

    test('Deve retornar erro quando a taxa de juros for inválida', () {
      final result = useCase.calculateRate(Financing(rate: -1.5));

      expect(result.isError, isTrue);
      result.fold(
        (failure) => expect(
          failure.errors,
          containsAll([
            'O valor inicial deve ser maior que zero',
            'O valor final deve ser maior que zero',
            'A quantidade de meses deve ser maior que zero'
          ]),
        ),
        (_) => fail('Esperava validação falhar.'),
      );
    });

    test('Deve retornar erro quando o número de meses for inválido', () {
      final result = useCase.calculateMonths(Financing());

      //expect(result.isError, isTrue);
      result.fold(
        (failure) => expect(
          failure.errors,
          containsAll([
            'O valor inicial deve ser maior que zero',
            'O valor final deve ser maior que zero',
            'O valor da taxa deve ser maior que zero'
          ]),
        ),
        (_) => fail('Esperava validação falhar.'),
      );
    });
  });
}
