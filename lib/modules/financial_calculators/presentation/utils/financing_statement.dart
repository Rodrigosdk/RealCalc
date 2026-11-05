import 'package:real_calc/core/widgets/calculator_band/band_statement.dart';

import '../../domain/entities/financial_calculation.dart';
import '../../domain/enum/financial_calculation_target.dart';
import 'calculator_statement.dart';

String financingFieldName(FinancialCalculationTarget field) => switch (field) {
  FinancialCalculationTarget.initialValue => 'o valor financiado',
  FinancialCalculationTarget.periods => 'o prazo',
  FinancialCalculationTarget.interestRate => 'a taxa de juros',
  FinancialCalculationTarget.finalValue => 'a prestação',
};

BandStatement financingStatement({
  required Set<FinancialCalculationTarget> emptyFields,
  required FinancialCalculation values,
  FinancialCalculationTarget? calculatedField,
}) {
  if (calculatedField == null) {
    return pendingStatement(emptyFields, financingFieldName);
  }

  final installment = money(values.finalValue);
  final periods = values.periods;

  return switch (calculatedField) {
    FinancialCalculationTarget.finalValue => BandStatement(
      kicker: 'Sua prestação vai ser',
      value: moneyValue(values.finalValue),
      isMoney: true,
      sub: periods == 1
          ? '1 parcela, pela Tabela Price'
          : '$periods parcelas iguais, pela Tabela Price',
    ),
    FinancialCalculationTarget.initialValue => BandStatement(
      kicker: 'Você pode financiar',
      value: moneyValue(values.initialValue),
      isMoney: true,
      sub: periods == 1
          ? 'em 1 parcela de $installment'
          : 'em $periods parcelas de $installment',
    ),
    FinancialCalculationTarget.periods => BandStatement(
      kicker: 'Você quita em',
      value: months(periods),
      sub: 'com parcelas de $installment',
    ),
    FinancialCalculationTarget.interestRate => rateStatement(
      values.rate,
      kicker: 'A taxa de juros é de',
    ),
  };
}

String financingMissingFieldsMessage(Set<FinancialCalculationTarget> empty) =>
    missingFieldsMessage(empty, financingFieldName);
