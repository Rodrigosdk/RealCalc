import 'package:real_calc/core/errors/failures.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/core/seed_works/result.dart';
import 'package:real_calc/core/seed_works/specification.dart';
import 'package:real_calc/modules/financing/domain/entities/financing.dart';

import '../enum/calculate_financing_type.dart';
import 'spec/financing_spec.dart';

class FinancingValidator {
  // Instanciação limpa usando o CompositeSpecification do SeedWork
  final Specification<Financing, FinancingValidationMessage> _validateForFinalValue =
      CompositeSpecification([
        PositiveInitialValueSpecification(),
        PositiveRateSpecification(),
        PositiveMonthsSpecification(),
      ]);

  final Specification<Financing, FinancingValidationMessage> _validateForRate = 
      CompositeSpecification([
        PositiveInitialValueSpecification(),
        PositiveFinalValueSpecification(),
        PositiveMonthsSpecification(),
      ]);

  final Specification<Financing, FinancingValidationMessage> _validateForMonths = 
      CompositeSpecification([
        PositiveInitialValueSpecification(),
        PositiveFinalValueSpecification(),
        PositiveRateSpecification(),
      ]);

  final Specification<Financing, FinancingValidationMessage> _validateForInitialValue =
      CompositeSpecification([
        PositiveFinalValueSpecification(),
        PositiveRateSpecification(),
        PositiveMonthsSpecification(),
      ]);

  // Função utilitária privada para remover código duplicado de conversão para Result
  Result<Failure, T> _buildResult<T>(List<FinancingValidationMessage> errors, T successValue) {
    return errors.isEmpty
        ? SuccessResult<Failure, T>(successValue) // Ajustado o tipo genérico para Failure para bater com a assinatura do método
        : FailureResult<Failure, T>(
            ValidationFailure(message: errors),
          );
  }

  Result<Failure, Financing> validateForFinalValue(Financing params) {
    return _buildResult(_validateForFinalValue.validate(params), params);
  }

  Result<Failure, Financing> validateForRate(Financing params) {
    return _buildResult(_validateForRate.validate(params), params);
  }

  Result<Failure, Financing> validateForMonths(Financing params) {
    return _buildResult(_validateForMonths.validate(params), params);
  }

  Result<Failure, Financing> validateForInitialValue(Financing params) {
    return _buildResult(_validateForInitialValue.validate(params), params);
  }

  Result<Failure, CalculateFinancingType> validateTypeCalculation(Financing params) {
    if (_validateForInitialValue.validate(params).isEmpty) {
      return SuccessResult<Failure, CalculateFinancingType>(CalculateFinancingType.initialValue);
    }
    if (_validateForRate.validate(params).isEmpty) {
      return SuccessResult<Failure, CalculateFinancingType>(CalculateFinancingType.rate);
    }
    if (_validateForMonths.validate(params).isEmpty) {
      return SuccessResult<Failure, CalculateFinancingType>(CalculateFinancingType.months);
    }
    if (_validateForFinalValue.validate(params).isEmpty) {
      return SuccessResult<Failure, CalculateFinancingType>(CalculateFinancingType.finalValue);
    }

    return FailureResult<Failure, CalculateFinancingType>(
      ValidationFailure(message: [
        FinancingValidationMessage.unableToDetermineCalculationType
      ]),
    );
  }
}
