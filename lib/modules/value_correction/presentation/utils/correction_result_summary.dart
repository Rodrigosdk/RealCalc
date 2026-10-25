import 'package:intl/intl.dart';
import 'package:real_calc/core/utils/br_number_format.dart';
import 'package:real_calc/core/widgets/result_details/result_summary.dart';

import '../../domain/entites/value_correction.dart';

final _factorFormat = NumberFormat('#,##0.0000000', 'pt_BR');

/// Correção de Valores. Sem valor original (só o fator), não há o que
/// detalhar e devolve `null`.
///
/// A correção sai dos valores arredondados: corrigido − original, em
/// centavos. Com deflação a correção é negativa e a barra é omitida.
ResultSummary? correctionResultSummary(ValueCorrection correction) {
  final originalValue = correction.originalValue;
  final adjustedValue = correction.adjustedValue;
  if (originalValue == null || adjustedValue == null) return null;

  final original = toCents(originalValue);
  final adjusted = toCents(adjustedValue);
  final difference = adjusted - original;

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
      ResultDetailLine(
        'Fator de correção',
        _factorFormat.format(correction.factor),
      ),
    ],
  );
}
