import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/modules/financing/domain/entities/financing.dart';
import 'package:real_calc/modules/financing/domain/usecases/calculate_compound_interest_use_case.dart';
import 'package:real_calc/modules/financing/domain/validation/financing_validator.dart';

void main() {
  late double initialValue;
  late double rate;
  late int months;
  late double finalValue;

  late CalculateCompoundInterestUseCase useCase;

  Financing buildFinancing({
    double? initialValueParam,
    double? rateParam,
    int? monthsParam,
    double? finalValueParam,
  }) {
    return Financing(
      initialValue: initialValueParam ?? initialValue,
      rate: rateParam ?? rate,
      months: monthsParam ?? months,
      finalValue: finalValueParam ?? finalValue,
    );
  }

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
        buildFinancing(finalValueParam: 0),
      );

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull(), closeTo(finalValue, 0.01));
    });

    test('Deve calcular o valor inicial de um regime de Juros Compostos', () {
      final result = useCase.calculateInitialValue(
        buildFinancing(initialValueParam: 0),
      );

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull(), closeTo(initialValue, 0.01));
    });

    test('Deve calcular a taxa de juros de um regime de Juros Compostos', () {
      final result = useCase.calculateRate(buildFinancing(rateParam: 0));

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull(), closeTo(rate, 0.01));
    });

    test('Deve calcular o número de meses de um regime de Juros Compostos', () {
      final result = useCase.calculateMonths(buildFinancing(monthsParam: 0));

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull(), closeTo(months.toDouble(), 0.01));
    });
  });

  group("CalculateCompoundInterestUseCase - validate", () {
    test('Deve retornar erro quando o valor inicial for inválido', () {
      final result = useCase.calculateFinalValue(Financing());

      expect(result.isError, isTrue);
      expect(
        result.getErrorOrNull()?.message,
        containsAll([
          FinancingValidationMessage.positiveInitialValue,
          FinancingValidationMessage.positiveRate,
          FinancingValidationMessage.positiveMonths,
        ]),
      );
    });

    test('Deve retornar erro quando o valor final for inválido', () {
      final result = useCase.calculateInitialValue(Financing());

      expect(result.isError, isTrue);
      expect(
        result.getErrorOrNull()?.message,
        contains(FinancingValidationMessage.positiveFinalValue),
      );
    });

    test('Deve retornar erro quando a taxa de juros for inválida', () {
      final result = useCase.calculateRate(Financing(rate: -1.5));

      expect(result.isError, isTrue);
      expect(
        result.getErrorOrNull()?.message,
        containsAll(([
          FinancingValidationMessage.positiveInitialValue,
          FinancingValidationMessage.positiveFinalValue,
          FinancingValidationMessage.positiveMonths,
        ])),
      );
    });

    test('Deve retornar erro quando o número de meses for inválido', () {
      final result = useCase.calculateMonths(Financing());

      expect(result.isError, isTrue);
      expect(
        result.getErrorOrNull()?.message,
        containsAll([
          FinancingValidationMessage.positiveInitialValue,
          FinancingValidationMessage.positiveFinalValue,
          FinancingValidationMessage.positiveRate,
        ]),
      );
    });
  });

  group("CalculateCompoundInterestUseCase - determineType", () {
    test(
      'Deve retornar erro quando não for possível determinar o tipo de cálculo',
      () {
        final result = useCase.calculate(Financing());

        expect(result.isError, isTrue);
        expect(
          result.getErrorOrNull()?.message,
          contains(FinancingValidationMessage.unableToDetermineCalculationType),
        );
      },
    );

    test(
      'Deve determinar o tipo de cálculo correto para calcular o valor final',
      () {
        final result = useCase.calculate(buildFinancing(finalValueParam: 0));

        expect(result.isSuccess, isTrue);
        expect(result.getOrNull(), closeTo(finalValue, 0.01));
      },
    );
    test(
      'Deve determinar o tipo de cálculo correto para calcular o valor inicial',
      () {
        final result = useCase.calculate(buildFinancing(initialValueParam: 0));

        expect(result.isSuccess, isTrue);
        expect(result.getOrNull(), closeTo(initialValue, 0.01));
      },
    );

    test(
      'Deve determinar o tipo de cálculo correto para calcular a taxa de juros',
      () {
        final result = useCase.calculate(buildFinancing(rateParam: 0));

        expect(result.isSuccess, isTrue);
        expect(result.getOrNull(), closeTo(rate, 0.01));
      },
    );

    test(
      'Deve determinar o tipo de cálculo correto para calcular o número de meses',
      () {
        final result = useCase.calculate(buildFinancing(monthsParam: 0));

        expect(result.isSuccess, isTrue);
        expect(result.getOrNull(), closeTo(months.toDouble(), 0.01));
      },
    );
  });

  group("CalculateCompoundInterestUseCase - Imprecisão de Ponto Flutuante", () {
    test(
      'Deve mitigar a dízima do double e retornar o número exato de meses (48) mesmo com centavos aproximados',
      () {
        final inputComDizima = buildFinancing(
          initialValueParam: 50000.0,
          rateParam: 1.5,
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
