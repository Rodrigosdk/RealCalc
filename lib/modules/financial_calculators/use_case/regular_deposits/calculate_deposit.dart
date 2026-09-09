import 'dart:math';

import 'package:real_calc/core/errors/failures.dart';
import 'package:real_calc/core/seed_works/result.dart';
import 'package:real_calc/modules/financial_calculators/domain/validation/compound_interest_validator.dart';

import '../../domain/entities/financial_calculation.dart';
import '../../domain/enum/financial_calculation_target.dart';
import 'i_calculate_deposit.dart';

class CalculateDeposit implements ICalculateDeposit {

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
            return _calculateInterestRate(
              params,
            ).map((value) => params.copyWith(rate: value));
          case FinancialCalculationTarget.periods:
            return _calculateNumberOfPeriods(
              params,
            ).map((value) => params.copyWith(periods: value));
          case FinancialCalculationTarget.initialValue:
            return _calculateDepositAmount(
              params,
            ).map((value) => params.copyWith(initialValue: value));
        }
      },
    );
  }
  Result<Failure, double> _calculateFinalValue(FinancialCalculation params) {
    final rate = params.rate / 100;

    if (rate == 0) {
      final result = params.initialValue * params.periods;

      return SuccessResult<Failure, double>(result);
    }

    final result =
      params.initialValue *
        ((pow(1 + rate, params.periods) - 1) / rate) *
        (1 + rate);

    return SuccessResult<Failure, double>(result.toDouble());
  }

  Result<Failure, double> _calculateDepositAmount(FinancialCalculation params) {
    final rate = params.rate / 100;

    if (rate == 0) {
      final result = params.finalValue / params.periods;

      return SuccessResult<Failure, double>(result);
    }

    final result =
        params.finalValue /
        (((pow(1 + rate, params.periods) - 1) / rate) * (1 + rate));

    return SuccessResult<Failure, double>(result.toDouble());
  }

  Result<Failure, int> _calculateNumberOfPeriods(FinancialCalculation params) {
    final rate = params.rate / 100;

    if (rate == 0) {
      final result = (params.finalValue / params.initialValue).round();

      return SuccessResult<Failure, int>(result);
    }

    final adjustedFinalValue = params.finalValue / (1 + rate);

    final result =
      (log(adjustedFinalValue * rate / params.initialValue + 1) /
                log(1 + rate))
            .round();

    return SuccessResult<Failure, int>(result);
  }

  Result<Failure, double> _calculateInterestRate(FinancialCalculation params) {
    final periods = params.periods;
    final finalValue = params.finalValue;

    if (finalValue <= params.initialValue * periods) {
      return SuccessResult<Failure, double>(0.0);
    }

    var rate = 0.1;
    const precision = 1e-7;
    const maxIterations = 100;

    for (var iteration = 0; iteration < maxIterations; iteration++) {
      final power = pow(1 + rate, periods).toDouble();
      final previousPower = pow(1 + rate, periods - 1).toDouble();

      final functionValue =
          params.initialValue * ((power - 1) / rate) * (1 + rate) - finalValue;

      final derivative =
          params.initialValue *
          (((periods * previousPower * rate - power + 1) / (rate * rate)) *
                  (1 + rate) +
              ((power - 1) / rate));

      final nextRate = rate - functionValue / derivative;

      if ((nextRate - rate).abs() < precision) {
        return SuccessResult<Failure, double>(nextRate * 100);
      }

      rate = nextRate;
    }

    return SuccessResult<Failure, double>(rate * 100);
  }  
}
