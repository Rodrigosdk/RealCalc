import 'dart:math';

import 'package:real_calc/core/errors/failures.dart';
import 'package:real_calc/core/seed_works/result.dart';
import '../entities/financing.dart';
import '../enum/calculate_financing_type.dart';
import '../validation/financing_validator.dart';

class CalculateCompoundInterestUseCase {
  final FinancingValidator validator;

  CalculateCompoundInterestUseCase(this.validator);

  Result<Failure, double> calculateFinalValue(Financing params) {
    return validator.validateForFinalValue(params).map((financing) {
      final realRate = financing.rate / 100;
      return financing.initialValue *
          pow(1 + realRate, financing.months.toDouble());
    });
  }

  Result<Failure, double> calculateRate(Financing params) {
    return validator.validateForRate(params).map((financing) {
      return (pow(
                financing.finalValue / financing.initialValue,
                1.0 / financing.months.toDouble(),
              ) -
              1) *
          100;
    });
  }

  Result<Failure, int> calculateMonths(Financing params) {
    return validator.validateForMonths(params).map((financing) {
      final realRate = financing.rate / 100;
      return (log(financing.finalValue / financing.initialValue) /
              log(1 + realRate))
          .ceil()
          .toInt();
    });
  }

  Result<Failure, double> calculateInitialValue(Financing params) {
    return validator.validateForInitialValue(params).map((financing) {
      final realRate = financing.rate / 100;
      return financing.finalValue /
          pow(1 + realRate, financing.months.toDouble());
    });
  }

  Result<Failure, double> calculate(Financing params){
    return validator.detectTypeCalculation(params).fold(
      (error) => FailureResult<Failure, double>(error),
      (calculationType) {
        return switch(calculationType) {
          CalculateFinancingType.finalValue => calculateFinalValue(params),
          CalculateFinancingType.rate => calculateRate(params),
          CalculateFinancingType.months => calculateMonths(params).map((value) => value.toDouble()),
          CalculateFinancingType.initialValue => calculateInitialValue(params),
        };
      },
    );
  }
}
