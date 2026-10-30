import 'package:real_calc/core/seed_works/entity.dart';

class Metric extends Entity {
  final double anualRate;
  final double variationPercent;
  final List<double> sparklineData;
  final List<DateTime> sparklineDates;
  final DateTime? lastDate;
  final bool offline;

  Metric({
    required this.anualRate,
    required this.variationPercent,
    required this.sparklineData,
    this.sparklineDates = const [],
    this.lastDate,
    this.offline = false,
    super.updatedAt,
  });

  Metric copyWith({
    List<double>? sparklineData,
    List<DateTime>? sparklineDates,
    bool? offline,
    DateTime? updatedAt,
  }) {
    return Metric(
      anualRate: anualRate,
      variationPercent: variationPercent,
      sparklineData: sparklineData ?? this.sparklineData,
      sparklineDates: sparklineDates ?? this.sparklineDates,
      lastDate: lastDate,
      offline: offline ?? this.offline,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
