import 'package:real_calc/core/seed_works/result.dart';

import '../../../core/errors/failures.dart';
import '../../../core/errors/messages.dart';
import '../domain/entites/series_point.dart';
import '../domain/entites/value_correction.dart';
import '../domain/enum/series_kind.dart';
import '../domain/validation/value_correction_validation.dart';
import 'i_calculate_value_correction.dart';

class CalculateValueCorrection implements ICalculateValueCorrection {
  final ValueCorrectionValidation _validation;

  CalculateValueCorrection(this._validation);

  @override
  Result<Failure, ValueCorrection> call({
    required ValueCorrection params,
    required List<SeriesPoint> series,
    required SeriesKind type,
  }) {
    final validationResult = _validation.validate(params);
    if (validationResult.getErrorOrNull() != null) {
      return FailureResult(validationResult.getErrorOrNull()!);
    }

    final start = DateTime(
      params.period.initial.year,
      params.period.initial.month,
      params.period.initial.day,
    );
    final end = DateTime(
      params.period.end.year,
      params.period.end.month,
      params.period.end.day,
    );

    final filteredSeries = series.where((point) {
      final pointDate = DateTime(
        point.date.year,
        point.date.month,
        point.date.day,
      );
      return !pointDate.isBefore(start) && !pointDate.isAfter(end);
    }).toList();

    if (filteredSeries.isEmpty) {
      return FailureResult(
        ValidationFailure(message: [ValueCorrectionValidationMessage.invalidPeriod]),
      );
    }

    double factor = 1.0;

    switch (type) {
      case SeriesKind.monthlyVariation:
      case SeriesKind.periodRate:
        for (final point in filteredSeries) {
          factor *= (1 + (point.value / 100));
        }
        break;
      case SeriesKind.dailyRate:
        final percentage = params.percentage / 100;
        for (final point in filteredSeries) {
          factor *= (1 + ((point.value / 100) * percentage));
        }
        break;
      case SeriesKind.simpleMonthlyRate:
        double accumulatedRate = 0;
        for (final point in filteredSeries) {
          accumulatedRate += point.value / 100;
        }
        factor = 1 + accumulatedRate;
        break;
    }

    final adjustedValue = params.originalValue != null ? params.originalValue! * factor : null;
    final variation = (factor - 1) * 100;

    return SuccessResult(
      ValueCorrection(
        index: params.index,
        period: params.period,
        percentage: params.percentage,
        originalValue: params.originalValue,
        factor: factor,
        adjustedValue: adjustedValue,
        variation: variation,
      ),
    );
  }
}
