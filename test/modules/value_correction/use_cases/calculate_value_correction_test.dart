import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/errors/failures.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/modules/value_correction/domain/entites/period.dart';
import 'package:real_calc/modules/value_correction/domain/entites/series_point.dart';
import 'package:real_calc/modules/value_correction/domain/entites/value_correction.dart';
import 'package:real_calc/modules/value_correction/domain/enum/correction_index.dart';
import 'package:real_calc/modules/value_correction/domain/enum/series_kind.dart';
import 'package:real_calc/modules/value_correction/domain/validation/value_correction_validation.dart';
import 'package:real_calc/modules/value_correction/use_cases/calculate_value_correction.dart';

void main() {
  late ValueCorrectionValidation validation;

  setUp(() {
    validation = ValueCorrectionValidation();
  });

  ValueCorrection buildValueCorrection({
    int index = 1,
    DateTime? initial,
    DateTime? end,
    double percentage = 100,
    double? originalValue,
  }) {
    return ValueCorrection(
      index: index,
      period: Period(
        initial: initial ?? DateTime(2024, 1, 1),
        end: end ?? DateTime(2024, 2, 1),
      ),
      percentage: percentage,
      originalValue: originalValue ?? 1000,
      factor: 1,
      adjustedValue: 1000,
      variation: 0,
    );
  }

  group('CalculateValueCorrection', () {
    test('calcula o fator para variação mensal', () {
      final params = buildValueCorrection();
      final useCase = CalculateValueCorrection(validation);
      final result = useCase.call(
        params: params,
        series: [
          SeriesPoint(date: DateTime(2024, 1, 1), value: 2),
          SeriesPoint(date: DateTime(2024, 2, 1), value: 3),
        ],
        type: SeriesKind.monthlyVariation,
      );

      expect(result.isSuccess, isTrue);
      final valueCorrection = result.getOrNull();
      expect(valueCorrection, isNotNull);
      expect(valueCorrection!.factor, closeTo(1.0506, 1e-9));
      expect(valueCorrection.variation, closeTo(5.06, 1e-9));
      expect(valueCorrection.adjustedValue, closeTo(1050.6, 1e-9));
    });

    test('calcula taxa diária no intervalo (data inicial, data final]', () {
      final useCase = CalculateValueCorrection(validation);
      final firstResult = useCase.call(
        params: buildValueCorrection(percentage: 100),
        series: [
          SeriesPoint(date: DateTime(2024, 1, 1), value: 1),
          SeriesPoint(date: DateTime(2024, 1, 2), value: 2),
        ],
        type: SeriesKind.dailyRate,
      );

      final secondResult = useCase.call(
        params: buildValueCorrection(percentage: 80),
        series: [
          SeriesPoint(date: DateTime(2024, 1, 1), value: 1),
          SeriesPoint(date: DateTime(2024, 1, 2), value: 2),
        ],
        type: SeriesKind.dailyRate,
      );

      expect(firstResult.isSuccess, isTrue);
      expect(secondResult.isSuccess, isTrue);
      expect(firstResult.getOrNull()!.factor, closeTo(1.02, 1e-9));
      expect(secondResult.getOrNull()!.factor, closeTo(1.016, 1e-9));
      expect(
        secondResult.getOrNull()!.factor,
        lessThan(firstResult.getOrNull()!.factor),
      );
    });

    test('Selic: reproduz o fator oficial 1,03533284 em out-dez/2025', () {
      const dailyRate = 0.055131;
      final start = DateTime(2025, 10, 1);
      final series = List.generate(
        64,
        (index) => SeriesPoint(
          date: start.add(Duration(days: index)),
          value: dailyRate,
        ),
      );

      final result = CalculateValueCorrection(validation).call(
        params: buildValueCorrection(
          initial: start,
          end: DateTime(2025, 12, 31),
          percentage: 100,
        ),
        series: series,
        type: SeriesKind.dailyRate,
      );

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull()!.factor, closeTo(1.0353328397522692, 1e-12));
    });

    test('intervalo diário na mesma data tem fator 1', () {
      final date = DateTime(2025, 10, 1);
      final result = CalculateValueCorrection(validation).call(
        params: buildValueCorrection(initial: date, end: date),
        series: [SeriesPoint(date: date, value: 0.055131)],
        type: SeriesKind.dailyRate,
      );

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull()!.factor, 1);
    });

    test(
      'case de referência: IPCA de 01/2003 a 01/2003 produz fator 1,0225',
      () {
        final result = CalculateValueCorrection(validation).call(
          params: buildValueCorrection(
            initial: DateTime(2003, 1, 1),
            end: DateTime(2003, 1, 1),
            originalValue: 1000,
          ),
          series: [SeriesPoint(date: DateTime(2003, 1, 1), value: 2.25)],
          type: SeriesKind.monthlyVariation,
        );

        expect(result.isSuccess, isTrue);
        expect(result.getOrNull()!.factor, closeTo(1.0225, 1e-12));
      },
    );

    test(
      'case de referência: IPCA de 01/2003 a 12/2003 produz fator 1,0929994',
      () {
        final monthlyRate = 0.7437997182806688;
        final series = List.generate(
          12,
          (index) => SeriesPoint(
            date: DateTime(2003, index + 1, 1),
            value: monthlyRate,
          ),
        );

        final result = CalculateValueCorrection(validation).call(
          params: buildValueCorrection(
            initial: DateTime(2003, 1, 1),
            end: DateTime(2003, 12, 1),
            originalValue: 1000,
          ),
          series: series,
          type: SeriesKind.monthlyVariation,
        );

        expect(result.isSuccess, isTrue);
        expect(result.getOrNull()!.factor, closeTo(1.0929994, 1e-7));
      },
    );

    test(
      'case de referência: INPC de 01/1994 a 06/1994 com valor 1000 produz 8591,50',
      () {
        final monthlyRate = 43.11269684741077;
        final series = List.generate(
          6,
          (index) => SeriesPoint(
            date: DateTime(1994, index + 1, 1),
            value: monthlyRate,
          ),
        );

        final result = CalculateValueCorrection(validation).call(
          params: buildValueCorrection(
            initial: DateTime(1994, 1, 1),
            end: DateTime(1994, 6, 1),
            originalValue: 1000,
          ),
          series: series,
          type: SeriesKind.monthlyVariation,
        );

        expect(result.isSuccess, isTrue);
        expect(result.getOrNull()!.adjustedValue, closeTo(8591.5, 1e-6));
      },
    );

    test(
      'case de referência: INPC de 01/1989 a 05/1989 produz fator 2,1046',
      () {
        final monthlyRate = 16.046998792301913;
        final series = List.generate(
          5,
          (index) => SeriesPoint(
            date: DateTime(1989, index + 1, 1),
            value: monthlyRate,
          ),
        );

        final result = CalculateValueCorrection(validation).call(
          params: buildValueCorrection(
            initial: DateTime(1989, 1, 1),
            end: DateTime(1989, 5, 1),
            originalValue: 1000,
          ),
          series: series,
          type: SeriesKind.monthlyVariation,
        );

        expect(result.isSuccess, isTrue);
        expect(result.getOrNull()!.factor, closeTo(2.1046, 1e-7));
      },
    );

    test(
      'calcula fator para taxa de período usando encadeamento acumulado',
      () {
        final result = CalculateValueCorrection(validation).call(
          params: buildValueCorrection(
            initial: DateTime(2024, 1, 1),
            end: DateTime(2024, 3, 1),
            originalValue: 1000,
          ),
          series: [
            SeriesPoint(date: DateTime(2024, 1, 1), value: 1),
            SeriesPoint(date: DateTime(2024, 2, 1), value: 2),
            SeriesPoint(date: DateTime(2024, 3, 1), value: 3),
          ],
          type: SeriesKind.periodRate,
        );

        expect(result.isSuccess, isTrue);
        expect(result.getOrNull()!.factor, closeTo(1.061106, 1e-9));
        expect(result.getOrNull()!.adjustedValue, closeTo(1061.106, 1e-9));
      },
    );

    test(
      'TR acumula períodos consecutivos sem multiplicar taxas sobrepostas',
      () {
        final start = DateTime(2025, 10, 1);
        final end = DateTime(2025, 12, 31);
        final result = CalculateValueCorrection(validation).call(
          params: buildValueCorrection(
            index: CorrectionIndex.tr.sgsCode,
            initial: start,
            end: end,
          ),
          series: [
            SeriesPoint(
              date: DateTime(2025, 10, 1),
              periodEnd: DateTime(2025, 10, 31),
              value: 0.1738,
            ),
            SeriesPoint(
              date: DateTime(2025, 10, 1),
              periodEnd: DateTime(2025, 11, 1),
              value: 0.1758,
            ),
            SeriesPoint(
              date: DateTime(2025, 11, 1),
              periodEnd: DateTime(2025, 12, 1),
              value: 0.1634,
            ),
            SeriesPoint(
              date: DateTime(2025, 12, 1),
              periodEnd: DateTime(2025, 12, 31),
              value: 0.1723,
            ),
            SeriesPoint(
              date: DateTime(2025, 12, 1),
              periodEnd: DateTime(2026, 1, 1),
              value: 0.1742,
            ),
            SeriesPoint(
              date: DateTime(2025, 12, 31),
              periodEnd: DateTime(2026, 1, 31),
              value: 0.1738,
            ),
          ],
          type: SeriesKind.periodRate,
        );

        expect(result.isSuccess, isTrue);
        expect(result.getOrNull()!.factor, closeTo(1.00511520, 4e-6));
      },
    );

    test('calcula fator para taxa legal em juros simples', () {
      final result = CalculateValueCorrection(validation).call(
        params: buildValueCorrection(
          initial: DateTime(2024, 11, 1),
          end: DateTime(2024, 12, 1),
          originalValue: 1000,
        ),
        series: [SeriesPoint(date: DateTime(2024, 11, 1), value: 0.385874)],
        type: SeriesKind.simpleMonthlyRate,
      );

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull()!.factor, closeTo(1.00385874, 1e-9));
      expect(result.getOrNull()!.adjustedValue, closeTo(1003.85874, 1e-9));
    });

    test('Taxa Legal acumula mensalmente os dados SGS 29543', () {
      final result = CalculateValueCorrection(validation).call(
        params: buildValueCorrection(
          index: CorrectionIndex.taxaLegal.sgsCode,
          initial: DateTime(2025, 10, 1),
          end: DateTime(2026, 1, 1),
        ),
        series: [
          SeriesPoint(date: DateTime(2025, 10, 1), value: 0.736394),
          SeriesPoint(date: DateTime(2025, 11, 1), value: 1.093764),
          SeriesPoint(date: DateTime(2025, 12, 1), value: 0.851001),
        ],
        type: SeriesKind.simpleMonthlyRate,
      );

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull()!.factor, closeTo(1.02681159, 1e-12));
    });

    test('Taxa Legal aplica pro rata die em meses parciais', () {
      final result = CalculateValueCorrection(validation).call(
        params: buildValueCorrection(
          index: CorrectionIndex.taxaLegal.sgsCode,
          initial: DateTime(2025, 10, 1),
          end: DateTime(2025, 12, 31),
        ),
        series: [
          SeriesPoint(date: DateTime(2025, 10, 1), value: 0.736394),
          SeriesPoint(date: DateTime(2025, 11, 1), value: 1.093764),
          SeriesPoint(date: DateTime(2025, 12, 1), value: 0.851001),
        ],
        type: SeriesKind.simpleMonthlyRate,
      );

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull()!.factor, closeTo(1.02653707, 1e-12));
    });

    test('Taxa Legal reproduz 10,927298% de 30/08/2024 a 31/12/2025', () {
      final result = CalculateValueCorrection(validation).call(
        params: buildValueCorrection(
          index: CorrectionIndex.taxaLegal.sgsCode,
          initial: DateTime(2024, 8, 30),
          end: DateTime(2025, 12, 31),
        ),
        series: [
          SeriesPoint(date: DateTime(2024, 8, 1), value: 0.605306),
          SeriesPoint(date: DateTime(2024, 9, 1), value: 0.676227),
          SeriesPoint(date: DateTime(2024, 10, 1), value: 0.704241),
          SeriesPoint(date: DateTime(2024, 11, 1), value: 0.385874),
          SeriesPoint(date: DateTime(2024, 12, 1), value: 0.171924),
          SeriesPoint(date: DateTime(2025, 1, 1), value: 0.589427),
          SeriesPoint(date: DateTime(2025, 2, 1), value: 0.902209),
          SeriesPoint(date: DateTime(2025, 3, 1), value: 0),
          SeriesPoint(date: DateTime(2025, 4, 1), value: 0.321969),
          SeriesPoint(date: DateTime(2025, 5, 1), value: 0.6232),
          SeriesPoint(date: DateTime(2025, 6, 1), value: 0.775982),
          SeriesPoint(date: DateTime(2025, 7, 1), value: 0.83488),
          SeriesPoint(date: DateTime(2025, 8, 1), value: 0.942622),
          SeriesPoint(date: DateTime(2025, 9, 1), value: 1.305984),
          SeriesPoint(date: DateTime(2025, 10, 1), value: 0.736394),
          SeriesPoint(date: DateTime(2025, 11, 1), value: 1.093764),
          SeriesPoint(date: DateTime(2025, 12, 1), value: 0.851001),
        ],
        type: SeriesKind.simpleMonthlyRate,
      );

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull()!.variation, closeTo(10.927298, 1e-6));
      expect(result.getOrNull()!.factor, closeTo(1.10927298, 1e-8));
    });

    test(
      'retorna erro quando não há pontos na série para o período informado',
      () {
        final result = CalculateValueCorrection(validation).call(
          params: buildValueCorrection(
            initial: DateTime(2024, 2, 1),
            end: DateTime(2024, 2, 10),
          ),
          series: [
            SeriesPoint(date: DateTime(2024, 1, 1), value: 2),
            SeriesPoint(date: DateTime(2024, 1, 2), value: 3),
          ],
          type: SeriesKind.monthlyVariation,
        );

        expect(result.isError, isTrue);
        expect(result.getErrorOrNull(), isA<ValidationFailure>());
        expect(
          result.getErrorOrNull()!.message,
          contains(ValueCorrectionValidationMessage.invalidPeriod),
        );
      },
    );
  });
}
