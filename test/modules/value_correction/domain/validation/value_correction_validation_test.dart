import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/errors/failures.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/modules/value_correction/domain/entites/period.dart';
import 'package:real_calc/modules/value_correction/domain/entites/value_correction.dart';
import 'package:real_calc/modules/value_correction/domain/validation/value_correction_validation.dart';

void main() {
  late ValueCorrectionValidation validation;

  setUp(() {
    validation = ValueCorrectionValidation();
  });

  ValueCorrection buildValueCorrection({
    DateTime? initial,
    DateTime? end,
    double percentage = 10,
    double? originalValue,
  }) {
    return ValueCorrection(
      index: 1,
      period: Period(
        initial: initial ?? DateTime(2024, 1, 1),
        end: end ?? DateTime(2024, 2, 1),
      ),
      percentage: percentage,
      originalValue: originalValue ?? 100,
      factor: 1.2,
      adjustedValue: 120,
      variation: 20,
    );
  }

  group('ValueCorrectionValidation', () {
    test('aceita parâmetros válidos', () {
      final result = validation.validate(
        buildValueCorrection(
          initial: DateTime(2024, 1, 1),
          end: DateTime(2024, 2, 1),
          percentage: 5,
          originalValue: 200,
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull(), isNull);
    });

    test('rejeita período com data inicial maior que a data final', () {
      final result = validation.validate(
        buildValueCorrection(
          initial: DateTime(2024, 2, 1),
          end: DateTime(2024, 1, 1),
        ),
      );

      expect(result.isError, isTrue);
      final failure = result.getErrorOrNull();
      expect(failure, isA<ValidationFailure>());
      expect(
        failure?.message,
        contains(ValueCorrectionValidationMessage.invalidPeriod),
      );
    });

    test('rejeita percentual menor que zero', () {
      final result = validation.validate(
        buildValueCorrection(percentage: -1),
      );

      expect(result.isError, isTrue);
      final failure = result.getErrorOrNull();
      expect(failure, isA<ValidationFailure>());
      expect(
        failure?.message,
        contains(ValueCorrectionValidationMessage.invalidPercentage),
      );
    });

    test('rejeita valor original menor que zero', () {
      final result = validation.validate(
        buildValueCorrection(originalValue: -1),
      );

      expect(result.isError, isTrue);
      final failure = result.getErrorOrNull();
      expect(failure, isA<ValidationFailure>());
      expect(
        failure?.message,
        contains(ValueCorrectionValidationMessage.invalidValue),
      );
    });
  });
}