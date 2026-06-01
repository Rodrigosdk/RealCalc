import 'package:real_calc/core/utils/result.dart';
import 'package:real_calc/core/utils/specification.dart';
import 'package:real_calc/core/utils/validation.dart';
import 'package:real_calc/modules/financing/domain/entities/financing.dart';

import '../enum/calculate_financing_type.dart';

class PositiveInitialValueSpecification implements Specification<Financing> {
  @override
  List<String> validate(Financing financing) {
    return financing.initialValue > 0
        ? []
        : ['O valor inicial deve ser maior que zero'];
  }
}

class PositiveFinalValueSpecification implements Specification<Financing> {
  @override
  List<String> validate(Financing financing) {
    return financing.finalValue > 0
        ? []
        : ['O valor final deve ser maior que zero'];
  }
}

class PositiveRateSpecification implements Specification<Financing> {
  @override
  List<String> validate(Financing financing) {
    return financing.rate > 0
        ? []
        : ['O valor da taxa deve ser maior que zero'];
  }
}

class PositiveMonthsSpecification implements Specification<Financing> {
  @override
  List<String> validate(Financing financing) {
    return financing.months > 0
        ? []
        : ['A quantidade de meses deve ser maior que zero'];
  }
}

class FinancingValidator {
  final Specification<Financing> _validateForFinalValue =
      CompositeSpecification([
        PositiveInitialValueSpecification(),
        PositiveRateSpecification(),
        PositiveMonthsSpecification(),
      ]);

  final Specification<Financing> _validateForRate = CompositeSpecification([
    PositiveInitialValueSpecification(),
    PositiveFinalValueSpecification(),
    PositiveMonthsSpecification(),
  ]);

  final Specification<Financing> _validateForMonths = CompositeSpecification([
    PositiveInitialValueSpecification(),
    PositiveFinalValueSpecification(),
    PositiveRateSpecification(),
  ]);

  final Specification<Financing> _validateForInitialValue =
      CompositeSpecification([
        PositiveFinalValueSpecification(),
        PositiveRateSpecification(),
        PositiveMonthsSpecification(),
      ]);

  Result<ValidationFailure, Financing> validateForFinalValue(Financing params) {
    final errors = _validateForFinalValue.validate(params);
    return errors.isEmpty
        ? ValidationSuccess<ValidationFailure, Financing>(params)
        : ValidationError<ValidationFailure, Financing>(
            ValidationFailure(errors),
          );
  }

  Result<ValidationFailure, Financing> validateForRate(Financing params) {
    final errors = _validateForRate.validate(params);
    return errors.isEmpty
        ? ValidationSuccess<ValidationFailure, Financing>(params)
        : ValidationError<ValidationFailure, Financing>(
            ValidationFailure(errors),
          );
  }

  Result<ValidationFailure, Financing> validateForMonths(Financing params) {
    final errors = _validateForMonths.validate(params);
    return errors.isEmpty
        ? ValidationSuccess<ValidationFailure, Financing>(params)
        : ValidationError<ValidationFailure, Financing>(
            ValidationFailure(errors),
          );
  }

  Result<ValidationFailure, Financing> validateForInitialValue(
    Financing params,
  ) {
    final errors = _validateForInitialValue.validate(params);
    return errors.isEmpty
        ? ValidationSuccess<ValidationFailure, Financing>(params)
        : ValidationError<ValidationFailure, Financing>(
            ValidationFailure(errors),
          );
  }

  Result<ValidationFailure, CalculateFinancingType> validateTypeCalculation(
    Financing params,
  ) {
    final errorsInitialValue = _validateForInitialValue.validate(params);
    final errorsRate = _validateForRate.validate(params);
    final errorsMonths = _validateForMonths.validate(params);
    final errorsFinalValue = _validateForFinalValue.validate(params);

    if (errorsInitialValue.isEmpty) {
      return ValidationSuccess<ValidationFailure, CalculateFinancingType>(
        CalculateFinancingType.initialValue,
      );
    }
    if (errorsRate.isEmpty) {
      return ValidationSuccess<ValidationFailure, CalculateFinancingType>(
        CalculateFinancingType.rate,
      );
    }
    if (errorsMonths.isEmpty) {
      return ValidationSuccess<ValidationFailure, CalculateFinancingType>(
        CalculateFinancingType.months,
      );
    }
    if (errorsFinalValue.isEmpty) {
      return ValidationSuccess<ValidationFailure, CalculateFinancingType>(
        CalculateFinancingType.finalValue,
      );
    }

    return ValidationError<ValidationFailure, CalculateFinancingType>(
      ValidationFailure([
        "Não foi possível determinar o tipo de cálculo. Verifique os parâmetros informados."
      ]),
    );
  }
}
