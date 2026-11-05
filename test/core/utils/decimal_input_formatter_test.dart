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

    test(
      'Deve retornar texto vazio se o usuário digitar apenas caracteres não numéricos',
      () {
        const oldValue = TextEditingValue.empty;
        const newValue = TextEditingValue(text: 'abc');

        final result = formatter.formatEditUpdate(oldValue, newValue);

        expect(result.text, '');
      },
    );

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

    test('Deve manter centavos ao digitar normalmente', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: '243');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '2,43');
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

    test(
      'Deve aplicar separador de milhar corretamente para valores grandes',
      () {
        const oldValue = TextEditingValue(text: '123,45');
        const newValue = TextEditingValue(text: '123456');

        final result = formatter.formatEditUpdate(oldValue, newValue);

        expect(result.text, '1.234,56');
      },
    );

    test(
      'Deve manter o cursor sempre colapsado no final do texto formatado',
      () {
        const oldValue = TextEditingValue(text: '1.234,56');
        const newValue = TextEditingValue(text: '1234567');

        final result = formatter.formatEditUpdate(oldValue, newValue);

        expect(result.text, '12.345,67');
        expect(result.selection.isCollapsed, true);
        expect(result.selection.baseOffset, result.text.length);
      },
    );
  });

  group('DecimalInputFormatter com limite de dígitos', () {
    TextEditingValue type(
      DecimalInputFormatter formatter,
      String old,
      String typed,
    ) => formatter.formatEditUpdate(
      TextEditingValue(text: old),
      TextEditingValue(text: typed),
    );

    test('money aceita até 999.999.999.999,99 e ignora o dígito seguinte', () {
      final formatter = DecimalInputFormatter.money();

      final max = type(formatter, '99.999.999.999,99', '99999999999999');
      expect(max.text, '999.999.999.999,99');

      final over = type(formatter, max.text, '999999999999999');
      expect(over.text, '999.999.999.999,99');
    });

    test('percent aceita até 999,99', () {
      final formatter = DecimalInputFormatter.percent();

      expect(type(formatter, '99,99', '99999').text, '999,99');
      expect(type(formatter, '999,99', '999999').text, '999,99');
    });

    test('zeros à esquerda não contam para o limite', () {
      final formatter = DecimalInputFormatter.percent();

      expect(type(formatter, '', '0000012').text, '0,12');
    });

    test('sem limite aceita qualquer tamanho', () {
      final formatter = DecimalInputFormatter();

      expect(
        type(formatter, '', '100000000000000').text,
        '1.000.000.000.000,00',
      );
    });
  });
}
