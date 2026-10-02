import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/utils/month_year_input_formatter.dart';

void main() {
  late MonthYearInputFormatter formatter;

  setUp(() {
    formatter = MonthYearInputFormatter();
  });

  test('deve formatar entrada sequencial de mês e ano', () {
    var value = formatter.formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: '1'));
    value = formatter.formatEditUpdate(value, const TextEditingValue(text: '12'));
    value = formatter.formatEditUpdate(value, const TextEditingValue(text: '12/2'));
    value = formatter.formatEditUpdate(value, const TextEditingValue(text: '12/202'));
    value = formatter.formatEditUpdate(value, const TextEditingValue(text: '12/2024'));

    expect(value.text, '12/2024');
  });

  test('deve permitir apagar e manter o texto em estado incompleto', () {
    var value = formatter.formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: '12/2024'));
    value = formatter.formatEditUpdate(value, const TextEditingValue(text: '12/202'));
    value = formatter.formatEditUpdate(value, const TextEditingValue(text: '12/20'));

    expect(value.text, '12/20');
  });

  test('deve ignorar caracteres inválidos', () {
    final value = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: 'ab/2024'),
    );

    expect(value.text, '');
  });

  test('deve respeitar limite do mês', () {
    final value = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: '13'),
    );

    expect(value.text, '1');
  });
}
