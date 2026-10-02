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

    var monthText = digits;
    var yearText = '';

    if (digits.length >= 2) {
      final month = int.tryParse(digits.substring(0, 2)) ?? 0;
      if (month == 0 || month > 12) {
        monthText = digits.substring(0, 1);
        if (digits.length > 2) {
          yearText = digits.substring(2);
        }
      } else {
        monthText = digits.substring(0, 2);
        if (digits.length > 2) {
          yearText = digits.substring(2);
        }
      }
    }

    if (monthText.length == 2 && yearText.isEmpty && digits.length > 2) {
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
