import 'dart:math';

import 'package:real_calc/core/utils/result.dart';
import 'package:real_calc/core/utils/validation.dart';
import '../entities/financing.dart';
import '../validation/financing_validator.dart';

class CalculateCompoundInterestUseCase {
  final FinancingValidator validator;

  CalculateCompoundInterestUseCase(this.validator);

  Result<ValidationFailure, double> calculateFinalValue(Financing params) {
    return validator.validateForFinalValue(params).map((financing) {
      final realRate = financing.rate / 100;
      return financing.initialValue *
          pow(1 + realRate, financing.months.toDouble());
    });
  }

  Result<ValidationFailure, double> calculateRate(Financing params) {
    return validator.validateForRate(params).map((financing) {
      return (pow(
                financing.finalValue / financing.initialValue,
                1.0 / financing.months.toDouble(),
              ) -
              1) *
          100;
    });
  }

  Result<ValidationFailure, int> calculateMonths(Financing params) {
    return validator.validateForMonths(params).map((financing) {
      final realRate = financing.rate / 100;
      return (log(financing.finalValue / financing.initialValue) /
              log(1 + realRate))
          .ceil()
          .toInt();
    });
  }

  Result<ValidationFailure, double> calculateInitialValue(Financing params) {
    return validator.validateForInitialValue(params).map((financing) {
      final realRate = financing.rate / 100;
      return financing.finalValue /
          pow(1 + realRate, financing.months.toDouble());
    });
  }
}
