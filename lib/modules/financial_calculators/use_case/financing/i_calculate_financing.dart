import '../../../../core/errors/failures.dart';
import '../../../../core/seed_works/result.dart';
import '../../domain/entities/financial_calculation.dart';

abstract class ICalculateFinancing {
  Result<Failure, FinancialCalculation> calculate(FinancialCalculation params);
}
