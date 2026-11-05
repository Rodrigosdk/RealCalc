import 'package:real_calc/core/utils/br_number_format.dart';
import 'package:real_calc/core/widgets/calculator_band/band_statement.dart';

import '../../domain/entities/financial_calculation.dart';
import '../../domain/enum/financial_calculation_target.dart';
import 'calculator_statement.dart';

String futureValueFieldName(FinancialCalculationTarget field) =>
    switch (field) {
      FinancialCalculationTarget.initialValue => 'o valor aplicado',
      FinancialCalculationTarget.periods => 'o prazo',
      FinancialCalculationTarget.interestRate => 'a taxa de juros',
      FinancialCalculationTarget.finalValue => 'o valor futuro',
    };

BandStatement futureValueStatement({
  required Set<FinancialCalculationTarget> emptyFields,
  required FinancialCalculation values,
  FinancialCalculationTarget? calculatedField,
}) {
  if (calculatedField == null) {
    return pendingStatement(emptyFields, futureValueFieldName);
  }

  final applied = money(values.initialValue);
  final future = money(values.finalValue);
  final yieldCents = toCents(values.finalValue) - toCents(values.initialValue);
  final yieldText = '${formatCents(yieldCents)} de rendimento';

  return switch (calculatedField) {
    FinancialCalculationTarget.finalValue => BandStatement(
      kicker: 'Aplicando $applied hoje, você terá',
      value: moneyValue(values.finalValue),
      isMoney: true,
      sub: 'em ${months(values.periods)}, com $yieldText',
    ),
    FinancialCalculationTarget.initialValue => BandStatement(
      kicker: 'Para ter $future, aplique hoje',
      value: moneyValue(values.initialValue),
      isMoney: true,
      sub: 'por ${months(values.periods)}',
    ),
    FinancialCalculationTarget.periods => BandStatement(
      kicker: '$applied viram $future em',
      value: months(values.periods),
      sub: 'com $yieldText',
    ),
    FinancialCalculationTarget.interestRate => rateStatement(
      values.rate,
      kicker: 'Para isso, o dinheiro precisa render',
    ),
  };
}

String futureValueMissingFieldsMessage(Set<FinancialCalculationTarget> empty) =>
    missingFieldsMessage(empty, futureValueFieldName);
