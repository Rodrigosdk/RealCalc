import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/modules/value_correction/domain/enum/correction_index.dart';
import 'package:real_calc/modules/value_correction/presentation/cubit/forms/date_parsing/correction_form_date_parser.dart';
import 'package:real_calc/modules/value_correction/presentation/cubit/forms/validation/correction_form_validator.dart';
import 'package:real_calc/modules/value_correction/presentation/cubit/forms/value_correction_form_state.dart';

void main() {
  late CorrectionFormValidator validator;

  setUp(() {
    validator = CorrectionFormValidator(CorrectionFormDateParser());
  });

  group('CorrectionFormValidator', () {
    test('requer índice, datas e percentual para CDI', () {
      final noIndex = validator.validate(
        index: null,
        initialDate: '',
        finalDate: '',
        percentage: '',
        lastEditedDateField: null,
      );
      expect(
        noIndex.fieldErrors[ValueCorrectionField.selectedIndex],
        'Selecione um índice',
      );
      expect(noIndex.canCalculate, isFalse);

      final cdi = validator.validate(
        index: CorrectionIndex.cdi,
        initialDate: '01/01/2024',
        finalDate: '02/01/2024',
        percentage: '',
        lastEditedDateField: null,
      );
      expect(
        cdi.fieldErrors[ValueCorrectionField.percentage],
        'Informe o percentual',
      );
      expect(cdi.canCalculate, isFalse);
    });

    test('valida datas futuras, disponibilidade e período máximo', () {
      final future = DateTime.now().add(const Duration(days: 60));
      final futureMonth =
          '${future.month.toString().padLeft(2, '0')}/${future.year}';
      final futureResult = validator.validate(
        index: CorrectionIndex.ipca,
        initialDate: futureMonth,
        finalDate: futureMonth,
        percentage: '',
        lastEditedDateField: null,
      );
      expect(
        futureResult.fieldErrors[ValueCorrectionField.initialDate],
        'A data inicial não pode ser superior à data atual.',
      );

      final unavailable = validator.validate(
        index: CorrectionIndex.ipcaE,
        initialDate: '12/1991',
        finalDate: '01/1992',
        percentage: '',
        lastEditedDateField: null,
      );
      expect(
        unavailable.warningBannerMessage,
        'O índice IPCA-E (IBGE) possui dados a partir de 01/1992.',
      );
      expect(unavailable.canCalculate, isFalse);

      final tooLong = validator.validate(
        index: CorrectionIndex.ipca,
        initialDate: '01/2010',
        finalDate: '02/2020',
        percentage: '',
        lastEditedDateField: null,
      );
      expect(
        tooLong.warningBannerMessage,
        'O período entre as datas não pode ser superior a 10 anos exatos.',
      );
      expect(tooLong.canCalculate, isFalse);
    });

    test('associa erro de ordem ao campo editado por último', () {
      final result = validator.validate(
        index: CorrectionIndex.ipca,
        initialDate: '12/2025',
        finalDate: '01/2025',
        percentage: '',
        lastEditedDateField: ValueCorrectionField.initialDate,
      );

      expect(
        result.fieldErrors[ValueCorrectionField.initialDate],
        'A data inicial deve ser anterior ou igual à data final.',
      );
      expect(result.fieldErrors[ValueCorrectionField.finalDate], isNull);
    });

    test('habilita cálculo com dados válidos para índice sem percentual', () {
      final result = validator.validate(
        index: CorrectionIndex.ipca,
        initialDate: '01/2024',
        finalDate: '12/2024',
        percentage: '',
        lastEditedDateField: null,
      );

      expect(result.canCalculate, isTrue);
      expect(result.warningBannerMessage, isEmpty);
    });
  });
}
