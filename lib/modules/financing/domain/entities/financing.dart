// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:real_calc/core/seed_works/entity.dart';

class Financing extends Entity {
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

  Financing copyWith({
    double? initialValue,
    double? finalValue,
    double? rate,
    int? months,
  }) {
    return Financing(
      initialValue: initialValue ?? this.initialValue,
      finalValue: finalValue ?? this.finalValue,
      rate: rate ?? this.rate,
      months: months ?? this.months,
    );
  }
}
