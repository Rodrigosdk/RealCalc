import 'package:real_calc/core/seed_works/specification.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/modules/future_value/domain/entities/future_value.dart';

class PositiveCapitalSpecification extends Specification<FutureValue, FutureValueValidationMessage> {
  @override
  List<FutureValueValidationMessage> validate(FutureValue entity) {
    return (entity.capital ?? 0) > 0
        ? []
        : [FutureValueValidationMessage.positiveCapital];
  }
}

class PositiveFinalValueSpecification extends Specification<FutureValue, FutureValueValidationMessage> {
  @override
  List<FutureValueValidationMessage> validate(FutureValue entity) {
    return (entity.finalValue ?? 0) > 0
        ? []
        : [FutureValueValidationMessage.positiveFinalValue];
  }
}

class PositiveInterestRateSpecification extends Specification<FutureValue, FutureValueValidationMessage> {
  @override
  List<FutureValueValidationMessage> validate(FutureValue entity) {
    return (entity.interestRate ?? 0) > 0
        ? []
        : [FutureValueValidationMessage.positiveInterestRate];
  }
}

class PositiveMonthsSpecification extends Specification<FutureValue, FutureValueValidationMessage> {
  @override
  List<FutureValueValidationMessage> validate(FutureValue entity) {
    return (entity.months ?? 0) > 0
        ? []
        : [FutureValueValidationMessage.positiveMonths];
  }
}
