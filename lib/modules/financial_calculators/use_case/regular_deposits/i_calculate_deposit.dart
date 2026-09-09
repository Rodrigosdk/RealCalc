import '../../../../core/errors/failures.dart';
import '../../../../core/seed_works/result.dart';
import '../../domain/entities/financial_calculation.dart';

abstract class ICalculateDeposit {
  Result<Failure, FinancialCalculation> calculate(FinancialCalculation params);
}
