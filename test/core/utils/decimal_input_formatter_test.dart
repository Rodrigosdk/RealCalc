import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

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

    test('Deve permitir apagar um valor formatado até ficar vazio', () {
      const oldValue = TextEditingValue(text: '0,01');
      const newValue = TextEditingValue(
        text: '0,0',
        selection: TextSelection.collapsed(offset: 3),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '');
      expect(result.selection.baseOffset, 0);
      expect(result.selection.extentOffset, 0);
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

    test('Deve formatar zero digitado como valor decimal', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: '0');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '0,00');
    });

    test('Deve manter a posicao ao inserir digito no meio do valor', () {
      const oldValue = TextEditingValue(text: '0,23');
      const newValue = TextEditingValue(
        text: '0,243',
        selection: TextSelection.collapsed(offset: 4),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '0,243');
    });

    test('Deve manter centavos ao digitar normalmente', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: '243');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '2,43');
    });

    test('Deve preservar taxa decimal informada desde o campo vazio', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(
        text: '0,137',
        selection: TextSelection.collapsed(offset: 5),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '0,137');
    });

    test('Deve manter centavos ao digitar sequencialmente no final', () {
      var value = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '2'),
      );
      value = formatter.formatEditUpdate(
        value,
        TextEditingValue(
          text: '0,024',
          selection: const TextSelection.collapsed(offset: 5),
        ),
      );
      value = formatter.formatEditUpdate(
        value,
        TextEditingValue(
          text: '0,243',
          selection: const TextSelection.collapsed(offset: 5),
        ),
      );

      expect(value.text, '2,43');
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
