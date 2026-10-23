import 'package:flutter/services.dart';

class MonthYearInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return const TextEditingValue(text: '');
    }

    if (newValue.text.contains(RegExp(r'[^0-9/]'))) {
      return const TextEditingValue(text: '');
    }

    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }

    String monthText = digits;
    String yearText = '';

    if (digits.length > 2) {
      monthText = digits.substring(0, 2);
      yearText = digits.substring(2);
    }

    var formatted = monthText;
    if (yearText.isNotEmpty) {
      formatted = '$monthText/$yearText';
    }

    final selection = TextSelection.collapsed(offset: formatted.length);
    return newValue.copyWith(text: formatted, selection: selection);
  }
}
