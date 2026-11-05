import 'package:intl/intl.dart';
import 'package:real_calc/core/utils/br_number_format.dart';
import 'package:real_calc/core/widgets/calculator_band/band_statement.dart';

import '../../domain/enum/financial_calculation_target.dart';

const calculatorFieldOrder = [
  FinancialCalculationTarget.initialValue,
  FinancialCalculationTarget.periods,
  FinancialCalculationTarget.interestRate,
  FinancialCalculationTarget.finalValue,
];

typedef FieldName = String Function(FinancialCalculationTarget field);

final _money = NumberFormat('#,##0.00', 'pt_BR');

String moneyValue(double value) => _money.format(toCents(value) / 100);

String money(double value) => formatCents(toCents(value));

String months(int count) => count == 1 ? '1 mês' : '$count meses';

BandStatement pendingStatement(
  Set<FinancialCalculationTarget> emptyFields,
  FieldName fieldName,
) {
  if (emptyFields.length == calculatorFieldOrder.length) {
    return const BandStatement(
      kicker: 'Informe três valores',
      value: 'e descubra o quarto',
      sub: 'Qualquer campo pode ser o resultado.',
    );
  }

  if (emptyFields.length == 1) {
    return BandStatement(
      kicker: 'Você quer descobrir',
      value: fieldName(emptyFields.single),
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

String missingFieldsMessage(
  Set<FinancialCalculationTarget> emptyFields,
  FieldName fieldName,
) {
  final names = [
    for (final field in calculatorFieldOrder)
      if (emptyFields.contains(field)) fieldName(field),
  ];
  final list = names.length == 1
      ? names.single
      : '${names.sublist(0, names.length - 1).join(', ')} ou ${names.last}';
  return 'Preencha $list. O campo que ficar em branco é calculado.';
}

BandStatement rateStatement(double monthlyRate, {required String kicker}) {
  return BandStatement(
    kicker: kicker,
    value: '${formatPercent(monthlyRate)} ao mês',
    sub: '${formatPercent(annualEquivalentRate(monthlyRate))} ao ano',
  );
}
