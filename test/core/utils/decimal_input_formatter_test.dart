import 'package:flutter_test/flutter_test.dart';

import 'package:real_calc/core/utils/decimal_input_formatter.dart'; // Ajuste o pacote se necessário

void main() {
  late DecimalInputFormatter formatter;

  setUp(() {
    formatter = DecimalInputFormatter();
  });

  group('DecimalInputFormatter -', () {
    test('Deve retornar texto vazio quando o novo valor for vazio', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue.empty;

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '');
    });

    test('Deve retornar texto vazio se o usuário digitar apenas caracteres não numéricos', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: 'abc');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '');
    });

    test('Deve formatar um único dígito como centavos corretos', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: '5');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '0,05');
      expect(result.selection.baseOffset, 4); // Cursor no final
    });

    test('Deve formatar dois dígitos como centavos corretos', () {
      const oldValue = TextEditingValue(text: '0,05');
      const newValue = TextEditingValue(text: '52');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '0,52');
    });

    test('Deve formatar valores inteiros quando passar de três dígitos', () {
      const oldValue = TextEditingValue(text: '0,52');
      const newValue = TextEditingValue(text: '524');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '5,24');
    });

    test('Deve aplicar separador de milhar corretamente para valores grandes', () {
      const oldValue = TextEditingValue(text: '123,45');
      const newValue = TextEditingValue(text: '123456');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '1.234,56');
    });

    test('Deve manter o cursor sempre colapsado no final do texto formatado', () {
      const oldValue = TextEditingValue(text: '1.234,56');
      const newValue = TextEditingValue(text: '1234567');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '12.345,67');
      expect(result.selection.isCollapsed, true);
      expect(result.selection.baseOffset, result.text.length);
    });
  });
}
