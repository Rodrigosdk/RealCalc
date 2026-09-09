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
    initialValue = 50000.0;
    rate = 1.5;
    months = 48;
    finalValue = 102173.91;

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
      expect(result.getOrNull()?.initialValue, closeTo(initialValue, 0.01));
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

  group('CalculateFinancing - Imprecisão de Ponto Flutuante', () {
    test(
      'Deve mitigar a dízima do double e retornar o número exato de meses (48) mesmo com centavos aproximados',
      () {
        final inputComDizima = buildFinancing(
          initialValueParam: 50000.0,
          rateParam: 1.5,
          finalValueParam: 102173.91,
          monthsParam: 0,
        );

        final result = useCase.calculate(inputComDizima);

        expect(result.isSuccess, isTrue);
        expect(result.getOrNull()?.periods, equals(48));
      },
    );
  });
}