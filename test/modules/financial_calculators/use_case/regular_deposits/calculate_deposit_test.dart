import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/modules/financial_calculators/domain/entities/financial_calculation.dart';
import 'package:real_calc/modules/financial_calculators/use_case/regular_deposits/calculate_deposit.dart';

void main() {
  late double depositAmount;
  late int months;
  late double rate;
  late double finalValue;
  late CalculateDeposit useCase;

  FinancialCalculation buildEntity({
    double? depositAmountParam,
    int? monthsParam,
    double? rateParam,
    double? finalValueParam,
  }) {
    return FinancialCalculation(
      initialValue: depositAmountParam ?? depositAmount,
      periods: monthsParam ?? months,
      rate: rateParam ?? rate,
      finalValue: finalValueParam ?? finalValue,
    );
  }

  setUp(() {
    depositAmount = 100;
    months = 12;
    rate = 1.50;
    finalValue = 1323.68;

    useCase = CalculateDeposit();
  });

  group('CalculateDeposit', () {
    test('Deve conseguir calcular o valor futuro do depósito', () {
      final params = buildEntity(finalValueParam: 0);
      final sut = useCase.calculate(params);

      expect(sut.isSuccess, true);
      expect(sut.getOrNull()?.finalValue, closeTo(finalValue, 0.01));
    });

    test(
      'Deve conseguir calcular o valor futuro do depósito quando a taxa de juros for ZERO',
      () {
        final params = buildEntity(rateParam: 0, finalValueParam: 0);

        final sut = useCase.calculate(params);

        expect(sut.isSuccess, true);
        expect(sut.getOrNull()?.finalValue, closeTo(1200, 0.01));
      },
    );

    test('Deve conseguir calcular o valor do depósito regular', () {
      final params = buildEntity(depositAmountParam: 0);

      final sut = useCase.calculate(params);

      expect(sut.isSuccess, true);
      expect(sut.getOrNull()?.initialValue, closeTo(depositAmount, 0.01));
    });

    test(
      'Deve conseguir calcular o valor de depósito regular quando a taxa de juros for ZERO',
      () {
        final params = buildEntity(
          depositAmountParam: 0,
          finalValueParam: 1200.00,
          monthsParam: 12,
          rateParam: 0.0,
        );

        final sut = useCase.calculate(params);

        expect(sut.isSuccess, true);
        expect(sut.getOrNull()?.initialValue, closeTo(depositAmount, 0.01));
      },
    );

    test('Deve conseguir calcular o número do mês', () {
      final params = buildEntity(monthsParam: 0);

      final sut = useCase.calculate(params);

      expect(sut.isSuccess, true);
      expect(sut.getOrNull()?.periods, equals(months));
    });

    test(
      'Deve conseguir calcular o número do mês quando a taxa de juros for ZERO',
      () {
        final params = buildEntity(
          rateParam: 0,
          finalValueParam: 1200,
          monthsParam: 0,
        );

        final sut = useCase.calculate(params);

        expect(sut.isSuccess, true);
        expect(sut.getOrNull()?.periods, equals(months));
      },
    );

    test(
      'Deve conseguir calcular a taxa de juros mensal quando houver rendimento',
      () {
        final params = buildEntity(rateParam: 0.0, finalValueParam: 1323.68);

        final sut = useCase.calculate(params);

        expect(sut.isSuccess, true);
        expect(sut.getOrNull()?.rate, closeTo(rate, 0.01));
      },
    );

    test(
      'valor final igual à soma dos depósitos não tem taxa: devolve erro',
      () {
        final paramsSemJuros = buildEntity(
          rateParam: 0.0,
          finalValueParam: 1200.00,
        );

        final sut = useCase.calculate(paramsSemJuros);

        expect(
          sut.getErrorOrNull()!.message.single,
          RegularDepositsValidationMessage.noPositiveRate,
        );
      },
    );

    test(
      'valor final menor que a soma dos depósitos não tem taxa: devolve erro',
      () {
        final paramsComPerda = buildEntity(
          rateParam: 0.0,
          finalValueParam: 1100.00,
        );

        final sut = useCase.calculate(paramsComPerda);

        expect(
          sut.getErrorOrNull()!.message.single,
          RegularDepositsValidationMessage.noPositiveRate,
        );
      },
    );
  });

  group('CalculateDeposit - limites do resultado', () {
    test('valor final infinito devolve erro em vez de sucesso', () {
      final result = useCase.calculate(
        FinancialCalculation(initialValue: 0.01, periods: 9999, rate: 100),
      );

      expect(
        result.getErrorOrNull()!.message.single,
        FinancialCalculationValidationMessage.resultOutOfRange,
      );
    });

    test('taxa abaixo de 0,01% devolve erro em vez de 0,00', () {
      final result = useCase.calculate(
        FinancialCalculation(
          initialValue: 0.01,
          periods: 9999,
          finalValue: 100,
        ),
      );

      expect(
        result.getErrorOrNull()!.message.single,
        FinancialCalculationValidationMessage.resultTooSmall,
      );
    });
  });

  group('CalculateDeposit - taxa e prazo', () {
    test('taxa com prazo longo converge para o valor certo', () {
      final finalValue = useCase
          .calculate(
            FinancialCalculation(initialValue: 10, rate: 0.01, periods: 1200),
          )
          .getOrNull()!
          .finalValue;

      final result = useCase.calculate(
        FinancialCalculation(
          initialValue: 10,
          periods: 1200,
          finalValue: finalValue,
        ),
      );

      expect(result.getOrNull()!.rate, closeTo(0.01, 1e-9));
    });

    test('valor final abaixo do primeiro mês não tem prazo', () {
      final result = useCase.calculate(
        FinancialCalculation(initialValue: 100, rate: 1, finalValue: 50),
      );

      expect(
        result.getErrorOrNull()!.message.single,
        RegularDepositsValidationMessage.finalBelowFirstMonth,
      );
    });
  });

  group('CalculateDeposit - taxa e prazo sem solução', () {
    test('taxa: R\$ 100 por 12 meses para R\$ 500 devolve erro', () {
      final result = useCase.calculate(
        buildEntity(
          depositAmountParam: 100,
          monthsParam: 12,
          rateParam: 0,
          finalValueParam: 500,
        ),
      );

      expect(result.isError, isTrue);
      expect(
        result.getErrorOrNull()!.message.single,
        equals(RegularDepositsValidationMessage.noPositiveRate),
      );
    });

    test('taxa: R\$ 1.000 por 12 meses para R\$ 80 devolve erro', () {
      final result = useCase.calculate(
        buildEntity(
          depositAmountParam: 1000,
          monthsParam: 12,
          rateParam: 0,
          finalValueParam: 80,
        ),
      );

      expect(result.isError, isTrue);
      expect(
        result.getErrorOrNull()!.message.single,
        equals(RegularDepositsValidationMessage.noPositiveRate),
      );
    });

    test('prazo: R\$ 1.000 a 10% para R\$ 50 devolve erro', () {
      final result = useCase.calculate(
        buildEntity(
          depositAmountParam: 1000,
          rateParam: 10,
          monthsParam: 0,
          finalValueParam: 50,
        ),
      );

      expect(result.isError, isTrue);
      expect(
        result.getErrorOrNull()!.message.single,
        equals(RegularDepositsValidationMessage.finalBelowFirstMonth),
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
              buildEntity(
                depositAmountParam: initial,
                monthsParam: n,
                rateParam: 0,
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
              buildEntity(
                depositAmountParam: initial,
                rateParam: r,
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
