import 'package:real_calc/core/seed_works/result.dart';

import '../../../core/errors/failures.dart';
import '../domain/entites/correction_calculation_data.dart';
import '../domain/entites/series_point.dart';
import '../domain/entites/value_correction.dart';
import '../domain/enum/series_kind.dart';
import 'correction/data_preparation/i_correction_data_preparer.dart';
import 'correction/rate_calculation/i_correction_rate_calculator.dart';
import 'i_calculate_value_correction.dart';

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

    return SuccessResult(
      ValueCorrection(
        index: params.index,
        period: params.period,
        percentage: params.percentage,
        originalValue: params.originalValue,
        factor: factor,
        adjustedValue: _calculateAdjustedValue(params.originalValue, factor),
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
