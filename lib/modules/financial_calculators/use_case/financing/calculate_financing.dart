import 'dart:math';

import 'package:real_calc/core/errors/failures.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/core/seed_works/result.dart';

import '../../domain/entities/financial_calculation.dart';
import '../../domain/validation/calculation_limits.dart';
import '../../domain/validation/solving.dart';
import '../../domain/enum/financial_calculation_target.dart';
import '../../domain/validation/compound_interest_validator.dart';

import 'i_calculate_financing.dart';

class CalculateFinancing implements ICalculateFinancing {
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
          case FinancialCalculationTarget
              .finalValue: // Mapeado para Valor da Prestação (p)
            return _calculatePayment(
              params,
            ).map((value) => params.copyWith(finalValue: value));
          case FinancialCalculationTarget.interestRate: // Taxa de juros (j)
            return _calculateRate(
              params,
            ).map((value) => params.copyWith(rate: value));
          case FinancialCalculationTarget.periods: // Prazo / Nº de meses (n)
            return _calculateMonths(
              params,
            ).map((value) => params.copyWith(periods: value));
          case FinancialCalculationTarget.initialValue: // Valor Financiado (q0)
            return _calculateInitialValue(
              params,
            ).map((value) => params.copyWith(initialValue: value));
        }
      },
    );
  }

  /// Calcula o valor da Prestação (p):
  /// p = q0 * [ j / (1 - (1 + j)^(-n)) ]
  Result<Failure, double> _calculatePayment(FinancialCalculation params) {
    final j = params.rate / 100;
    final n = params.periods;
    final q0 = params.initialValue;

    final p = q0 * (j / (1 - pow(1 + j, -n)));

    return SuccessResult<Failure, double>(p);
  }

  /// Calcula a Taxa de Juros (j) por bisseção sobre a prestação p.
  Result<Failure, double> _calculateRate(FinancialCalculation params) {
    final q0 = params.initialValue;
    final n = params.periods;
    final p = params.finalValue;

    if (p * n <= q0) {
      return FailureResult<Failure, double>(
        const ValidationFailure(
          message: [FinancingValidationMessage.noPositiveRate],
        ),
      );
    }

    double paymentFor(double j) => q0 * j / (1 - pow(1 + j, -n));

    // A prestação é sempre maior que os juros do mês (q0 * j), então a taxa
    // fica abaixo de p / q0.
    final j = solveIncreasing((j) => paymentFor(j) - p, 0, p / q0);

    return SuccessResult<Failure, double>(j * 100);
  }

  /// Calcula a quantidade de Meses (n):
  /// n = -log(1 - (q0 * j) / p) / log(1 + j)
  Result<Failure, int> _calculateMonths(FinancialCalculation params) {
    final j = params.rate / 100;
    final q0 = params.initialValue;
    final p = params.finalValue;

    final firstMonthInterest = q0 * j;
    if (p + halfCent <= firstMonthInterest) {
      return FailureResult<Failure, int>(
        ValidationFailure(
          message: [PaymentBelowInterestError(firstMonthInterest)],
        ),
      );
    }

    double monthsFor(double payment) => payment <= firstMonthInterest
        ? double.infinity
        : -log(1 - firstMonthInterest / payment) / log(1 + j);

    return periodsFromMoney(value: p, periodsFor: monthsFor).fold(
      (failure) => FailureResult<Failure, int>(failure),
      (months) => months < 1
          ? FailureResult<Failure, int>(
              const ValidationFailure(
                message: [FinancingValidationMessage.paymentAboveDebt],
              ),
            )
          : SuccessResult<Failure, int>(months),
    );
  }

  /// Calcula o Valor Financiado (q0):
  /// q0 = [ (1 - (1 + j)^(-n)) / j ] * p
  Result<Failure, double> _calculateInitialValue(FinancialCalculation params) {
    final j = params.rate / 100;
    final n = params.periods.toDouble();
    final p = params.finalValue;

    final q0 = ((1 - pow(1 + j, -n)) / j) * p;

    return SuccessResult<Failure, double>(q0);
  }
}
