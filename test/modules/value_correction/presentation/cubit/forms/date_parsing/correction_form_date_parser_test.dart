import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/modules/value_correction/domain/enum/date_granularity.dart';
import 'package:real_calc/modules/value_correction/presentation/cubit/forms/date_parsing/correction_form_date_parser.dart';

void main() {
  late CorrectionFormDateParser parser;

  setUp(() {
    parser = CorrectionFormDateParser();
  });

  group('CorrectionFormDateParser', () {
    test('interpreta data mensal no formato MM/aaaa', () {
      expect(parser.parse('02/2024', DateGranularity.month), DateTime(2024, 2));
    });

    test('interpreta data diária e rejeita datas inexistentes', () {
      expect(
        parser.parse('29/02/2024', DateGranularity.day),
        DateTime(2024, 2, 29),
      );
      expect(parser.parse('29/02/2023', DateGranularity.day), isNull);
      expect(parser.parse('31/04/2024', DateGranularity.day), isNull);
    });

    test('rejeita entradas vazias e formatos incompatíveis', () {
      expect(parser.parse('', DateGranularity.month), isNull);
      expect(parser.parse('01/01/2024', DateGranularity.month), isNull);
      expect(parser.parse('01/2024', DateGranularity.day), isNull);
    });

    test('identifica datas futuras em ambas as granularidades', () {
      final future = DateTime.now().add(const Duration(days: 40));
      final monthly =
          '${future.month.toString().padLeft(2, '0')}/${future.year}';
      final daily =
          '${future.day.toString().padLeft(2, '0')}/'
          '${future.month.toString().padLeft(2, '0')}/${future.year}';

      expect(parser.isFutureDate(monthly, DateGranularity.month), isTrue);
      expect(parser.isFutureDate(daily, DateGranularity.day), isTrue);
      expect(parser.isFutureDate('invalida', DateGranularity.day), isFalse);
    });
  });
}
