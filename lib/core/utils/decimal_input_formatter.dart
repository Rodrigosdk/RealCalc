import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DecimalInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return _emptyValue(newValue);
    }

    String onlyDigits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (onlyDigits.isEmpty) {
      return _emptyValue(newValue);
    }

    if (oldValue.text.isEmpty && newValue.text.contains(',')) {
      return _formatExplicitValue(newValue);
    }

    if (newValue.text.length < oldValue.text.length &&
        RegExp(r'^0+$').hasMatch(onlyDigits)) {
      return _emptyValue(newValue);
    }

    final isInsertionInFormattedValue =
      oldValue.text.isNotEmpty &&
      newValue.text.contains(',') &&
      newValue.selection.baseOffset < newValue.text.length;

    if (isInsertionInFormattedValue) {
      return _formatExplicitValue(newValue);
    }

    double value = double.parse(onlyDigits) / 100;

    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: '');
    String formattedText = formatter.format(value).trim();

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }

  TextEditingValue _emptyValue(TextEditingValue value) {
    return value.copyWith(
      text: '',
      selection: const TextSelection.collapsed(offset: 0),
      composing: TextRange.empty,
    );
  }

  TextEditingValue _formatExplicitValue(TextEditingValue value) {
    final parts = value.text.split(',');
    final integerDigits = parts.first.replaceAll(RegExp(r'[^\d]'), '');
    final decimalDigits = parts.skip(1).join().replaceAll(RegExp(r'[^\d]'), '');
    final integerValue = int.tryParse(integerDigits) ?? 0;
    final integerText = NumberFormat.decimalPattern('pt_BR').format(integerValue);
    final formattedText = '$integerText,$decimalDigits';

    return value.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }

}
