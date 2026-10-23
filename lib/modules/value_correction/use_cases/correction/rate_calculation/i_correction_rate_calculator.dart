import '../../../domain/entites/series_point.dart';

abstract interface class ICorrectionRateCalculator {
  double calculateMonthlyVariation(List<SeriesPoint> series);

  double calculateDailyRate(List<SeriesPoint> series, double percentage);

  double calculatePeriodRate(List<SeriesPoint> series);

  double calculateSimpleMonthlyRate(
    List<SeriesPoint> series, {
    double? taxaLegalAccumulatedRate,
  });

  double? calculateTaxaLegalAccumulatedRate(
    List<SeriesPoint> series,
    DateTime start,
    DateTime end,
  );
}
