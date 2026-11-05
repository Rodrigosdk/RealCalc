import 'package:real_calc/core/utils/br_number_format.dart';
import 'package:real_calc/core/widgets/calculator_band/band_statement.dart';

import '../../domain/entities/financial_calculation.dart';
import '../../domain/enum/financial_calculation_target.dart';
import 'calculator_statement.dart';

String depositsFieldName(FinancialCalculationTarget field) => switch (field) {
  FinancialCalculationTarget.initialValue => 'o depósito',
  FinancialCalculationTarget.periods => 'o prazo',
  FinancialCalculationTarget.interestRate => 'a taxa de juros',
  FinancialCalculationTarget.finalValue => 'o valor final',
};

BandStatement depositsStatement({
  required Set<FinancialCalculationTarget> emptyFields,
  required FinancialCalculation values,
  FinancialCalculationTarget? calculatedField,
}) {
  if (calculatedField == null) {
    return pendingStatement(emptyFields, depositsFieldName);
  }

  final deposit = money(values.initialValue);
  final total = money(values.finalValue);
  final yieldCents =
      toCents(values.finalValue) -
      toCents(values.initialValue) * values.periods;
  final yieldText = '${formatCents(yieldCents)} de rendimento';

  return switch (calculatedField) {
    FinancialCalculationTarget.finalValue => BandStatement(
      kicker: 'Guardando $deposit por mês, você terá',
      value: moneyValue(values.finalValue),
      isMoney: true,
      sub: 'em ${months(values.periods)}, com $yieldText',
    ),
    FinancialCalculationTarget.initialValue => BandStatement(
      kicker: 'Para juntar $total, guarde por mês',
      value: moneyValue(values.initialValue),
      isMoney: true,
      sub: 'durante ${months(values.periods)}',
    ),
    FinancialCalculationTarget.periods => BandStatement(
      kicker: 'Guardando $deposit por mês, você junta $total em',
      value: months(values.periods),
      sub: 'com $yieldText',
    ),
    FinancialCalculationTarget.interestRate => rateStatement(
      values.rate,
      kicker: 'Para isso, o dinheiro precisa render',
    ),
  };
}

String depositsMissingFieldsMessage(Set<FinancialCalculationTarget> empty) =>
    missingFieldsMessage(empty, depositsFieldName);
