import 'package:real_calc/core/errors/failures.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/core/seed_works/result.dart';
import 'package:real_calc/core/seed_works/specification.dart';
import 'package:real_calc/modules/regular_deposits/domain/entities/regular_deposit.dart';

import '../enum/calculate_regular_deposit_type.dart';
import 'spec/regular_deposits_spec.dart';

class RegularDepositsValidator {
  final Specification<RegularDeposit, RegularDepositsValidationMessage> _validateForFinalValue =
      CompositeSpecification([
        PositiveDepositValueSpecification(),
        PositiveRateValueSpecification(),
        PositiveMonthsValueSpecification(),
      ]);

  final Specification<RegularDeposit, RegularDepositsValidationMessage> _validateForRate =
      CompositeSpecification([
        PositiveDepositValueSpecification(),
        PositiveFinalValueSpecification(),
        PositiveMonthsValueSpecification(),
      ]);

  final Specification<RegularDeposit, RegularDepositsValidationMessage> _validateForMonths =
      CompositeSpecification([
        PositiveDepositValueSpecification(),
        PositiveFinalValueSpecification(),
        PositiveRateValueSpecification(),
      ]);

  final Specification<RegularDeposit, RegularDepositsValidationMessage> _validateForDepositAmount =
      CompositeSpecification([
        PositiveFinalValueSpecification(),
        PositiveRateValueSpecification(),
        PositiveMonthsValueSpecification(),
      ]);

  Result<Failure, T> _buildResult<T>(List<RegularDepositsValidationMessage> errors, T successValue) {
    return errors.isEmpty
        ? SuccessResult<Failure, T>(successValue)
        : FailureResult<Failure, T>(
            ValidationFailure(message: errors),
          );
  }

  Result<Failure, RegularDeposit> validateForFinalValue(RegularDeposit params) {
    return _buildResult(_validateForFinalValue.validate(params), params);
  }

  Result<Failure, RegularDeposit> validateForRate(RegularDeposit params) {
    return _buildResult(_validateForRate.validate(params), params);
  }

  Result<Failure, RegularDeposit> validateForMonths(RegularDeposit params) {
    return _buildResult(_validateForMonths.validate(params), params);
  }

  Result<Failure, RegularDeposit> validateForDepositAmount(RegularDeposit params) {
    return _buildResult(_validateForDepositAmount.validate(params), params);
  }

  Result<Failure, CalculateRegularDepositType> detectTypeCalculation(RegularDeposit params) {
    if (_validateForDepositAmount.validate(params).isEmpty) {
      return SuccessResult<Failure, CalculateRegularDepositType>(CalculateRegularDepositType.depositAmount);
    }
    if (_validateForRate.validate(params).isEmpty) {
      return SuccessResult<Failure, CalculateRegularDepositType>(CalculateRegularDepositType.rate);
    }
    if (_validateForMonths.validate(params).isEmpty) {
      return SuccessResult<Failure, CalculateRegularDepositType>(CalculateRegularDepositType.months);
    }
    if (_validateForFinalValue.validate(params).isEmpty) {
      return SuccessResult<Failure, CalculateRegularDepositType>(CalculateRegularDepositType.finalValue);
    }

    return FailureResult<Failure, CalculateRegularDepositType>(
      ValidationFailure(message: [
        RegularDepositsValidationMessage.unableToDetermineCalculationType,
      ]),
    );
  }
}