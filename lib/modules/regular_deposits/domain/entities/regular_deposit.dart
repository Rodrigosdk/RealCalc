import 'package:real_calc/core/seed_works/entity.dart';

class RegularDeposit extends Entity {
  final double depositAmount;
  final double rate;
  final int months;
  final double finalValue;

  RegularDeposit({
    super.id,
    this.depositAmount = 0,
    this.rate = 0,
    this.months = 0,
    this.finalValue = 0,
  });

  RegularDeposit copyWith({
    double? depositAmount,
    double? rate,
    int? months,
    double? finalValue,
  }) {
    return RegularDeposit(
      depositAmount: depositAmount ?? this.depositAmount,
      rate: rate ?? this.rate,
      months: months ?? this.months,
      finalValue: finalValue ?? this.finalValue,
    );
  }
}
