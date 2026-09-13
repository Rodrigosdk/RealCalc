

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/messages.dart';
import '../../../../core/seed_works/result.dart';
import '../entities/financial_calculation.dart';
import '../enum/financial_calculation_target.dart';

Result<Failure, FinancialCalculationTarget> detectCompoundInterestTarget(
  FinancialCalculation params,
) {
  final emptyFields = <FinancialCalculationTarget>[];

  if (params.initialValue <= 0) {
    emptyFields.add(FinancialCalculationTarget.initialValue);
  }
  if (params.finalValue <= 0) {
    emptyFields.add(FinancialCalculationTarget.finalValue);
  }
  if (params.periods <= 0) {
    emptyFields.add(FinancialCalculationTarget.periods);
  }

  if (params.initialValue > 0 &&
      params.finalValue > 0 &&
      params.periods > 0 &&
      params.rate <= 0) {
    emptyFields.add(FinancialCalculationTarget.interestRate);
  }

  if (emptyFields.length != 1) {
    return FailureResult<Failure, FinancialCalculationTarget>(
      ValidationFailure(
        message: [
          FinancialCalculationValidationMessage.invalidParameterCount,
        ],
      ),
    );
  }

  return SuccessResult<Failure, FinancialCalculationTarget>(
    emptyFields.first,
  );
}
