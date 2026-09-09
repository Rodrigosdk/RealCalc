import 'package:flutter_test/flutter_test.dart';
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
      final result = useCase.calculate(
        buildFutureValue(interestRateParam: 0),
      );

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull()?.rate, closeTo(interestRate, 0.01));
    });

    test('calcula o número de períodos', () {
      final result = useCase.calculate(buildFutureValue(monthsParam: 0));

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull()?.periods, equals(months));
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
}