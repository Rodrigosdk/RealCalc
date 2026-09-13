import 'package:flutter_test/flutter_test.dart';
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

    test('Deve conseguir calcular a taxa de juros mensal quando houver rendimento', () {
      final params = buildEntity(rateParam: 0.0, finalValueParam: 1323.68);

      final sut = useCase.calculate(params);

      expect(sut.isSuccess, true);
      expect(sut.getOrNull()?.rate, closeTo(rate, 0.01));
    });

    test(
      'Deve retornar taxa ZERO quando o valor final for exatamente igual à soma linear dos depósitos',
      () {
        final paramsSemJuros = buildEntity(
          rateParam: 0.0,
          finalValueParam: 1200.00,
        );

        final sut = useCase.calculate(paramsSemJuros);

        expect(sut.isSuccess, true);
        expect(sut.getOrNull()?.rate, 0.0);
      },
    );

    test(
      'Deve retornar taxa ZERO quando o valor final for menor do que a soma linear dos depósitos',
      () {
        final paramsComPerda = buildEntity(
          rateParam: 0.0,
          finalValueParam: 1100.00,
        );

        final sut = useCase.calculate(paramsComPerda);

        expect(sut.isSuccess, true);
        expect(sut.getOrNull()?.rate, 0.0);
      },
    );
  });
}