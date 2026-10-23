import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/errors/failures.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/modules/value_correction/domain/entites/period.dart';
import 'package:real_calc/modules/value_correction/domain/entites/series_point.dart';
import 'package:real_calc/modules/value_correction/domain/entites/value_correction.dart';
import 'package:real_calc/modules/value_correction/domain/enum/correction_index.dart';
import 'package:real_calc/modules/value_correction/domain/enum/series_kind.dart';
import 'package:real_calc/modules/value_correction/domain/validation/value_correction_validation.dart';
import 'package:real_calc/modules/value_correction/use_cases/correction/data_validation/correction_data_validator.dart';

void main() {
  late CorrectionDataValidator validator;

  setUp(() {
    validator = CorrectionDataValidator(ValueCorrectionValidation());
  });

  ValueCorrection buildParams({
    DateTime? start,
    DateTime? end,
    double percentage = 100,
    double? value = 100,
  }) {
    return ValueCorrection(
      index: CorrectionIndex.ipca.sgsCode,
      period: Period(
        initial: start ?? DateTime(2024, 1, 1),
        end: end ?? DateTime(2024, 2, 1),
      ),
      percentage: percentage,
      originalValue: value,
      factor: 1,
      adjustedValue: value,
      variation: 0,
    );
  }

  group('CorrectionDataValidator', () {
    test('aceita parâmetros válidos e retorna falha para período inválido', () {
      expect(validator.validateParams(buildParams()), isNull);

      final failure = validator.validateParams(
        buildParams(start: DateTime(2024, 2, 1), end: DateTime(2024, 1, 1)),
      );

      expect(failure, isA<ValidationFailure>());
      expect(
        failure!.message,
        contains(ValueCorrectionValidationMessage.invalidPeriod),
      );
    });

    test('exige pontos para correções não diárias', () {
      final failure = validator.validateSeriesAvailability(
        index: CorrectionIndex.ipca.sgsCode,
        type: SeriesKind.monthlyVariation,
        filteredSeries: const [],
        savingsRates: const [],
        trPeriods: const [],
        taxaLegalAccumulatedRate: null,
      );

      expect(failure, isA<ValidationFailure>());
      expect(
        failure!.message,
        contains(ValueCorrectionValidationMessage.invalidPeriod),
      );
    });

    test('permite série diária vazia, inclusive para CDI', () {
      final failure = validator.validateSeriesAvailability(
        index: CorrectionIndex.cdi.sgsCode,
        type: SeriesKind.dailyRate,
        filteredSeries: const [],
        savingsRates: const [],
        trPeriods: const [],
        taxaLegalAccumulatedRate: null,
      );

      expect(failure, isNull);
    });

    test('verifica dados específicos de poupança, TR e Taxa Legal', () {
      Failure? validate({
        required int index,
        List<SeriesPoint> filtered = const [],
        List<SeriesPoint> savings = const [],
        List<SeriesPoint> tr = const [],
        double? taxaLegal,
      }) {
        return validator.validateSeriesAvailability(
          index: index,
          type: SeriesKind.periodRate,
          filteredSeries: filtered,
          savingsRates: savings,
          trPeriods: tr,
          taxaLegalAccumulatedRate: taxaLegal,
        );
      }

      expect(
        validate(index: CorrectionIndex.poupancaNova.sgsCode),
        isA<ValidationFailure>(),
      );
      expect(
        validate(index: CorrectionIndex.tr.sgsCode),
        isA<ValidationFailure>(),
      );
      expect(
        validate(index: CorrectionIndex.taxaLegal.sgsCode),
        isA<ValidationFailure>(),
      );
      expect(
        validate(
          index: CorrectionIndex.poupancaNova.sgsCode,
          filtered: [SeriesPoint(date: DateTime(2024, 1, 1), value: 1)],
          savings: [SeriesPoint(date: DateTime(2024, 2, 1), value: 1)],
        ),
        isNull,
      );
      expect(
        validate(
          index: CorrectionIndex.tr.sgsCode,
          filtered: [SeriesPoint(date: DateTime(2024, 1, 1), value: 1)],
          tr: [SeriesPoint(date: DateTime(2024, 1, 1), value: 1)],
        ),
        isNull,
      );
      expect(
        validate(index: CorrectionIndex.taxaLegal.sgsCode, taxaLegal: 0.01),
        isNull,
      );
    });
  });
}
