import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/modules/value_correction/domain/enum/correction_index.dart';

void main() {
  group('CorrectionIndex', () {
    test('o nome não carrega a fonte entre parênteses', () {
      for (final index in CorrectionIndex.values) {
        expect(index.label, isNot(contains('(')));
        expect(index.source, isNotEmpty);
      }
      expect(CorrectionIndex.ipca.label, 'IPCA');
      expect(CorrectionIndex.ipca.source, 'IBGE');
      expect(CorrectionIndex.igpM.source, 'FGV');
    });

    test('sinceMonthLabel usa mm/aaaa mesmo nas séries diárias', () {
      expect(CorrectionIndex.ipcSp.sinceMonthLabel, '11/1942');
      expect(CorrectionIndex.selic.sinceMonthLabel, '06/1986');
      expect(CorrectionIndex.taxaLegal.sinceMonthLabel, '08/2024');
    });
  });
}
