import 'dart:math';

import 'package:real_calc/core/errors/failures.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/core/seed_works/result.dart';
import 'package:real_calc/modules/financial_calculators/domain/validation/compound_interest_validator.dart';

import '../../domain/entities/financial_calculation.dart';
import '../../domain/validation/calculation_limits.dart';
import '../../domain/validation/solving.dart';
import '../../domain/enum/financial_calculation_target.dart';
import 'i_calculate_deposit.dart';

class CalculateDeposit implements ICalculateDeposit {
  @override
  Result<Failure, FinancialCalculation> calculate(
    FinancialCalculation params,
  ) => _calculate(params).fold(
    (failure) => FailureResult<Failure, FinancialCalculation>(failure),
    (result) => ensureWithinLimits(
      result,
      calculated: detectCompoundInterestTarget(params).getOrNull(),
    ),
  );

  Result<Failure, FinancialCalculation> _calculate(
    FinancialCalculation params,
  ) {
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
    final deposit = params.initialValue;

    if (rate == 0) {
      return SuccessResult<Failure, int>((params.finalValue / deposit).round());
    }

    double periodsFor(double value) =>
        log(value * rate / (deposit * (1 + rate)) + 1) / log(1 + rate);

    return periodsFromMoney(
      value: params.finalValue,
      periodsFor: periodsFor,
    ).fold(
      (failure) => FailureResult<Failure, int>(failure),
      (periods) => periods < 1
          ? FailureResult<Failure, int>(
              const ValidationFailure(
                message: [
                  RegularDepositsValidationMessage.finalBelowFirstMonth,
                ],
              ),
            )
          : SuccessResult<Failure, int>(periods),
    );
  }

  Result<Failure, double> _calculateInterestRate(FinancialCalculation params) {
    final deposit = params.initialValue;
    final periods = params.periods;
    final finalValue = params.finalValue;

    if (finalValue <= deposit * periods) {
      return FailureResult<Failure, double>(
        const ValidationFailure(
          message: [RegularDepositsValidationMessage.noPositiveRate],
        ),
      );
    }

    double finalValueFor(double rate) =>
        deposit * ((pow(1 + rate, periods) - 1) / rate) * (1 + rate);

    // O valor final é sempre maior que deposit * (1 + rate)^periods, então a
    // taxa fica abaixo da que faz só esse termo chegar ao valor final.
    final upper = pow(finalValue / deposit, 1 / periods) - 1;
    final rate = solveIncreasing(
      (rate) => finalValueFor(rate) - finalValue,
      0,
      upper.toDouble(),
    );

    return SuccessResult<Failure, double>(rate * 100);
  }
}
