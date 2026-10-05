import 'package:flutter/services.dart';

class DateInputFormatter extends TextInputFormatter {
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

    var dayText = digits;
    var monthText = '';
    var yearText = '';

    if (digits.length >= 2) {
      dayText = digits.substring(0, 2);
    }

    if (digits.length > 2) {
      final remaining = digits.substring(2);
      if (remaining.length >= 2) {
        monthText = remaining.substring(0, 2);
        if (remaining.length > 2) {
          yearText = remaining.substring(2);
        }
      } else {
        monthText = remaining;
      }
    }

    var formatted = dayText;
    if (monthText.isNotEmpty) {
      formatted = '$dayText/$monthText';
    }
    if (yearText.isNotEmpty) {
      formatted = '$formatted/$yearText';
    }

    final selection = TextSelection.collapsed(offset: formatted.length);
    return newValue.copyWith(text: formatted, selection: selection);
  }
}
