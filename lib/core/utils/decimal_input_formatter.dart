import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DecimalInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
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

    double value = double.parse(onlyDigits) / 100;

    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: '');
    String formattedText = formatter.format(value).trim();

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}