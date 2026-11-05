import '../../../../core/errors/failures.dart';
import '../../../../core/errors/messages.dart';
import '../../../../core/seed_works/result.dart';
import '../entities/financial_calculation.dart';

/// R$ 1 trilhão. Acima disso a conversão para centavos perde precisão e o
/// valor não cabe nas linhas da tela.
const maxCalculatedMoney = 1e12;

Result<Failure, FinancialCalculation> ensureWithinLimits(
  FinancialCalculation result,
) {
  final money = [result.initialValue, result.finalValue];
  final withinLimits =
      [...money, result.rate].every((value) => value.isFinite) &&
      money.every((value) => value <= maxCalculatedMoney);

  return withinLimits
      ? SuccessResult<Failure, FinancialCalculation>(result)
      : FailureResult<Failure, FinancialCalculation>(
          const ValidationFailure(
            message: [FinancialCalculationValidationMessage.resultOutOfRange],
          ),
        );
}
