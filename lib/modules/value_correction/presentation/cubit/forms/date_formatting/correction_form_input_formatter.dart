import 'package:flutter/material.dart';

import '../../../../domain/enum/correction_index.dart';
import '../../../../domain/enum/date_granularity.dart';
import 'i_correction_form_input_formatter.dart';

class CorrectionFormInputFormatter implements ICorrectionFormInputFormatter {
  @override
  void normalizeDateFields(
    TextEditingController initialDate,
    TextEditingController finalDate,
    CorrectionIndex index,
  ) {
    if (index.granularity == DateGranularity.day) {
      _normalizeToDayFormat(initialDate);
      _normalizeToDayFormat(finalDate);
      return;
    }
    _normalizeToMonthFormat(initialDate);
    _normalizeToMonthFormat(finalDate);
  }

  @override
  void applyIndexDefaults(
    TextEditingController percentage,
    CorrectionIndex index,
  ) {
    if (index == CorrectionIndex.cdi) {
      percentage.text = '100';
    } else {
      percentage.clear();
    }
  }

  void _normalizeToDayFormat(TextEditingController controller) {
    final value = controller.text.trim();
    if (_looksLikeMonthYear(value)) {
      controller.text = '01/$value';
    }
  }

  void _normalizeToMonthFormat(TextEditingController controller) {
    final value = controller.text.trim();
    if (!_looksLikeDayDate(value)) return;
    final parts = value.split('/');
    controller.text = '${parts[1]}/${parts[2]}';
  }

  bool _looksLikeMonthYear(String value) =>
      value.isNotEmpty && value.split('/').length == 2;

  bool _looksLikeDayDate(String value) =>
      value.isNotEmpty && value.split('/').length == 3;
}
