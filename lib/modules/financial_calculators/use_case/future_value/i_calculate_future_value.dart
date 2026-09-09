import 'package:real_calc/core/errors/failures.dart';
import 'package:real_calc/core/seed_works/result.dart';

import '../../domain/entities/financial_calculation.dart';

abstract class ICalculateFutureValue {
  Result<Failure, FinancialCalculation> calculate(FinancialCalculation params);
}
