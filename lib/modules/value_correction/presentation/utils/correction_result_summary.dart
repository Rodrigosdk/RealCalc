import 'package:real_calc/core/utils/br_number_format.dart';
import 'package:real_calc/core/widgets/result_details/result_summary.dart';

import '../../domain/entites/value_correction.dart';
import 'correction_statement.dart';

ResultSummary correctionResultSummary(ValueCorrection correction) {
  final originalValue = correction.originalValue;
  final adjustedValue = correction.adjustedValue;
  final factorLine = ResultDetailLine(
    'Fator de correção',
    formatFactor(correction.factor),
  );

  if (originalValue == null || adjustedValue == null) {
    return ResultSummary(
      title: 'Da correção no período',
      composition: null,
      lines: [
        ResultDetailLine('Variação', formatVariation(correction.variation)),
        factorLine,
      ],
    );
  }

  final original = toCents(originalValue);
  final difference = toCents(adjustedValue) - original;

  return ResultSummary(
    title: 'Do valor corrigido',
    composition: ResultComposition.fromCents(
      ownLabel: 'Valor original',
      ownCents: original,
      otherLabel: 'Correção',
      otherCents: difference,
    ),
    lines: [
      ResultDetailLine('Valor original', formatCents(original)),
      ResultDetailLine('Correção no período', formatCents(difference)),
      factorLine,
    ],
  );
}
