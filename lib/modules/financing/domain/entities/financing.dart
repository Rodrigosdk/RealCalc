import 'package:real_calc/core/seed_works/entity.dart';

class Financing extends Entity{
  final double initialValue;
  final double finalValue;
  final double rate;
  final int months;

  Financing({
    super.id,
    super.createdAt,
    super.updatedAt,
    this.initialValue = 0,
    this.finalValue = 0,
    this.rate = 0,
    this.months = 0,
  });
}
