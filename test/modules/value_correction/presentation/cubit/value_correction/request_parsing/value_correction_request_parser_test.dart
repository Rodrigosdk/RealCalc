import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/modules/value_correction/domain/enum/correction_index.dart';
import 'package:real_calc/modules/value_correction/presentation/cubit/forms/date_parsing/correction_form_date_parser.dart';
import 'package:real_calc/modules/value_correction/presentation/cubit/value_correction/request_parsing/value_correction_request_parser.dart';

void main() {
  late ValueCorrectionRequestParser parser;

  setUp(() {
    parser = ValueCorrectionRequestParser(CorrectionFormDateParser());
  });

  group('ValueCorrectionRequestParser', () {
    test(
      'cria parâmetros a partir de datas mensais e ignora percentual não CDI',
      () {
        final params = parser.parse(
          index: CorrectionIndex.ipca,
          initialDate: '01/2024',
          finalDate: '02/2024',
          percentage: '80',
          value: '1.234,56',
        );

        expect(params, isNotNull);
        expect(params!.period.initial, DateTime(2024, 1));
        expect(params.period.end, DateTime(2024, 2));
        expect(params.percentage, 0);
        expect(params.originalValue, 1234.56);
        expect(params.adjustedValue, 1234.56);
      },
    );

    test('usa 100% para índices diários e CDI quando percentual inválido', () {
      final dailyParams = parser.parse(
        index: CorrectionIndex.selic,
        initialDate: '01/01/2024',
        finalDate: '02/01/2024',
        percentage: '',
        value: '',
      );
      final cdiParams = parser.parse(
        index: CorrectionIndex.cdi,
        initialDate: '01/01/2024',
        finalDate: '02/01/2024',
        percentage: '0',
        value: '',
      );

      expect(dailyParams!.percentage, 100);
      expect(cdiParams!.percentage, 100);
      expect(dailyParams.originalValue, isNull);
      expect(dailyParams.adjustedValue, isNull);
    });

    test(
      'usa percentual CDI positivo fornecido e retorna null para datas inválidas',
      () {
        final params = parser.parse(
          index: CorrectionIndex.cdi,
          initialDate: '01/01/2024',
          finalDate: '02/01/2024',
          percentage: '80,5',
          value: '100',
        );

        expect(params!.percentage, 80.5);
        expect(
          parser.parse(
            index: CorrectionIndex.cdi,
            initialDate: '31/02/2024',
            finalDate: '02/01/2024',
            percentage: '100',
            value: '100',
          ),
          isNull,
        );
      },
    );
  });
}
