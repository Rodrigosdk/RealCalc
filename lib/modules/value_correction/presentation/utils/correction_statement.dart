import 'package:intl/intl.dart';
import 'package:real_calc/core/utils/br_number_format.dart';
import 'package:real_calc/core/widgets/calculator_band/band_statement.dart';

import '../../domain/entites/value_correction.dart';
import '../../domain/enum/correction_index.dart';
import '../../domain/enum/date_granularity.dart';

final _money = NumberFormat('#,##0.00', 'pt_BR');
final _factor = NumberFormat('#,##0.0000000', 'pt_BR');

extension CorrectionIndexText on CorrectionIndex {
  String get shortName => label.split(' (').first;

  bool get _isFeminine => switch (this) {
    CorrectionIndex.selic ||
    CorrectionIndex.tr ||
    CorrectionIndex.poupancaNova ||
    CorrectionIndex.poupancaVelha ||
    CorrectionIndex.taxaLegal => true,
    _ => false,
  };

  String get article => _isFeminine ? 'A' : 'O';

  String get by => _isFeminine ? 'pela' : 'pelo';

  String get availabilitySentence =>
      '$article $shortName tem dados a partir de $availableFromInputLabel.';

  String get sinceSentence =>
      '$article $shortName tem dados desde $availableFromInputLabel.';

  String formatDate(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');
    final monthYear = '${two(date.month)}/${date.year}';
    return granularity == DateGranularity.month
        ? monthYear
        : '${two(date.day)}/$monthYear';
  }
}

CorrectionIndex correctionIndexOf(ValueCorrection result) =>
    CorrectionIndex.values.firstWhere(
      (index) => index.sgsCode == result.index,
      orElse: () => CorrectionIndex.ipca,
    );

String formatVariation(double percent) {
  final sign = percent >= 0 ? '+' : '';
  return '$sign${formatPercent(percent)}';
}

String formatFactor(double factor) => _factor.format(factor);

String correctionDuration(
  CorrectionIndex index,
  DateTime initial,
  DateTime end,
) {
  if (index.granularity == DateGranularity.month) {
    final months = (end.year - initial.year) * 12 + end.month - initial.month;
    final count = months + 1;
    return count == 1 ? '1 mês' : '$count meses';
  }
  final days = end.difference(initial).inDays;
  return days == 1 ? '1 dia' : '$days dias';
}

BandStatement correctionStatement({
  required CorrectionIndex index,
  ValueCorrection? result,
  bool outOfRange = false,
  bool offline = false,
}) {
  if (offline) {
    return const BandStatement(
      kicker: 'Sem conexão com o',
      value: 'Banco Central',
      sub: 'Confira a internet e tente de novo.',
    );
  }

  if (outOfRange) {
    return BandStatement(
      kicker: 'Para corrigir ${index.by} ${index.shortName},',
      value: 'ajuste a data',
      sub: index.availabilitySentence,
    );
  }

  if (result == null) {
    return const BandStatement(
      kicker: 'Quanto vale hoje',
      value: 'o seu dinheiro?',
      sub: 'Escolha o índice, o período e o valor.',
    );
  }

  final resultIndex = correctionIndexOf(result);
  final period =
      'de ${resultIndex.formatDate(result.period.initial)} '
      'a ${resultIndex.formatDate(result.period.end)}';
  final by = '${resultIndex.by} ${resultIndex.shortName}';
  final original = result.originalValue;
  final adjusted = result.adjustedValue;

  if (original == null || adjusted == null) {
    return BandStatement(
      kicker:
          '${by[0].toUpperCase()}${by.substring(1)}, $period, '
          'a correção é de',
      value: formatVariation(result.variation),
      sub: 'Fator de correção ${formatFactor(result.factor)}',
    );
  }

  return BandStatement(
    kicker: 'Hoje, seus ${formatCents(toCents(original))} valem',
    value: _money.format(toCents(adjusted) / 100),
    isMoney: true,
    sub: '${formatVariation(result.variation)} $by, $period',
  );
}
