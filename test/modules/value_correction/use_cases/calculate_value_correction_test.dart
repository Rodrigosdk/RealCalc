import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/errors/failures.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/modules/value_correction/domain/entites/period.dart';
import 'package:real_calc/modules/value_correction/domain/entites/series_point.dart';
import 'package:real_calc/modules/value_correction/domain/entites/value_correction.dart';
import 'package:real_calc/modules/value_correction/domain/enum/series_kind.dart';
import 'package:real_calc/modules/value_correction/domain/validation/value_correction_validation.dart';
import 'package:real_calc/modules/value_correction/use_cases/calculate_value_correction.dart';

void main() {
  late ValueCorrectionValidation validation;

  setUp(() {
    validation = ValueCorrectionValidation();
  });

  ValueCorrection buildValueCorrection({
    DateTime? initial,
    DateTime? end,
    double percentage = 100,
    double? originalValue,
  }) {
    return ValueCorrection(
      index: 1,
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

    test('calcula o fator para taxa diária considerando o percentual', () {
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
      expect(firstResult.getOrNull()!.factor, closeTo(1.0302, 1e-9));
      expect(secondResult.getOrNull()!.factor, closeTo(1.024128, 1e-9));
      expect(secondResult.getOrNull()!.factor, lessThan(firstResult.getOrNull()!.factor));
    });

    test('case de referência: IPCA de 01/2003 a 01/2003 produz fator 1,0225', () {
      final result = CalculateValueCorrection(validation).call(
        params: buildValueCorrection(
          initial: DateTime(2003, 1, 1),
          end: DateTime(2003, 1, 1),
          originalValue: 1000,
        ),
        series: [
          SeriesPoint(date: DateTime(2003, 1, 1), value: 2.25),
        ],
        type: SeriesKind.monthlyVariation,
      );

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull()!.factor, closeTo(1.0225, 1e-12));
    });

    test('case de referência: IPCA de 01/2003 a 12/2003 produz fator 1,0929994', () {
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
    });

    test('case de referência: INPC de 01/1994 a 06/1994 com valor 1000 produz 8591,50', () {
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
    });

    test('case de referência: INPC de 01/1989 a 05/1989 produz fator 2,1046', () {
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
    });

    test('retorna erro quando não há pontos na série para o período informado', () {
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
    });
  });
}
