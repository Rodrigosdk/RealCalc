import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/modules/financing/domain/entities/financing.dart';
import 'package:real_calc/modules/financing/domain/usecases/calculate_compound_interest_use_case.dart';

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

    useCase = CalculateCompoundInterestUseCase();
  });

  group('CalculateCompoundInterestUseCase', () {
    test('Deve calcular o montante final de um regime de Juros Compostos', () {
      final sut = useCase.calculateFinalValue(
        Financing(initialValue: initialValue, rate: rate, months: months),
      );

      expect(sut, closeTo(finalValue, 0.01));
    });

    test('Deve calcular o valor inicial de um regime de Juros Compostos', () {
      final sut = useCase.calculateInitialValue(
        Financing(rate: rate, months: months, finalValue: finalValue),
      );

      expect(sut, closeTo(initialValue, 0.01));
    });

    test('Deve calcular a taxa de juros de um regime de Juros Compostos', () {
      final sut = useCase.calculateRate(
        Financing(
          initialValue: initialValue,
          months: months,
          finalValue: finalValue,
        ),
      );

      expect(sut, closeTo(rate, 0.01));
    });

    test('Deve calcular o número de meses de um regime de Juros Compostos', () {
      final sut = useCase.calculateMonths(
        Financing(
          initialValue: initialValue,
          rate: rate,
          finalValue: finalValue,
        ),
      );

      expect(sut, closeTo(months, 0.01));
    });
  });

  group("CalculateCompoundInterestUseCase - validate", () {
    test('Deve lançar ArgumentError quando o valor inicial for inválido', () {
      expect(
        () => useCase.calculateFinalValue(Financing(initialValue: -1000)),
        throwsArgumentError,
      );
    });

    test('Deve lançar ArgumentError quando o valor final for inválido', () {
      expect(
        () => useCase.calculateInitialValue(Financing(finalValue: -1000)),
        throwsArgumentError,
      );
    });

    test('Deve lançar ArgumentError quando a taxa de juros for inválida', () {
      expect(
        () => useCase.calculateRate(Financing(rate: -1.5)),
        throwsArgumentError,
      );
    });

    test('Deve lançar ArgumentError quando o número de meses for inválido', () {
      expect(
        () => useCase.calculateMonths(Financing(months: -48)),
        throwsArgumentError,
      );
    });
  });
}
