
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/core/seed_works/specification.dart';
import 'package:real_calc/modules/regular_deposits/domain/entities/regular_deposit.dart';

class PositiveRateValueSpecification extends Specification<RegularDeposit, RegularDepositsValidationMessage> {
  @override
  List<RegularDepositsValidationMessage> validate(RegularDeposit params) {
    return params.rate > 0
        ? []
        : [RegularDepositsValidationMessage.positiveRate];
  }
}
class PositiveDepositValueSpecification extends Specification<RegularDeposit, RegularDepositsValidationMessage> {
  @override
  List<RegularDepositsValidationMessage> validate(RegularDeposit params) {
    return params.depositAmount > 0
        ? []
        : [RegularDepositsValidationMessage.positiveDepositValue];
  }
}

class PositiveFinalValueSpecification extends Specification<RegularDeposit, RegularDepositsValidationMessage> {
  @override
  List<RegularDepositsValidationMessage> validate(RegularDeposit params) {
    return params.finalValue > 0
        ? []
        : [RegularDepositsValidationMessage.positiveFinalValue];
  }
}

class PositiveMonthsValueSpecification extends Specification<RegularDeposit, RegularDepositsValidationMessage> {
  @override
  List<RegularDepositsValidationMessage> validate(RegularDeposit params) {
    return params.months > 0
        ? []
        : [RegularDepositsValidationMessage.positiveMonths];
  }
}