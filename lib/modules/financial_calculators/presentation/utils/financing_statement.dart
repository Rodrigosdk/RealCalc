import 'package:intl/intl.dart';
import 'package:real_calc/core/utils/br_number_format.dart';
import 'package:real_calc/core/widgets/calculator_band/band_statement.dart';

import '../../domain/entities/financial_calculation.dart';
import '../../domain/enum/financial_calculation_target.dart';

const _fieldOrder = [
  FinancialCalculationTarget.initialValue,
  FinancialCalculationTarget.periods,
  FinancialCalculationTarget.interestRate,
  FinancialCalculationTarget.finalValue,
];

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
  if (calculatedField != null) return _answer(calculatedField, values);

  if (emptyFields.length == _fieldOrder.length) {
    return const BandStatement(
      kicker: 'Informe três valores',
      value: 'e descubra o quarto',
      sub: 'Qualquer campo pode ser o resultado.',
    );
  }

  if (emptyFields.length == 1) {
    return BandStatement(
      kicker: 'Você quer descobrir',
      value: financingFieldName(emptyFields.single),
      sub: 'Os outros três campos já estão preenchidos.',
    );
  }

  if (emptyFields.isEmpty) {
    return const BandStatement(
      kicker: 'Para calcular, deixe',
      value: '1 campo em branco',
      sub: 'Apague o valor que você quer descobrir.',
    );
  }

  final missing = emptyFields.length - 1;
  return BandStatement(
    kicker: 'Para calcular, ainda',
    value: missing == 1 ? 'falta 1 campo' : 'faltam $missing campos',
    sub: 'Deixe em branco só o que você quer descobrir.',
  );
}

String financingMissingFieldsMessage(Set<FinancialCalculationTarget> empty) {
  final names = [
    for (final field in _fieldOrder)
      if (empty.contains(field)) financingFieldName(field),
  ];
  final list = names.length == 1
      ? names.single
      : '${names.sublist(0, names.length - 1).join(', ')} ou ${names.last}';
  return 'Preencha $list. O campo que ficar em branco é calculado.';
}

final _money = NumberFormat('#,##0.00', 'pt_BR');

BandStatement _answer(
  FinancialCalculationTarget field,
  FinancialCalculation values,
) {
  final installment = formatCents(toCents(values.finalValue));
  final periods = values.periods;

  return switch (field) {
    FinancialCalculationTarget.finalValue => BandStatement(
      kicker: 'Sua prestação vai ser',
      value: _money.format(toCents(values.finalValue) / 100),
      isMoney: true,
      sub: periods == 1
          ? '1 parcela, pela Tabela Price'
          : '$periods parcelas iguais, pela Tabela Price',
    ),
    FinancialCalculationTarget.initialValue => BandStatement(
      kicker: 'Você pode financiar',
      value: _money.format(toCents(values.initialValue) / 100),
      isMoney: true,
      sub: periods == 1
          ? 'em 1 parcela de $installment'
          : 'em $periods parcelas de $installment',
    ),
    FinancialCalculationTarget.periods => BandStatement(
      kicker: 'Você quita em',
      value: periods == 1 ? '1 mês' : '$periods meses',
      sub: 'com parcelas de $installment',
    ),
    FinancialCalculationTarget.interestRate => BandStatement(
      kicker: 'A taxa de juros é de',
      value: '${formatPercent(values.rate)} ao mês',
      sub: '${formatPercent(annualEquivalentRate(values.rate))} ao ano',
    ),
  };
}
