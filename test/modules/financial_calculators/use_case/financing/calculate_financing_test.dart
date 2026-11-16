import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/modules/financial_calculators/domain/entities/financial_calculation.dart';
import 'package:real_calc/modules/financial_calculators/use_case/financing/calculate_financing.dart';

void main() {
  late double initialValue;
  late double rate;
  late int months;
  late double finalValue;

  late CalculateFinancing useCase;

  FinancialCalculation buildFinancing({
    double? initialValueParam,
    double? rateParam,
    int? monthsParam,
    double? finalValueParam,
  }) {
    return FinancialCalculation(
      initialValue: initialValueParam ?? initialValue,
      rate: rateParam ?? rate,
      periods: monthsParam ?? months,
      finalValue: finalValueParam ?? finalValue,
    );
  }

  setUp(() {
    initialValue = 52882.82;
    rate = 5.55;
    months = 25;
    finalValue = 3961.64;

    useCase = CalculateFinancing();
  });

  group('CalculateFinancing - calculate', () {
    test('Deve calcular o montante final de um regime de Juros Compostos', () {
      final result = useCase.calculate(buildFinancing(finalValueParam: 0));

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull()?.finalValue, closeTo(finalValue, 0.01));
    });

    test('Deve calcular o valor inicial de um regime de Juros Compostos', () {
      final result = useCase.calculate(buildFinancing(initialValueParam: 0));

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull()?.initialValue, closeTo(initialValue, 0.05));
    });

    test('Deve calcular a taxa de juros de um regime de Juros Compostos', () {
      final result = useCase.calculate(buildFinancing(rateParam: 0));

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull()?.rate, closeTo(rate, 0.01));
    });

    test('Deve calcular o número de meses de um regime de Juros Compostos', () {
      final result = useCase.calculate(buildFinancing(monthsParam: 0));

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull()?.periods, equals(months));
    });
  });

  group('CalculateFinancing - validate', () {
    test(
      'Deve retornar erro de quantidade de parâmetros quando nenhum campo estiver zerado',
      () {
        final result = useCase.calculate(buildFinancing());

        expect(result.isError, isTrue);
        expect(
          result.getErrorOrNull()?.message,
          contains(FinancialCalculationValidationMessage.invalidParameterCount),
        );
      },
    );

    test(
      'Deve retornar erro de quantidade de parâmetros quando mais de um campo estiver zerado',
      () {
        final result = useCase.calculate(
          buildFinancing(initialValueParam: 0, rateParam: 0),
        );

        expect(result.isError, isTrue);
        expect(
          result.getErrorOrNull()?.message,
          contains(FinancialCalculationValidationMessage.invalidParameterCount),
        );
      },
    );

    test(
      'Deve retornar erro de quantidade de parâmetros quando todos os campos estiverem zerados',
      () {
        final result = useCase.calculate(FinancialCalculation());

        expect(result.isError, isTrue);
        expect(
          result.getErrorOrNull()?.message,
          contains(FinancialCalculationValidationMessage.invalidParameterCount),
        );
      },
    );
  });

  group('CalculateFinancing - prazo sem solução', () {
    FinancialCalculation withoutTerm(double payment) =>
        FinancialCalculation(initialValue: 10000, rate: 2, finalValue: payment);

    test('prestação menor que os juros do primeiro mês devolve erro', () {
      final result = useCase.calculate(withoutTerm(100));

      final error = result.getErrorOrNull()!.message.single;
      expect(error, isA<PaymentBelowInterestError>());
      expect((error as PaymentBelowInterestError).firstMonthInterest, 200);
      expect(
        error.message,
        'Com essa prestação, a dívida nunca é quitada: ela precisa ser maior '
        'que os juros do primeiro mês, de R\$\u00A0200,00.',
      );
    });

    test(
      'prestação igual aos juros em centavos: qualquer prazo longo serve',
      () {
        final result = useCase.calculate(withoutTerm(200));

        final error = result.getErrorOrNull()!.message.single;
        expect(error, isA<AmbiguousPeriodsError>());
        expect((error as AmbiguousPeriodsError).from, 536);
      },
    );

    test('prestação um centavo abaixo dos juros nunca quita a dívida', () {
      final result = useCase.calculate(withoutTerm(199.99));

      expect(
        result.getErrorOrNull()!.message.single,
        isA<PaymentBelowInterestError>(),
      );
    });

    test('prestação maior que a dívida com os juros não tem prazo', () {
      final result = useCase.calculate(
        FinancialCalculation(initialValue: 1000, rate: 1, finalValue: 5000),
      );

      expect(
        result.getErrorOrNull()!.message.single,
        FinancingValidationMessage.paymentAboveDebt,
      );
    });

    test('10.000 em 70 meses a 999,99%: refazer o prazo pela prestação '
        'mostrada explica que o prazo não pode ser descoberto', () {
      final payment = useCase
          .calculate(
            FinancialCalculation(
              initialValue: 10000,
              periods: 70,
              rate: 999.99,
            ),
          )
          .getOrNull()!
          .finalValue;
      final shown = (payment * 100).round() / 100;
      expect(shown, 99999.0);

      final result = useCase.calculate(
        FinancialCalculation(
          initialValue: 10000,
          rate: 999.99,
          finalValue: shown,
        ),
      );

      final error = result.getErrorOrNull()!.message.single;
      expect(error, isA<AmbiguousPeriodsError>());
      expect((error as AmbiguousPeriodsError).from, lessThanOrEqualTo(70));
      expect(
        error.message,
        contains('qualquer prazo a partir de ${error.from} meses'),
      );
    });

    test('prestação um centavo acima dos juros calcula o prazo', () {
      final result = useCase.calculate(withoutTerm(200.01));

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull()!.periods, greaterThan(0));
    });
  });

  group('CalculateFinancing - limites do resultado', () {
    test('prestações que somam o valor financiado não têm taxa', () {
      final result = useCase.calculate(
        FinancialCalculation(initialValue: 0.01, periods: 1, finalValue: 0.01),
      );

      expect(
        result.getErrorOrNull()!.message.single,
        FinancingValidationMessage.noPositiveRate,
      );
    });

    test('taxa com prazo longo converge para o valor certo', () {
      final payment = useCase
          .calculate(
            FinancialCalculation(initialValue: 10000, periods: 1200, rate: 0.5),
          )
          .getOrNull()!
          .finalValue;

      final result = useCase.calculate(
        FinancialCalculation(
          initialValue: 10000,
          periods: 1200,
          finalValue: payment,
        ),
      );

      expect(result.getOrNull()!.rate, closeTo(0.5, 1e-9));
    });

    test('prestação acima de R\$ 1 trilhão devolve erro', () {
      final result = useCase.calculate(
        FinancialCalculation(initialValue: 1e12, periods: 1, rate: 50),
      );

      expect(
        result.getErrorOrNull()!.message.single,
        FinancialCalculationValidationMessage.resultOutOfRange,
      );
    });
  });

  group('CalculateFinancing - Imprecisão de Ponto Flutuante', () {
    test(
      'Deve mitigar a dízima do double e retornar o número exato de meses (25) mesmo com centavos aproximados',
      () {
        final inputComDizima = buildFinancing(monthsParam: 0);

        final result = useCase.calculate(inputComDizima);

        expect(result.isSuccess, isTrue);
        expect(result.getOrNull()?.periods, equals(25));
      },
    );
  });

  group('CalculateFinancing - taxa e prazo sem solução', () {
    test('taxa: R\$ 1.000 em 12x de R\$ 50 devolve erro', () {
      final result = useCase.calculate(
        buildFinancing(
          initialValueParam: 1000,
          monthsParam: 12,
          rateParam: 0,
          finalValueParam: 50,
        ),
      );

      expect(result.isError, isTrue);
      expect(
        result.getErrorOrNull()!.message.single,
        equals(FinancingValidationMessage.noPositiveRate),
      );
    });

    test('taxa: R\$ 1.000 em 12x de R\$ 80 devolve erro', () {
      final result = useCase.calculate(
        buildFinancing(
          initialValueParam: 1000,
          monthsParam: 12,
          rateParam: 0,
          finalValueParam: 80,
        ),
      );

      expect(result.isError, isTrue);
      expect(
        result.getErrorOrNull()!.message.single,
        equals(FinancingValidationMessage.noPositiveRate),
      );
    });

    test('prazo: R\$ 1.000 a 10% com prestação de R\$ 50 devolve erro', () {
      final result = useCase.calculate(
        buildFinancing(
          initialValueParam: 1000,
          rateParam: 10,
          monthsParam: 0,
          finalValueParam: 50,
        ),
      );

      expect(result.isError, isTrue);
      expect(
        result.getErrorOrNull()!.message.single,
        isA<PaymentBelowInterestError>(),
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
              buildFinancing(
                initialValueParam: initial,
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
              buildFinancing(
                initialValueParam: initial,
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
