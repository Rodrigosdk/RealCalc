import 'package:real_calc/core/seed_works/entity.dart';

import 'period.dart';


class ValueCorrection extends Entity {
  final int index;
  final Period period;
  final double percentage;
  final double? originalValue;
  final double factor;
  final double? adjustedValue;
  final double variation;

  ValueCorrection({
    required this.index,
    required this.period,
    required this.percentage,
    required this.originalValue,
    required this.factor,
    required this.adjustedValue,
    required this.variation,
  });
}
