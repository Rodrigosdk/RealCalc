import 'dart:math';

import 'package:real_calc/core/errors/failures.dart';
import 'package:real_calc/core/seed_works/result.dart';

import '../../domain/entities/financial_calculation.dart';
import '../../domain/enum/financial_calculation_target.dart';
import '../../domain/validation/compound_interest_validator.dart';
import 'i_calculate_future_value.dart';

class CalculateFutureValue implements ICalculateFutureValue {
  @override
  Result<Failure, FinancialCalculation> calculate(FinancialCalculation params) {
    return detectCompoundInterestTarget(params).fold(
      (failure) => FailureResult<Failure, FinancialCalculation>(failure),
      (target) {
        switch (target) {
          case FinancialCalculationTarget.finalValue:
            return _calculateFinalValue(
              params,
            ).map((value) => params.copyWith(finalValue: value));

          case FinancialCalculationTarget.interestRate:
            return _calculateRate(
              params,
            ).map((value) => params.copyWith(rate: value));

          case FinancialCalculationTarget.periods:
            return _calculatePeriods(
              params,
            ).map((value) => params.copyWith(periods: value));

          case FinancialCalculationTarget.initialValue:
            return _calculateInitialValue(
              params,
            ).map((value) => params.copyWith(initialValue: value));
        }
      },
    );
  }

  Result<Failure, double> _calculateFinalValue(FinancialCalculation params) {
    final result =
        params.initialValue *
        pow(1 + params.rate / 100, params.periods).toDouble();

    return SuccessResult<Failure, double>(result);
  }

  Result<Failure, double> _calculateRate(FinancialCalculation params) {
    final result =
        (pow(
              params.finalValue / params.initialValue,
              1 / params.periods,
            ).toDouble() -
            1) *
        100;

    return SuccessResult<Failure, double>(result);
  }

  Result<Failure, int> _calculatePeriods(FinancialCalculation params) {
    final result =
        (log(params.finalValue / params.initialValue) /
                log(1 + params.rate / 100))
            .round();

    return SuccessResult<Failure, int>(result);
  }

  Result<Failure, double> _calculateInitialValue(FinancialCalculation params) {
    final result =
        params.finalValue /
        pow(1 + params.rate / 100, params.periods).toDouble();

    return SuccessResult<Failure, double>(result);
  }
}
