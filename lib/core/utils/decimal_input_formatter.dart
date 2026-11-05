import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DecimalInputFormatter extends TextInputFormatter {
  /// Dígitos aceitos, contando os centavos; `null` aceita qualquer tamanho.
  final int? maxDigits;

  DecimalInputFormatter({this.maxDigits});

  /// Até 999.999.999.999,99, dentro do limite de R\$ 1 trilhão dos cálculos.
  DecimalInputFormatter.money() : maxDigits = 14;

  /// Até 999,99.
  DecimalInputFormatter.percent() : maxDigits = 5;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String onlyDigits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Dígitos "reais" (sem zeros à esquerda) — ajuda a saber se o valor já é zero
    String trimmedDigits = onlyDigits.replaceFirst(RegExp(r'^0+'), '');

    bool isDeleting = newValue.text.length < oldValue.text.length;

    // Se o usuário está apagando e só sobraram zeros, limpa o campo
    if (onlyDigits.isEmpty || (isDeleting && trimmedDigits.isEmpty)) {
      return newValue.copyWith(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    if (maxDigits != null && trimmedDigits.length > maxDigits!) {
      return oldValue;
    }

    double value = double.parse(onlyDigits) / 100;

    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: '');
    String formattedText = formatter.format(value).trim();

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
