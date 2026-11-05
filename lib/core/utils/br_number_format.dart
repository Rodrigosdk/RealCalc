import 'dart:math';

import 'package:intl/intl.dart';

final _decimal = NumberFormat('#,##0.00', 'pt_BR');

/// Arredonda para centavos e devolve o valor em centavos inteiros, para as
/// contas derivadas fecharem com o que a pessoa vê na tela.
int toCents(double value) => (value * 100).round();

/// "R$ 2.836,80", com espaço não separável entre o símbolo e o número.
/// Negativos ficam com o sinal antes do símbolo: "-R$ 10,00".
String formatCents(int cents) {
  final sign = cents < 0 ? '-' : '';
  return '${sign}R\$\u00A0${_decimal.format(cents.abs() / 100)}';
}

/// "26,82%".
String formatPercent(double percent) => '${_decimal.format(percent)}%';

/// Taxa anual equivalente, em %, a partir da taxa mensal em %:
/// (1 + i)¹² − 1.
double annualEquivalentRate(double monthlyPercent) =>
    (pow(1 + monthlyPercent / 100, 12) - 1) * 100;
