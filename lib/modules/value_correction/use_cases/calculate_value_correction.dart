import 'package:real_calc/core/seed_works/result.dart';

import '../../../core/errors/failures.dart';
import '../../../core/errors/messages.dart';
import '../domain/entites/series_point.dart';
import '../domain/entites/value_correction.dart';
import '../domain/enum/correction_index.dart';
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

      final isAfterStart = type == SeriesKind.dailyRate
          ? pointDate.isAfter(start)
          : !pointDate.isBefore(start);
      return isAfterStart && !pointDate.isAfter(end);
    }).toList();

    final isTaxaLegal = params.index == CorrectionIndex.taxaLegal.sgsCode;
    final taxaLegalAccumulatedRate = isTaxaLegal
        ? _calculateTaxaLegalAccumulatedRate(series, start, end)
        : null;

    final trPeriods = params.index == CorrectionIndex.tr.sgsCode
        ? _selectTrRates(series, start, end)
        : const <SeriesPoint>[];

    if (((isTaxaLegal && taxaLegalAccumulatedRate == null) ||
            (!isTaxaLegal && filteredSeries.isEmpty) ||
            (params.index == CorrectionIndex.tr.sgsCode &&
                trPeriods.isEmpty)) &&
        type != SeriesKind.dailyRate) {
      return FailureResult(
        ValidationFailure(
          message: [ValueCorrectionValidationMessage.invalidPeriod],
        ),
      );
    }

    double factor = 1.0;

    switch (type) {
      case SeriesKind.monthlyVariation:
        for (final point in filteredSeries) {
          factor *= (1 + (point.value / 100));
        }
        break;
      case SeriesKind.periodRate:
        final points = params.index == CorrectionIndex.tr.sgsCode
            ? trPeriods
            : filteredSeries;
        for (final point in points) {
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
        if (isTaxaLegal) {
          factor = 1 + (taxaLegalAccumulatedRate ?? 0);
        } else {
          final accumulatedRate = filteredSeries.fold<double>(
            0,
            (total, point) => total + point.value / 100,
          );
          factor = 1 + accumulatedRate;
        }
        break;
    }

    final adjustedValue = params.originalValue != null
        ? params.originalValue! * factor
        : null;
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

  List<SeriesPoint> _selectTrRates(
    List<SeriesPoint> series,
    DateTime start,
    DateTime end,
  ) {
    final rates = <SeriesPoint>[];
    var cursor = start;

    while (cursor.isBefore(end)) {
      final nextAnniversary = _nextMonthlyAnniversary(cursor);
      if (nextAnniversary.isAfter(end)) break;

      final candidates =
          series
              .where(
                (point) =>
                    _sameDate(point.date, cursor) && point.periodEnd != null,
              )
              .toList()
            ..sort((a, b) => a.periodEnd!.compareTo(b.periodEnd!));

      if (candidates.isEmpty) break;

      final selected = cursor.day == 1
          ? candidates.first
          : candidates.firstWhere(
              (point) => _sameDate(point.periodEnd!, nextAnniversary),
              orElse: () => candidates.last,
            );
      rates.add(selected);
      cursor = selected.periodEnd!;
      if (cursor.day == DateTime(cursor.year, cursor.month + 1, 0).day) {
        cursor = cursor.add(const Duration(days: 1));
      }
    }

    if (rates.isEmpty) {
      return const <SeriesPoint>[];
    }

    if (!_sameDate(cursor, end)) {
      final finalDateRate = series.where((point) {
        return _sameDate(point.date, end);
      }).toList();
      if (finalDateRate.isEmpty) return const <SeriesPoint>[];
      rates.add(finalDateRate.first);
    }

    return rates;
  }

  DateTime _nextMonthlyAnniversary(DateTime date) {
    final monthStart = DateTime(date.year, date.month + 1, 1);
    final lastDay = DateTime(monthStart.year, monthStart.month + 1, 0).day;
    return DateTime(
      monthStart.year,
      monthStart.month,
      date.day > lastDay ? lastDay : date.day,
    );
  }

  double? _calculateTaxaLegalAccumulatedRate(
    List<SeriesPoint> series,
    DateTime start,
    DateTime end,
  ) {
    if (!start.isBefore(end)) return 0;

    var accumulatedRate = 0.0;
    var monthStart = DateTime(start.year, start.month);

    while (monthStart.isBefore(end)) {
      final nextMonth = DateTime(monthStart.year, monthStart.month + 1);
      final overlapStart = start.isAfter(monthStart) ? start : monthStart;
      final overlapEnd = end.isBefore(nextMonth) ? end : nextMonth;
      final elapsedDays = overlapEnd.difference(overlapStart).inDays;

      if (elapsedDays > 0) {
        final monthRates = series.where((point) {
          return point.date.year == monthStart.year &&
              point.date.month == monthStart.month;
        });
        if (monthRates.isEmpty) return null;

        final daysInMonth = nextMonth.difference(monthStart).inDays;
        final proratedRatePercent =
            (monthRates.first.value * elapsedDays / daysInMonth * 1000000)
                .round() /
            1000000;
        accumulatedRate += proratedRatePercent / 100;
      }

      monthStart = nextMonth;
    }

    return accumulatedRate;
  }

  bool _sameDate(DateTime left, DateTime right) =>
      left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}
