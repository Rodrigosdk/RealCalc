import 'package:real_calc/core/utils/br_number_format.dart';
import 'package:real_calc/core/utils/share_text.dart';

import '../../domain/entities/financial_calculation.dart';
import '../../domain/enum/financial_calculation_target.dart';
import 'calculator_statement.dart';
import 'deposits_statement.dart';
import 'financing_statement.dart';
import 'future_value_statement.dart';

typedef ShareTextBuilder =
    String Function(
      FinancialCalculation values,
      FinancialCalculationTarget calculatedField,
    );

List<(String, String)> _fieldLines(
  FinancialCalculation values,
  FinancialCalculationTarget calculatedField,
  Map<FinancialCalculationTarget, String> labels,
) => [
  for (final field in calculatorFieldOrder)
    if (field != calculatedField)
      (
        labels[field]!,
        switch (field) {
          FinancialCalculationTarget.initialValue => money(values.initialValue),
          FinancialCalculationTarget.periods => months(values.periods),
          FinancialCalculationTarget.interestRate =>
            '${formatPercent(values.rate)} ao mês',
          FinancialCalculationTarget.finalValue => money(values.finalValue),
        },
      ),
];

String financingShareText(
  FinancialCalculation values,
  FinancialCalculationTarget calculatedField,
) {
  final total = toCents(values.finalValue) * values.periods;
  final interest = total - toCents(values.initialValue);

  return shareText(
    calculator: 'Financiamento',
    statement: financingStatement(
      emptyFields: const {},
      values: values,
      calculatedField: calculatedField,
    ),
    lines: [
      ..._fieldLines(values, calculatedField, const {
        FinancialCalculationTarget.initialValue: 'Valor financiado',
        FinancialCalculationTarget.periods: 'Prazo',
        FinancialCalculationTarget.interestRate: 'Taxa de juros',
        FinancialCalculationTarget.finalValue: 'Prestação',
      }),
      ('Total pago', formatCents(total)),
      ('Juros', formatCents(interest)),
    ],
  );
}

String depositsShareText(
  FinancialCalculation values,
  FinancialCalculationTarget calculatedField,
) {
  final deposited = toCents(values.initialValue) * values.periods;
  final yield_ = toCents(values.finalValue) - deposited;

  return shareText(
    calculator: 'Depósitos Regulares',
    statement: depositsStatement(
      emptyFields: const {},
      values: values,
      calculatedField: calculatedField,
    ),
    lines: [
      ..._fieldLines(values, calculatedField, const {
        FinancialCalculationTarget.initialValue: 'Depósito mensal',
        FinancialCalculationTarget.periods: 'Prazo',
        FinancialCalculationTarget.interestRate: 'Taxa de juros',
        FinancialCalculationTarget.finalValue: 'Valor final',
      }),
      ('Total depositado', formatCents(deposited)),
      ('Rendimento', formatCents(yield_)),
    ],
  );
}

String futureValueShareText(
  FinancialCalculation values,
  FinancialCalculationTarget calculatedField,
) {
  final yield_ = toCents(values.finalValue) - toCents(values.initialValue);

  return shareText(
    calculator: 'Valor Futuro',
    statement: futureValueStatement(
      emptyFields: const {},
      values: values,
      calculatedField: calculatedField,
    ),
    lines: [
      ..._fieldLines(values, calculatedField, const {
        FinancialCalculationTarget.initialValue: 'Valor aplicado',
        FinancialCalculationTarget.periods: 'Prazo',
        FinancialCalculationTarget.interestRate: 'Taxa de juros',
        FinancialCalculationTarget.finalValue: 'Valor futuro',
      }),
      ('Rendimento', formatCents(yield_)),
    ],
  );
}
