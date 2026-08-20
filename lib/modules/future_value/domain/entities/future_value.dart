import 'package:real_calc/core/seed_works/entity.dart';

class FutureValue extends Entity{
  final double? capital;
  final int? months;
  final double? interestRate;
  final double? finalValue;

  FutureValue({
    this.capital = 0,
    this.months = 0,
    this.interestRate = 0,
    this.finalValue = 0,
  });

  FutureValue copyWith({
    double? capital,
    int? months,
    double? interestRate,
    double? finalValue,
  }) {
    return FutureValue(
      capital: capital ?? this.capital,
      months: months ?? this.months,
      interestRate: interestRate ?? this.interestRate,
      finalValue: finalValue ?? this.finalValue,
    );
  }
}