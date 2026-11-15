import '../../../../core/errors/failures.dart';
import '../../../../core/errors/messages.dart';
import '../../../../core/seed_works/result.dart';
import '../entities/financial_calculation.dart';
import '../enum/financial_calculation_target.dart';
import 'solving.dart';

/// R$ 1 trilhão. Acima disso a conversão para centavos perde precisão e o
/// valor não cabe nas linhas da tela.
const maxCalculatedMoney = 1e12;

Result<Failure, FinancialCalculation> ensureWithinLimits(
  FinancialCalculation result, {
  FinancialCalculationTarget? calculated,
}) {
  final money = [result.initialValue, result.finalValue];
  final withinLimits =
      [...money, result.rate].every((value) => value.isFinite) &&
      money.every((value) => value <= maxCalculatedMoney);

  if (!withinLimits) {
    return FailureResult<Failure, FinancialCalculation>(
      const ValidationFailure(
        message: [FinancialCalculationValidationMessage.resultOutOfRange],
      ),
    );
  }

  // A tela mostra duas casas e trata 0,00 como campo vazio.
  final displayable = switch (calculated) {
    null => true,
    FinancialCalculationTarget.initialValue => result.initialValue >= halfCent,
    FinancialCalculationTarget.finalValue => result.finalValue >= halfCent,
    FinancialCalculationTarget.interestRate => result.rate >= halfCent,
    FinancialCalculationTarget.periods => result.periods >= 1,
  };
  if (!displayable) {
    return FailureResult<Failure, FinancialCalculation>(
      const ValidationFailure(
        message: [FinancialCalculationValidationMessage.resultTooSmall],
      ),
    );
  }

  return SuccessResult<Failure, FinancialCalculation>(result);
}
