import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/widgets/result_details/result_summary.dart';
import 'package:real_calc/modules/value_correction/domain/entites/period.dart';
import 'package:real_calc/modules/value_correction/domain/entites/value_correction.dart';
import 'package:real_calc/modules/value_correction/presentation/utils/correction_result_summary.dart';

ValueCorrection correctionOf({
  double? original = 1000,
  double? adjusted = 1234.5678,
  double factor = 1.2345678,
}) => ValueCorrection(
  index: 433,
  period: Period(initial: DateTime(2022), end: DateTime(2025)),
  percentage: 100,
  originalValue: original,
  factor: factor,
  adjustedValue: adjusted,
  variation: (factor - 1) * 100,
);

void main() {
  group('correctionResultSummary', () {
    test('valor original 81%, correção 19%', () {
      final summary = correctionResultSummary(correctionOf());

      expect(summary.title, 'Do valor corrigido');
      expect(
        summary.composition!.own,
        const ResultSegment('Valor original', 81),
      );
      expect(summary.composition!.other, const ResultSegment('Correção', 19));
    });

    test('a correção sai dos valores arredondados', () {
      final summary = correctionResultSummary(correctionOf());

      expect(summary.lines, const [
        ResultDetailLine('Valor original', 'R\$\u00A01.000,00'),
        ResultDetailLine('Correção no período', 'R\$\u00A0234,57'),
        ResultDetailLine('Fator de correção', '1,2345678'),
      ]);
    });

    test('com deflação, mostra as linhas mas omite a barra', () {
      final summary = correctionResultSummary(
        correctionOf(adjusted: 990, factor: 0.99),
      );

      expect(summary.composition, isNull);
      expect(summary.lines[1].value, '-R\$\u00A010,00');
    });

    test('sem valor original, mostra só a variação e o fator', () {
      final summary = correctionResultSummary(
        correctionOf(original: null, adjusted: null),
      );

      expect(summary.title, 'Da correção no período');
      expect(summary.composition, isNull);
      expect(summary.lines, const [
        ResultDetailLine('Variação', '+23,46%'),
        ResultDetailLine('Fator de correção', '1,2345678'),
      ]);
    });
  });
}
