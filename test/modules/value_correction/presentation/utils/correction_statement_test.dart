import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/widgets/calculator_band/band_statement.dart';
import 'package:real_calc/modules/value_correction/domain/entites/period.dart';
import 'package:real_calc/modules/value_correction/domain/entites/value_correction.dart';
import 'package:real_calc/modules/value_correction/domain/enum/correction_index.dart';
import 'package:real_calc/modules/value_correction/presentation/utils/correction_statement.dart';

ValueCorrection ipcaResult({double? original = 5555.55, double? adjusted}) =>
    ValueCorrection(
      index: CorrectionIndex.ipca.sgsCode,
      period: Period(initial: DateTime(2001, 12), end: DateTime(2003, 12)),
      percentage: 100,
      originalValue: original,
      factor: 1.2379507,
      adjustedValue: original == null ? null : (adjusted ?? 6877.498),
      variation: 23.79507,
    );

void main() {
  final nbsp = String.fromCharCode(0xA0);

  group('correctionStatement', () {
    test('inicial', () {
      expect(
        correctionStatement(index: CorrectionIndex.ipca),
        const BandStatement(
          kicker: 'Quanto vale hoje',
          value: 'o seu dinheiro?',
          sub: 'Escolha o índice, o período e o valor.',
        ),
      );
    });

    test('com valor', () {
      expect(
        correctionStatement(index: CorrectionIndex.ipca, result: ipcaResult()),
        BandStatement(
          kicker: 'Hoje, seus R\$${nbsp}5.555,55 valem',
          value: '6.877,50',
          isMoney: true,
          sub: '+23,80% pelo IPCA, de 12/2001 a 12/2003',
        ),
      );
    });

    test('sem valor', () {
      expect(
        correctionStatement(
          index: CorrectionIndex.ipca,
          result: ipcaResult(original: null),
        ),
        const BandStatement(
          kicker: 'Pelo IPCA, de 12/2001 a 12/2003, a correção é de',
          value: '+23,80%',
          sub: 'Fator de correção 1,2379507',
        ),
      );
    });

    test('data fora da série', () {
      expect(
        correctionStatement(index: CorrectionIndex.ipca, outOfRange: true),
        const BandStatement(
          kicker: 'Para corrigir pelo IPCA,',
          value: 'ajuste a data',
          sub: 'O IPCA tem dados a partir de 01/1980.',
        ),
      );
    });

    test('sem conexão tem prioridade', () {
      expect(
        correctionStatement(
          index: CorrectionIndex.ipca,
          result: ipcaResult(),
          outOfRange: true,
          offline: true,
        ),
        const BandStatement(
          kicker: 'Sem conexão com o',
          value: 'Banco Central',
          sub: 'Confira a internet e tente de novo.',
        ),
      );
    });

    test('usa o artigo de cada índice e a data diária', () {
      expect(
        correctionStatement(
          index: CorrectionIndex.selic,
          outOfRange: true,
        ).kicker,
        'Para corrigir pela Selic,',
      );
      expect(
        CorrectionIndex.poupancaNova.availabilitySentence,
        'A Poupança Nova tem dados a partir de 05/2012.',
      );
      expect(
        CorrectionIndex.igpM.sinceSentence,
        'O IGP-M tem dados desde 06/1989.',
      );
    });
  });

  group('correctionDuration', () {
    test('conta os meses incluindo o início e o fim', () {
      expect(
        correctionDuration(
          CorrectionIndex.ipca,
          DateTime(2001, 12),
          DateTime(2003, 12),
        ),
        '25 meses',
      );
      expect(
        correctionDuration(
          CorrectionIndex.ipca,
          DateTime(2024, 3),
          DateTime(2024, 3),
        ),
        '1 mês',
      );
    });

    test('conta dias nos índices diários', () {
      expect(
        correctionDuration(
          CorrectionIndex.cdi,
          DateTime(2024, 1, 1),
          DateTime(2024, 1, 31),
        ),
        '30 dias',
      );
    });
  });
}
