import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/enum/correction_index.dart';
import '../../../domain/enum/date_granularity.dart';
import 'value_correction_form_state.dart';

class ValueCorrectionFormCubit extends Cubit<ValueCorrectionFormState> {
  final initialDate = TextEditingController();
  final finalDate = TextEditingController();
  final percentage = TextEditingController();
  final value = TextEditingController();

  ValueCorrectionField? _lastEditedDateField;
  String _lastInitialText = '';
  String _lastFinalText = '';

  ValueCorrectionFormCubit() : super(ValueCorrectionFormState.initial()) {
    for (final controller in _controllers) {
      controller.addListener(_onControllerChanged);
    }
    _refreshValidation();
  }

  List<TextEditingController> get _controllers => [
    initialDate,
    finalDate,
    percentage,
    value,
  ];

  TextEditingController controllerFor(ValueCorrectionField field) =>
      switch (field) {
        ValueCorrectionField.initialDate => initialDate,
        ValueCorrectionField.finalDate => finalDate,
        ValueCorrectionField.percentage => percentage,
        ValueCorrectionField.value => value,
        ValueCorrectionField.selectedIndex => throw UnsupportedError(
          'O índice não é suportado por um controlador.',
        ),
      };

  void _onControllerChanged() {
    _updateLastEditedDateField();
    _refreshValidation();
  }

  void _updateLastEditedDateField() {
    if (initialDate.text != _lastInitialText) {
      _lastEditedDateField = ValueCorrectionField.initialDate;
      _lastInitialText = initialDate.text;
      return;
    }

    if (finalDate.text != _lastFinalText) {
      _lastEditedDateField = ValueCorrectionField.finalDate;
      _lastFinalText = finalDate.text;
    }
  }

  void _refreshValidation() {
    final index = state.index;
    final dateGranularity = index?.granularity ?? DateGranularity.month;
    final showsPercentage = index == CorrectionIndex.cdi;
    final hasInitialDate = initialDate.text.trim().isNotEmpty;
    final hasFinalDate = finalDate.text.trim().isNotEmpty;
    final hasPercentage = percentage.text.trim().isNotEmpty;

    final errors = <ValueCorrectionField, String?>{
      ValueCorrectionField.selectedIndex: null,
      ValueCorrectionField.initialDate: null,
      ValueCorrectionField.finalDate: null,
      ValueCorrectionField.percentage: null,
      ValueCorrectionField.value: null,
    };

    if (index == null) {
      errors[ValueCorrectionField.selectedIndex] = 'Selecione um índice';
    }

    if (hasInitialDate && !_isValidDate(initialDate.text, dateGranularity)) {
      errors[ValueCorrectionField.initialDate] = 'Data inicial inválida';
    } else if (hasInitialDate &&
        _isFutureDate(initialDate.text, dateGranularity)) {
      errors[ValueCorrectionField.initialDate] =
          'A data inicial não pode ser superior à data atual.';
    }

    if (hasFinalDate && !_isValidDate(finalDate.text, dateGranularity)) {
      errors[ValueCorrectionField.finalDate] = 'Data final inválida';
    } else if (hasFinalDate && _isFutureDate(finalDate.text, dateGranularity)) {
      errors[ValueCorrectionField.finalDate] =
          'A data final não pode ser superior à data atual.';
    }

    if (index != null &&
        hasInitialDate &&
        _isValidDate(initialDate.text, dateGranularity) &&
        _parseDate(
          initialDate.text,
          dateGranularity,
        )!.isBefore(index.minimumInputDate)) {
      errors[ValueCorrectionField.initialDate] = index.availabilityMessage;
    }

    if (index != null &&
        hasFinalDate &&
        _isValidDate(finalDate.text, dateGranularity) &&
        _parseDate(
          finalDate.text,
          dateGranularity,
        )!.isBefore(index.minimumInputDate)) {
      errors[ValueCorrectionField.finalDate] = index.availabilityMessage;
    }

    final hasValidInitialDate =
        hasInitialDate && errors[ValueCorrectionField.initialDate] == null;
    final hasValidFinalDate =
        hasFinalDate && errors[ValueCorrectionField.finalDate] == null;

    if (hasValidInitialDate && hasValidFinalDate) {
      final initialDateValue = _parseDate(initialDate.text, dateGranularity)!;
      final finalDateValue = _parseDate(finalDate.text, dateGranularity)!;

      if (initialDateValue.isAfter(finalDateValue)) {
        final targetField =
            _lastEditedDateField ?? ValueCorrectionField.finalDate;

        if (targetField == ValueCorrectionField.finalDate) {
          errors[ValueCorrectionField.finalDate] =
              'A data final deve ser posterior ou igual à data inicial.';
          errors[ValueCorrectionField.initialDate] = null;
        } else {
          errors[ValueCorrectionField.initialDate] =
              'A data inicial deve ser anterior ou igual à data final.';
          errors[ValueCorrectionField.finalDate] = null;
        }
      } else if (index != null &&
          finalDateValue.isAfter(
            index.latestAllowedEndDate(initialDateValue),
          )) {
        errors[ValueCorrectionField.finalDate] =
            'O período entre as datas não pode ser superior a 10 anos exatos.';
      }
    }

    if (showsPercentage && !hasPercentage) {
      errors[ValueCorrectionField.percentage] = 'Informe o percentual';
    }

    emit(
      state.copyWith(
        index: index,
        dateGranularity: dateGranularity,
        showsPercentage: showsPercentage,
        canCalculate:
            index != null &&
            hasInitialDate &&
            hasFinalDate &&
            errors[ValueCorrectionField.initialDate] == null &&
            errors[ValueCorrectionField.finalDate] == null &&
            (!showsPercentage ||
                (hasPercentage &&
                    errors[ValueCorrectionField.percentage] == null)),
        showsCurrencyWarning: _isCurrencyWarning(
          initialDate.text,
          dateGranularity,
        ),
        fieldErrors: errors,
      ),
    );
  }

  void setIndex(CorrectionIndex newIndex) {
    _resetDateTracking();

    if (newIndex.granularity == DateGranularity.day) {
      _normalizeToDayFormat(initialDate);
      _normalizeToDayFormat(finalDate);
    } else {
      _normalizeToMonthFormat(initialDate);
      _normalizeToMonthFormat(finalDate);
    }

    if (newIndex == CorrectionIndex.cdi) {
      percentage.text = '100';
    } else {
      percentage.clear();
    }

    emit(
      state.copyWith(
        index: newIndex,
        dateGranularity: newIndex.granularity,
        showsPercentage: newIndex == CorrectionIndex.cdi,
        canCalculate: false,
        showsCurrencyWarning: _isCurrencyWarning(
          initialDate.text,
          newIndex.granularity,
        ),
      ),
    );
    _refreshValidation();
  }

  void _normalizeToDayFormat(TextEditingController controller) {
    final value = controller.text.trim();
    if (_looksLikeMonthYear(value)) {
      controller.text = '01/${value.trim()}';
    }
  }

  void _normalizeToMonthFormat(TextEditingController controller) {
    final value = controller.text.trim();
    if (_looksLikeDayDate(value)) {
      final parts = value.split('/');
      controller.text = '${parts[1]}/${parts[2]}';
    }
  }

  bool _looksLikeMonthYear(String value) {
    final parts = value.trim().split('/');
    return value.trim().isNotEmpty && parts.length == 2;
  }

  bool _looksLikeDayDate(String value) {
    final parts = value.trim().split('/');
    return value.trim().isNotEmpty && parts.length == 3;
  }

  bool _isCurrencyWarning(String value, DateGranularity granularity) {
    final date = _parseDate(value, granularity);
    if (date == null) return false;
    return date.isBefore(DateTime(1994, 7, 1));
  }

  bool _isFutureDate(String value, DateGranularity granularity) {
    final date = _parseDate(value, granularity);
    if (date == null) return false;

    final today = DateTime.now();
    final todayAtMidnight = DateTime(today.year, today.month, today.day);
    return date.isAfter(todayAtMidnight);
  }

  bool _isValidDate(String value, DateGranularity granularity) {
    return _parseDate(value, granularity) != null;
  }

  DateTime? _parseDate(String value, DateGranularity granularity) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final parts = trimmed.split('/');
    if (granularity == DateGranularity.month) {
      if (parts.length != 2) return null;
      final month = int.tryParse(parts[0]);
      final year = int.tryParse(parts[1]);
      if (month == null || year == null || month < 1 || month > 12) return null;
      return DateTime(year, month, 1);
    }

    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    if (day < 1 || month < 1 || month > 12) return null;
    final parsed = DateTime(year, month, day);
    if (parsed.year != year || parsed.month != month || parsed.day != day) {
      return null;
    }
    return parsed;
  }

  void _resetDateTracking() {
    _lastEditedDateField = null;
    _lastInitialText = '';
    _lastFinalText = '';
  }

  void clear() {
    _resetDateTracking();
    for (final controller in _controllers) {
      controller.clear();
    }
    emit(ValueCorrectionFormState.initial());
  }

  @override
  Future<void> close() {
    for (final controller in _controllers) {
      controller.removeListener(_onControllerChanged);
      controller.dispose();
    }
    return super.close();
  }
}
