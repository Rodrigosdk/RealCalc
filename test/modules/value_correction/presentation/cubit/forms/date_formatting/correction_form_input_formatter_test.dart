import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/modules/value_correction/domain/enum/correction_index.dart';
import 'package:real_calc/modules/value_correction/presentation/cubit/forms/date_formatting/correction_form_input_formatter.dart';

void main() {
  late CorrectionFormInputFormatter formatter;
  late TextEditingController initialDate;
  late TextEditingController finalDate;
  late TextEditingController percentage;

  setUp(() {
    formatter = CorrectionFormInputFormatter();
    initialDate = TextEditingController();
    finalDate = TextEditingController();
    percentage = TextEditingController();
  });

  tearDown(() {
    initialDate.dispose();
    finalDate.dispose();
    percentage.dispose();
  });

  group('CorrectionFormInputFormatter', () {
    test('converte datas mensais para formato diário quando necessário', () {
      initialDate.text = '02/2024';
      finalDate.text = '03/2024';

      formatter.normalizeDateFields(
        initialDate,
        finalDate,
        CorrectionIndex.cdi,
      );

      expect(initialDate.text, '01/02/2024');
      expect(finalDate.text, '01/03/2024');
    });

    test('converte datas diárias para formato mensal quando necessário', () {
      initialDate.text = '15/02/2024';
      finalDate.text = '29/02/2024';

      formatter.normalizeDateFields(
        initialDate,
        finalDate,
        CorrectionIndex.ipca,
      );

      expect(initialDate.text, '02/2024');
      expect(finalDate.text, '02/2024');
    });

    test('define percentual padrão para CDI e limpa para outros índices', () {
      formatter.applyIndexDefaults(percentage, CorrectionIndex.cdi);
      expect(percentage.text, '100');

      formatter.applyIndexDefaults(percentage, CorrectionIndex.ipca);
      expect(percentage.text, isEmpty);
    });
  });
}
