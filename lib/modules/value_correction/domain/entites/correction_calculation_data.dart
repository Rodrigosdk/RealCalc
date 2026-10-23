import 'series_point.dart';

class CorrectionCalculationData {
  final List<SeriesPoint> filteredSeries;
  final List<SeriesPoint> calculationSeries;
  final double? taxaLegalAccumulatedRate;

  const CorrectionCalculationData({
    required this.filteredSeries,
    required this.calculationSeries,
    required this.taxaLegalAccumulatedRate,
  });
}
