import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DecimalInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String onlyDigits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (onlyDigits.isEmpty) {
      return newValue.copyWith(text: '');
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
