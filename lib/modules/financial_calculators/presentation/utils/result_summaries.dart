import 'package:real_calc/core/utils/br_number_format.dart';
import 'package:real_calc/core/widgets/result_details/result_summary.dart';

import '../../domain/entities/financial_calculation.dart';

// Os valores derivados saem dos valores arredondados que a pessoa vê na tela
// (em centavos), para a conta fechar: 236,40 × 12 = 2.836,80.

/// Financiamento: [FinancialCalculation.initialValue] é o valor emprestado e
/// [FinancialCalculation.finalValue], a prestação.
ResultSummary financingResultSummary(FinancialCalculation calculation) {
  final borrowed = toCents(calculation.initialValue);
  final total = toCents(calculation.finalValue) * calculation.periods;
  final interest = total - borrowed;

  return ResultSummary(
    title: 'Do total que você vai pagar',
    composition: ResultComposition.fromCents(
      ownLabel: 'Emprestado',
      ownCents: borrowed,
      otherLabel: 'Juros',
      otherCents: interest,
    ),
    lines: [
      ResultDetailLine('Total pago', formatCents(total)),
      ResultDetailLine('Total de juros', formatCents(interest)),
      _annualRateLine(calculation.rate),
    ],
  );
}

/// Depósitos Regulares: [FinancialCalculation.initialValue] é o depósito
/// mensal e [FinancialCalculation.finalValue], o valor final.
ResultSummary regularDepositsResultSummary(FinancialCalculation calculation) {
  final deposited = toCents(calculation.initialValue) * calculation.periods;
  final yield_ = toCents(calculation.finalValue) - deposited;

  return ResultSummary(
    title: 'Do valor final',
    composition: ResultComposition.fromCents(
      ownLabel: 'Depositado',
      ownCents: deposited,
      otherLabel: 'Rendimento',
      otherCents: yield_,
    ),
    lines: [
      ResultDetailLine('Total depositado', formatCents(deposited)),
      ResultDetailLine('Rendimento', formatCents(yield_)),
      _annualRateLine(calculation.rate),
    ],
  );
}

/// Valor Futuro: [FinancialCalculation.initialValue] é o valor aplicado e
/// [FinancialCalculation.finalValue], o valor final.
ResultSummary futureValueResultSummary(FinancialCalculation calculation) {
  final applied = toCents(calculation.initialValue);
  final yield_ = toCents(calculation.finalValue) - applied;

  return ResultSummary(
    title: 'Do valor futuro',
    composition: ResultComposition.fromCents(
      ownLabel: 'Valor aplicado',
      ownCents: applied,
      otherLabel: 'Rendimento',
      otherCents: yield_,
    ),
    lines: [
      ResultDetailLine('Valor aplicado', formatCents(applied)),
      ResultDetailLine('Rendimento', formatCents(yield_)),
      _annualRateLine(calculation.rate),
    ],
  );
}

ResultDetailLine _annualRateLine(double monthlyPercent) => ResultDetailLine(
  'Taxa anual equivalente',
  '${formatPercent(annualEquivalentRate(monthlyPercent))} a.a.',
);
