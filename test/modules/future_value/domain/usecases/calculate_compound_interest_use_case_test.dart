import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/modules/future_value/domain/entities/future_value.dart';
import 'package:real_calc/modules/future_value/domain/usecase/calculate_compound_interest_use_case.dart';
import 'package:real_calc/modules/future_value/domain/validation/future_value_validator.dart';

void main() {
  late double capital;
  late double interestRate;
  late int months;
  late double finalValue;

  late CalculateCompoundInterestUseCase useCase;

  FutureValue buildFutureValue({
    double? capitalParam,
    double? interestRateParam,
    int? monthsParam,
    double? finalValueParam,
  }) {
    return FutureValue(
      capital: capitalParam ?? capital,
      interestRate: interestRateParam ?? interestRate,
      months: monthsParam ?? months,
      finalValue: finalValueParam ?? finalValue,
    );
  }

  setUp(() {
    capital = 50000.0;
    interestRate = 1.5;
    months = 48;
    finalValue = 102173.91;

    useCase = CalculateCompoundInterestUseCase(FutureValueValidator());
  });

  group('CalculateCompoundInterestUseCase', () {
    test('Deve calcular o montante final de um regime de Juros Compostos', () {
      final result = useCase.calculateFinalValue(
        buildFutureValue(finalValueParam: 0),
      );

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull(), closeTo(finalValue, 0.01));
    });

    test('Deve calcular o valor inicial de um regime de Juros Compostos', () {
      final result = useCase.calculateInitialValue(
        buildFutureValue(capitalParam: 0),
      );

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull(), closeTo(capital, 0.01));
    });

    test('Deve calcular a taxa de juros de um regime de Juros Compostos', () {
      final result = useCase.calculateRate(buildFutureValue(interestRateParam: 0));

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull(), closeTo(interestRate, 0.01));
    });

    test('Deve calcular o número de meses de um regime de Juros Compostos', () {
      final result = useCase.calculateMonths(buildFutureValue(monthsParam: 0));

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull(), closeTo(months.toDouble(), 0.01));
    });
  });

  group("CalculateCompoundInterestUseCase - validate", () {
    test('Deve retornar erro quando o capital for inválido', () {
      final result = useCase.calculateFinalValue(FutureValue());

      expect(result.isError, isTrue);
      expect(
        result.getErrorOrNull()?.message,
        containsAll([
          FutureValueValidationMessage.positiveCapital,
          FutureValueValidationMessage.positiveInterestRate,
          FutureValueValidationMessage.positiveMonths,
        ]),
      );
    });

    test('Deve retornar erro quando o valor final for inválido', () {
      final result = useCase.calculateInitialValue(FutureValue());

      expect(result.isError, isTrue);
      expect(
        result.getErrorOrNull()?.message,
        contains(FutureValueValidationMessage.positiveFinalValue),
      );
    });

    test('Deve retornar erro quando a taxa de juros for inválida', () {
      final result = useCase.calculateRate(FutureValue(interestRate: -1.5));

      expect(result.isError, isTrue);
      expect(
        result.getErrorOrNull()?.message,
        containsAll(([
          FutureValueValidationMessage.positiveCapital,
          FutureValueValidationMessage.positiveFinalValue,
          FutureValueValidationMessage.positiveMonths,
        ])),
      );
    });

    test('Deve retornar erro quando o número de meses for inválido', () {
      final result = useCase.calculateMonths(FutureValue());

      expect(result.isError, isTrue);
      expect(
        result.getErrorOrNull()?.message,
        containsAll([
          FutureValueValidationMessage.positiveCapital,
          FutureValueValidationMessage.positiveFinalValue,
          FutureValueValidationMessage.positiveInterestRate,
        ]),
      );
    });
  });

  group("CalculateCompoundInterestUseCase - determineType", () {
    test(
      'Deve retornar erro quando não for possível determinar o tipo de cálculo',
      () {
        final result = useCase.calculate(FutureValue());

        expect(result.isError, isTrue);
        expect(
          result.getErrorOrNull()?.message,
          contains(FutureValueValidationMessage.unableToDetermineCalculationType),
        );
      },
    );

    test(
      'Deve determinar o tipo de cálculo correto para calcular o valor final',
      () {
        final result = useCase.calculate(buildFutureValue(finalValueParam: 0));

        expect(result.isSuccess, isTrue);
        expect(result.getOrNull(), closeTo(finalValue, 0.01));
      },
    );
    test(
      'Deve determinar o tipo de cálculo correto para calcular o valor inicial',
      () {
        final result = useCase.calculate(buildFutureValue(capitalParam: 0));

        expect(result.isSuccess, isTrue);
        expect(result.getOrNull(), closeTo(capital, 0.01));
      },
    );

    test(
      'Deve determinar o tipo de cálculo correto para calcular a taxa de juros',
      () {
        final result = useCase.calculate(buildFutureValue(interestRateParam: 0));

        expect(result.isSuccess, isTrue);
        expect(result.getOrNull(), closeTo(interestRate, 0.01));
      },
    );

    test(
      'Deve determinar o tipo de cálculo correto para calcular o número de meses',
      () {
        final result = useCase.calculate(buildFutureValue(monthsParam: 0));

        expect(result.isSuccess, isTrue);
        expect(result.getOrNull(), closeTo(months.toDouble(), 0.01));
      },
    );
  });

  group("CalculateCompoundInterestUseCase - Imprecisão de Ponto Flutuante", () {
    test(
      'Deve mitigar a dízima do double e retornar o número exato de meses (48) mesmo com centavos aproximados',
      () {
        final inputComDizima = buildFutureValue(
          capitalParam: 50000.0,
          interestRateParam: 1.5,
          finalValueParam: 102173.91,
          monthsParam: 0,
        );

        final result = useCase.calculateMonths(inputComDizima);

        expect(result.isSuccess, isTrue);
        expect(result.getOrNull(), equals(48));
      },
    );
  });
}
