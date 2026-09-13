import '../../../../core/seed_works/entity.dart';

class FinancialCalculation extends Entity {
  final double initialValue;
  final double rate;
  final int periods;
  final double finalValue;

  FinancialCalculation({
    this.initialValue = 0.0,
    this.rate = 0.0,
    this.periods = 0,
    this.finalValue = 0.0,
  });

  FinancialCalculation copyWith({
    double? initialValue,
    int? periods,
    double? rate,
    double? finalValue,
  }) {
    return FinancialCalculation(
      initialValue: initialValue ?? this.initialValue,
      rate: rate ?? this.rate,
      periods: periods ?? this.periods,
      finalValue: finalValue ?? this.finalValue,
    );
  }
}