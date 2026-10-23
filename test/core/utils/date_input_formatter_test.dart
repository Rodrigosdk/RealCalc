import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/utils/date_input_formatter.dart';

void main() {
  late DateInputFormatter formatter;

  setUp(() {
    formatter = DateInputFormatter();
  });

  test('deve formatar entrada sequencial de dia, mês e ano', () {
    var value = formatter.formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: '1'));
    value = formatter.formatEditUpdate(value, const TextEditingValue(text: '12'));
    value = formatter.formatEditUpdate(value, const TextEditingValue(text: '12/0'));
    value = formatter.formatEditUpdate(value, const TextEditingValue(text: '12/05'));
    value = formatter.formatEditUpdate(value, const TextEditingValue(text: '12/05/2'));
    value = formatter.formatEditUpdate(value, const TextEditingValue(text: '12/05/2024'));

    expect(value.text, '12/05/2024');
  });

  test('deve permitir apagar até a parte incompleta', () {
    var value = formatter.formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: '12/05/2024'));
    value = formatter.formatEditUpdate(value, const TextEditingValue(text: '12/05/202'));
    value = formatter.formatEditUpdate(value, const TextEditingValue(text: '12/05/20'));

    expect(value.text, '12/05/20');
  });

  test('deve ignorar caracteres inválidos', () {
    final value = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: 'aa/05/2024'),
    );

    expect(value.text, '');
  });

  test('não bloqueia a digitação intermediária de um dia inexistente', () {
    final value = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: '32'),
    );

    expect(value.text, '32');
  });
}
