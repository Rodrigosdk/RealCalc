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

    test('prestação igual aos juros do primeiro mês também devolve erro', () {
      final result = useCase.calculate(withoutTerm(200));

      expect(
        result.getErrorOrNull()!.message.single,
        isA<PaymentBelowInterestError>(),
      );
    });

    test('prestação um centavo acima dos juros calcula o prazo', () {
      final result = useCase.calculate(withoutTerm(200.01));

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull()!.periods, greaterThan(0));
    });
  });

  group('CalculateFinancing - limites do resultado', () {
    test('taxa que não converge (NaN) devolve erro em vez de sucesso', () {
      final result = useCase.calculate(
        FinancialCalculation(initialValue: 0.01, periods: 1, finalValue: 0.01),
      );

      expect(
        result.getErrorOrNull()!.message.single,
        FinancialCalculationValidationMessage.resultOutOfRange,
      );
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
}
