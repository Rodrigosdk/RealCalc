import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/modules/financial_calculators/domain/entities/financial_calculation.dart';
import 'package:real_calc/modules/financial_calculators/use_case/future_value/calculate_future_value.dart';

void main() {
  late double capital;
  late double interestRate;
  late int months;
  late double finalValue;

  late CalculateFutureValue useCase;

  FinancialCalculation buildFutureValue({
    double? capitalParam,
    double? interestRateParam,
    int? monthsParam,
    double? finalValueParam,
  }) {
    return FinancialCalculation(
      initialValue: capitalParam ?? capital,
      rate: interestRateParam ?? interestRate,
      periods: monthsParam ?? months,
      finalValue: finalValueParam ?? finalValue,
    );
  }

  setUp(() {
    capital = 50000.0;
    interestRate = 1.5;
    months = 48;
    finalValue = 102173.91;

    useCase = CalculateFutureValue();
  });

  group('CalculateFutureValue - calculate', () {
    test('calcula o valor final', () {
      final result = useCase.calculate(buildFutureValue(finalValueParam: 0));

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull()?.finalValue, closeTo(finalValue, 0.01));
    });

    test('calcula o capital inicial', () {
      final result = useCase.calculate(buildFutureValue(capitalParam: 0));

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull()?.initialValue, closeTo(capital, 0.01));
    });

    test('calcula a taxa de juros', () {
      final result = useCase.calculate(buildFutureValue(interestRateParam: 0));

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull()?.rate, closeTo(interestRate, 0.01));
    });

    test('calcula o número de períodos', () {
      final result = useCase.calculate(buildFutureValue(monthsParam: 0));

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull()?.periods, equals(months));
    });
  });

  group('CalculateFutureValue - limites do resultado', () {
    test('valor futuro infinito devolve erro em vez de sucesso', () {
      final result = useCase.calculate(
        FinancialCalculation(initialValue: 0.01, periods: 9999, rate: 100),
      );

      expect(
        result.getErrorOrNull()!.message.single,
        FinancialCalculationValidationMessage.resultOutOfRange,
      );
    });

    test('valor futuro acima de R\$ 1 trilhão devolve erro', () {
      final result = useCase.calculate(
        FinancialCalculation(initialValue: 1000, periods: 999, rate: 10),
      );

      expect(
        result.getErrorOrNull()!.message.single,
        FinancialCalculationValidationMessage.resultOutOfRange,
      );
    });
  });

  group('CalculateFutureValue - Imprecisão de Ponto Flutuante', () {
    test(
      'Deve mitigar a dízima do double e retornar o número exato de meses (48) mesmo com centavos aproximados',
      () {
        final inputComDizima = buildFutureValue(
          capitalParam: 50000.0,
          interestRateParam: 1.5,
          finalValueParam: 102173.91,
          monthsParam: 0,
        );

        final result = useCase.calculate(inputComDizima);

        expect(result.isSuccess, isTrue);
        expect(result.getOrNull()?.periods, equals(48));
      },
    );
  });

  group('CalculateFutureValue - valor futuro abaixo do aplicado', () {
    test('taxa: devolve erro', () {
      final result = useCase.calculate(
        FinancialCalculation(initialValue: 1000, periods: 12, finalValue: 500),
      );

      expect(
        result.getErrorOrNull()!.message.single,
        FutureValueValidationMessage.finalNotAboveInitial,
      );
    });

    test('prazo: devolve erro em vez de prazo negativo', () {
      final result = useCase.calculate(
        FinancialCalculation(initialValue: 1000, rate: 1, finalValue: 500),
      );

      expect(
        result.getErrorOrNull()!.message.single,
        FutureValueValidationMessage.finalNotAboveInitial,
      );
    });
  });

  group('CalculateFutureValue - taxa e prazo sem solução', () {
    test('taxa: R\$ 1.000 em 12 meses para R\$ 80 devolve erro', () {
      final result = useCase.calculate(
        buildFutureValue(
          capitalParam: 1000,
          monthsParam: 12,
          interestRateParam: 0,
          finalValueParam: 80,
        ),
      );

      expect(result.isError, isTrue);
      expect(
        result.getErrorOrNull()!.message.single,
        equals(FutureValueValidationMessage.finalNotAboveInitial),
      );
    });

    test('prazo: R\$ 1.000 a 10% para R\$ 50 devolve erro', () {
      final result = useCase.calculate(
        buildFutureValue(
          capitalParam: 1000,
          interestRateParam: 10,
          monthsParam: 0,
          finalValueParam: 50,
        ),
      );

      expect(result.isError, isTrue);
      expect(
        result.getErrorOrNull()!.message.single,
        equals(FutureValueValidationMessage.finalNotAboveInitial),
      );
    });

    test('nenhuma combinação devolve taxa ou prazo impossível', () {
      const values = [0.01, 1.0, 50.0, 500.0, 1000.0, 1e6, 1e9];
      const rates = [0.01, 0.5, 1.0, 10.0, 100.0, 999.99];
      const monthsList = [1, 2, 12, 360, 9999];

      for (final initial in values) {
        for (final target in values) {
          for (final n in monthsList) {
            final result = useCase.calculate(
              buildFutureValue(
                capitalParam: initial,
                monthsParam: n,
                interestRateParam: 0,
                finalValueParam: target,
              ),
            );
            final reason = 'taxa: $initial, $n meses, final $target';

            if (result.isError) {
              expect(
                result.getErrorOrNull()!.message,
                isNotEmpty,
                reason: reason,
              );
            } else {
              expect(
                result.getOrNull()!.rate,
                greaterThanOrEqualTo(0.005),
                reason: reason,
              );
            }
          }

          for (final r in rates) {
            final result = useCase.calculate(
              buildFutureValue(
                capitalParam: initial,
                interestRateParam: r,
                monthsParam: 0,
                finalValueParam: target,
              ),
            );
            final reason = 'prazo: $initial a $r%, final $target';

            if (result.isError) {
              expect(
                result.getErrorOrNull()!.message,
                isNotEmpty,
                reason: reason,
              );
            } else {
              expect(
                result.getOrNull()!.periods,
                greaterThanOrEqualTo(1),
                reason: reason,
              );
            }
          }
        }
      }
    });
  });
}
