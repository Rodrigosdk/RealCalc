import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/core/seed_works/specification.dart';
import 'package:real_calc/modules/financing/domain/entities/financing.dart';

class PositiveInitialValueSpecification extends Specification<Financing, FinancingValidationMessage> {
  @override
  List<FinancingValidationMessage> validate(Financing financing) {
    return financing.initialValue > 0
        ? []
        : [FinancingValidationMessage.positiveInitialValue];
  }
}

class PositiveFinalValueSpecification extends Specification<Financing, FinancingValidationMessage> {
  @override
  List<FinancingValidationMessage> validate(Financing financing) {
    return financing.finalValue > 0
        ? []
        : [FinancingValidationMessage.positiveFinalValue];
  }
}

class PositiveRateSpecification extends Specification<Financing, FinancingValidationMessage> {
  @override
  List<FinancingValidationMessage> validate(Financing financing) {
    return financing.rate > 0
        ? []
        : [FinancingValidationMessage.positiveRate];
  }
}

class PositiveMonthsSpecification extends Specification<Financing, FinancingValidationMessage> {
  @override
  List<FinancingValidationMessage> validate(Financing financing) {
    return financing.months > 0
        ? []
        : [FinancingValidationMessage.positiveMonths];
  }
}
