import 'package:real_calc/core/seed_works/entity.dart';

class Metric extends Entity {
  final double anualRate;
  final double variationPercent;
  final List<double> sparklineData;
  final List<DateTime> sparklineDates;
  final DateTime? lastDate;

  Metric({
    required this.anualRate,
    required this.variationPercent,
    required this.sparklineData,
    this.sparklineDates = const [],
    this.lastDate,
  });
}
