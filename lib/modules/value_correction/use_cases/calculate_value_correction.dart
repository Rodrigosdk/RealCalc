import 'package:real_calc/core/seed_works/result.dart';

import '../../../core/errors/failures.dart';
import '../../../core/errors/messages.dart';
import '../domain/entities/correction_calculation_data.dart';
import '../domain/entities/series_point.dart';
import '../domain/entities/value_correction.dart';
import '../domain/enum/series_kind.dart';
import 'correction/data_preparation/i_correction_data_preparer.dart';
import 'correction/rate_calculation/i_correction_rate_calculator.dart';
import 'i_calculate_value_correction.dart';

/// R\$ 1 trilhão, o mesmo limite das calculadoras financeiras.
const maxCorrectedValue = 1e12;

class CalculateValueCorrection implements ICalculateValueCorrection {
  final ICorrectionDataPreparer _dataPreparer;
  final ICorrectionRateCalculator _rateCalculator;

  CalculateValueCorrection(this._dataPreparer, this._rateCalculator);

  @override
  Result<Failure, ValueCorrection> call({
    required ValueCorrection params,
    required List<SeriesPoint> series,
    required SeriesKind type,
  }) {
    final preparationResult = _dataPreparer.prepare(
      params: params,
      series: series,
      type: type,
    );

    final preparationFailure = preparationResult.getErrorOrNull();
    if (preparationFailure != null) {
      return FailureResult(preparationFailure);
    }
    final calculationData = preparationResult.getOrNull()!;

    final factor = _calculateFactor(
      type: type,
      percentage: params.percentage,
      calculationData: calculationData,
    );

    final adjustedValue = _calculateAdjustedValue(params.originalValue, factor);
    if (!factor.isFinite ||
        (adjustedValue != null &&
            (!adjustedValue.isFinite || adjustedValue > maxCorrectedValue))) {
      return FailureResult(
        const ValidationFailure(
          message: [ValueCorrectionValidationMessage.resultOutOfRange],
        ),
      );
    }

    return SuccessResult(
      ValueCorrection(
        index: params.index,
        period: params.period,
        percentage: params.percentage,
        originalValue: params.originalValue,
        factor: factor,
        adjustedValue: adjustedValue,
        variation: _calculateVariation(factor),
      ),
    );
  }

  double _calculateFactor({
    required SeriesKind type,
    required double percentage,
    required CorrectionCalculationData calculationData,
  }) {
    return switch (type) {
      SeriesKind.monthlyVariation => _rateCalculator.calculateMonthlyVariation(
        calculationData.filteredSeries,
      ),
      SeriesKind.periodRate => _rateCalculator.calculatePeriodRate(
        calculationData.calculationSeries,
      ),
      SeriesKind.dailyRate => _rateCalculator.calculateDailyRate(
        calculationData.filteredSeries,
        percentage,
      ),
      SeriesKind.simpleMonthlyRate =>
        _rateCalculator.calculateSimpleMonthlyRate(
          calculationData.filteredSeries,
          taxaLegalAccumulatedRate: calculationData.taxaLegalAccumulatedRate,
        ),
    };
  }

  double? _calculateAdjustedValue(double? originalValue, double factor) =>
      originalValue == null ? null : originalValue * factor;

  double _calculateVariation(double factor) => (factor - 1) * 100;
}
