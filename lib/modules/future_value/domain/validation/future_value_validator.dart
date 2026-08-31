import 'package:real_calc/core/errors/failures.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/core/seed_works/result.dart';
import 'package:real_calc/core/seed_works/specification.dart';
import 'package:real_calc/modules/future_value/domain/entities/future_value.dart';

import '../enum/future_value_type.dart';
import 'spec/future_value_spec.dart';

class FutureValueValidator {
  final Specification<FutureValue, FutureValueValidationMessage> _validateForCapital =
      CompositeSpecification([
    PositiveFinalValueSpecification(),
    PositiveInterestRateSpecification(),
    PositiveMonthsSpecification(),
  ]);

  final Specification<FutureValue, FutureValueValidationMessage> _validateForFinalValue =
      CompositeSpecification([
    PositiveCapitalSpecification(),
    PositiveInterestRateSpecification(),
    PositiveMonthsSpecification(),
  ]);

  final Specification<FutureValue, FutureValueValidationMessage> _validateForInterestRate =
      CompositeSpecification([
    PositiveCapitalSpecification(),
    PositiveFinalValueSpecification(),
    PositiveMonthsSpecification(),
  ]);

  final Specification<FutureValue, FutureValueValidationMessage> _validateForMonths =
      CompositeSpecification([
    PositiveCapitalSpecification(),
    PositiveFinalValueSpecification(),
    PositiveInterestRateSpecification(),
  ]);

  Result<Failure, T> _buildResult<T>(List<FutureValueValidationMessage> errors, T successValue) {
    return errors.isEmpty
        ? SuccessResult<Failure, T>(successValue)
        : FailureResult<Failure, T>(
            ValidationFailure(message: errors),
          );
  }

  Result<Failure, FutureValue> validateForCapital(FutureValue params) {
    return _buildResult(_validateForCapital.validate(params), params);
  }

  Result<Failure, FutureValue> validateForFinalValue(FutureValue params) {
    return _buildResult(_validateForFinalValue.validate(params), params);
  }

  Result<Failure, FutureValue> validateForInterestRate(FutureValue params) {
    return _buildResult(_validateForInterestRate.validate(params), params);
  }

  Result<Failure, FutureValue> validateForMonths(FutureValue params) {
    return _buildResult(_validateForMonths.validate(params), params);
  }

  Result<Failure, FutureValueType> detectTypeCalculation(FutureValue params) {
    if (_validateForCapital.validate(params).isEmpty) {
      return SuccessResult<Failure, FutureValueType>(FutureValueType.capital);
    }
    if (_validateForInterestRate.validate(params).isEmpty) {
      return SuccessResult<Failure, FutureValueType>(FutureValueType.interestRate);
    }
    if (_validateForMonths.validate(params).isEmpty) {
      return SuccessResult<Failure, FutureValueType>(FutureValueType.months);
    }
    if (_validateForFinalValue.validate(params).isEmpty) {
      return SuccessResult<Failure, FutureValueType>(FutureValueType.finalValue);
    }

    return FailureResult<Failure, FutureValueType>(
      ValidationFailure(message: [FutureValueValidationMessage.unableToDetermineCalculationType]),
    );
  }
}
