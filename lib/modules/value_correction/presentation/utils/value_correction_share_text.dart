import 'package:intl/intl.dart';

import '../../domain/entites/value_correction.dart';
import '../../domain/enum/correction_index.dart';
import '../../domain/enum/date_granularity.dart';

String buildShareText(ValueCorrection correction) {
  final index = CorrectionIndex.values.firstWhere(
    (candidate) => candidate.sgsCode == correction.index,
    orElse: () => CorrectionIndex.ipca,
  );
  final periodFormat = DateFormat(
    index.granularity == DateGranularity.month ? 'MM/yyyy' : 'dd/MM/yyyy',
    'pt_BR',
  );
  final currencyFormat = NumberFormat('#,##0.00', 'pt_BR');
  final factorFormat = NumberFormat('#,##0.0000000', 'pt_BR');
  final percentageFormat = NumberFormat('#,##0.00', 'pt_BR');
  final lines = <String>[
    'RealCalc · Correção de Valores',
    'Índice: ${index.label}',
  ];

  if (index == CorrectionIndex.cdi) {
    lines.add(
      'Percentual do CDI: ${percentageFormat.format(correction.percentage)}%',
    );
  }

  lines.add(
    'Período: ${periodFormat.format(correction.period.initial)} a ${periodFormat.format(correction.period.end)}',
  );

  if (correction.originalValue != null && correction.adjustedValue != null) {
    lines.add(
      'Valor original: R\$ ${currencyFormat.format(correction.originalValue!)}',
    );
  }

  lines.add('Fator de correção: ${factorFormat.format(correction.factor)}');

  if (correction.adjustedValue != null) {
    final variation = percentageFormat.format(correction.variation);
    final variationText = correction.variation >= 0 ? '+$variation' : variation;
    lines.add(
      'Valor corrigido: R\$ ${currencyFormat.format(correction.adjustedValue!)} ($variationText%)',
    );
  }

  lines.addAll(['', 'Simulação feita no RealCalc, sem valor oficial.']);
  return lines.join('\n');
}
