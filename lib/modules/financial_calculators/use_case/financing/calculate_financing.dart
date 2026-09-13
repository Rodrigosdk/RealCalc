import 'dart:math';

import 'package:real_calc/core/errors/failures.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/core/seed_works/result.dart';

import '../../domain/entities/financial_calculation.dart';
import '../../domain/enum/financial_calculation_target.dart';
import '../../domain/validation/compound_interest_validator.dart';

import 'i_calculate_financing.dart';

class CalculateFinancing implements ICalculateFinancing {
  @override
  Result<Failure, FinancialCalculation> calculate(FinancialCalculation params) {
    if (params.initialValue <= 0 && params.rate <= 0) {
      return FailureResult<Failure, FinancialCalculation>(
        ValidationFailure(
          message: [
            FinancialCalculationValidationMessage.invalidParameterCount,
          ],
        ),
      );
    }

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
            return _calculateMonths(
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

  Result<Failure, int> _calculateMonths(FinancialCalculation params) {
    final rate = params.rate / 100;

    final result =
        (log(params.finalValue / params.initialValue) / log(1 + rate)).round();

    return SuccessResult<Failure, int>(result);
  }

  Result<Failure, double> _calculateInitialValue(FinancialCalculation params) {
    final realRate = params.rate / 100;
    final result =
        params.finalValue / pow(1 + realRate, params.periods.toDouble());

    return SuccessResult<Failure, double>(result);
  }
}
