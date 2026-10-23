import 'package:real_calc/core/seed_works/result.dart';

import '../../../../../core/errors/failures.dart';
import '../../../domain/entites/correction_calculation_data.dart';
import '../../../domain/entites/series_point.dart';
import '../../../domain/entites/value_correction.dart';
import '../../../domain/enum/series_kind.dart';
import '../data_validation/i_correction_data_validator.dart';
import '../series_selection/i_correction_index_series_selector.dart';
import '../series_filtering/i_correction_period_series_filter.dart';
import 'i_correction_data_preparer.dart';

class CorrectionDataPreparer implements ICorrectionDataPreparer {
  final ICorrectionDataValidator _validator;
  final ICorrectionPeriodSeriesFilter _periodSeriesFilter;
  final ICorrectionIndexSeriesSelector _indexSeriesSelector;

  CorrectionDataPreparer(
    this._validator,
    this._periodSeriesFilter,
    this._indexSeriesSelector,
  );

  @override
  Result<Failure, CorrectionCalculationData> prepare({
    required ValueCorrection params,
    required List<SeriesPoint> series,
    required SeriesKind type,
  }) {
    final paramsFailure = _validator.validateParams(params);
    if (paramsFailure != null) return FailureResult(paramsFailure);

    final start = _periodSeriesFilter.normalizeDate(params.period.initial);
    final end = _periodSeriesFilter.normalizeDate(params.period.end);
    final filteredSeries = _periodSeriesFilter.filter(
      series: series,
      start: start,
      end: end,
      type: type,
    );
    final taxaLegalRate = _indexSeriesSelector.selectTaxaLegalRate(
      index: params.index,
      series: series,
      start: start,
      end: end,
    );
    final savingsRates = _indexSeriesSelector.selectSavingsRates(
      index: params.index,
      series: series,
      start: start,
      end: end,
    );
    final trRates = _indexSeriesSelector.selectTrRates(
      index: params.index,
      series: series,
      start: start,
      end: end,
    );

    final seriesFailure = _validator.validateSeriesAvailability(
      index: params.index,
      type: type,
      filteredSeries: filteredSeries,
      savingsRates: savingsRates,
      trPeriods: trRates,
      taxaLegalAccumulatedRate: taxaLegalRate,
    );
    if (seriesFailure != null) return FailureResult(seriesFailure);

    final calculationSeries = _indexSeriesSelector.selectCalculationSeries(
      index: params.index,
      type: type,
      filteredSeries: filteredSeries,
      savingsRates: savingsRates,
      trRates: trRates,
    );

    return SuccessResult(
      CorrectionCalculationData(
        filteredSeries: filteredSeries,
        calculationSeries: calculationSeries,
        taxaLegalAccumulatedRate: taxaLegalRate,
      ),
    );
  }
}
