import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:real_calc/modules/value_correction/domain/entites/period.dart';
import 'package:real_calc/modules/value_correction/domain/entites/value_correction.dart';
import 'package:real_calc/modules/value_correction/domain/enum/correction_index.dart';
import 'package:real_calc/modules/value_correction/domain/enum/date_granularity.dart';
import 'package:real_calc/modules/value_correction/presentation/utils/value_correction_share_text.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR', null);
  });

  ValueCorrection result({
    int index = 433,
    double percentage = 0,
    double? originalValue = 5000,
    double factor = 1.1434,
    double? adjustedValue = 5717,
    double variation = 14.34,
    DateTime? initial,
    DateTime? end,
  }) {
    return ValueCorrection(
      index: index,
      period: Period(
        initial: initial ?? DateTime(2023, 1, 1),
        end: end ?? DateTime(2025, 12, 1),
      ),
      percentage: percentage,
      originalValue: originalValue,
      factor: factor,
      adjustedValue: adjustedValue,
      variation: variation,
    );
  }

  test('gera o texto completo quando há valor corrigido', () {
    expect(
      buildShareText(result()),
      'RealCalc · Correção de Valores\n'
      'Índice: IPCA (IBGE)\n'
      'Período: 01/2023 a 12/2025\n'
      'Valor original: R\$ 5.000,00\n'
      'Fator de correção: 1,1434000\n'
      'Valor corrigido: R\$ 5.717,00 (+14,34%)\n\n'
      'Simulação feita no RealCalc, sem valor oficial.',
    );
  });

  test('omite valores original e corrigido quando não há valor informado', () {
    final text = buildShareText(
      result(originalValue: null, adjustedValue: null),
    );

    expect(
      text,
      'RealCalc · Correção de Valores\n'
      'Índice: IPCA (IBGE)\n'
      'Período: 01/2023 a 12/2025\n'
      'Fator de correção: 1,1434000\n\n'
      'Simulação feita no RealCalc, sem valor oficial.',
    );
    expect(text, isNot(contains('Valor original:')));
    expect(text, isNot(contains('Valor corrigido:')));
  });

  test('inclui percentual CDI e datas diárias', () {
    expect(
      buildShareText(
        result(
          index: CorrectionIndex.cdi.sgsCode,
          percentage: 80,
          initial: DateTime(2024, 1, 1),
          end: DateTime(2024, 1, 31),
        ),
      ),
      'RealCalc · Correção de Valores\n'
      'Índice: CDI\n'
      'Percentual do CDI: 80,00%\n'
      'Período: 01/01/2024 a 31/01/2024\n'
      'Valor original: R\$ 5.000,00\n'
      'Fator de correção: 1,1434000\n'
      'Valor corrigido: R\$ 5.717,00 (+14,34%)\n\n'
      'Simulação feita no RealCalc, sem valor oficial.',
    );
  });

  for (final index in CorrectionIndex.values) {
    test('gera texto para ${index.name} com rótulo e período corretos', () {
      final initial = DateTime(2024, 1, 2);
      final end = DateTime(2024, 2, 3);
      final isMonthly = index.granularity == DateGranularity.month;
      final dateRange = isMonthly
          ? '01/2024 a 02/2024'
          : '02/01/2024 a 03/02/2024';
      final expected = StringBuffer()
        ..write('RealCalc · Correção de Valores\n')
        ..write('Índice: ${index.label}\n');

      if (index == CorrectionIndex.cdi) {
        expected.write('Percentual do CDI: 80,00%\n');
      }

      expected
        ..write('Período: $dateRange\n')
        ..write('Fator de correção: 1,2500000\n\n')
        ..write('Simulação feita no RealCalc, sem valor oficial.');

      final text = buildShareText(
        result(
          index: index.sgsCode,
          percentage: 80,
          originalValue: null,
          adjustedValue: null,
          factor: 1.25,
          initial: initial,
          end: end,
        ),
      );

      expect(text, expected.toString());
    });
  }
}
