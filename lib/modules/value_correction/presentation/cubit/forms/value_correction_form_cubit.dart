import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/enum/correction_index.dart';
import '../../../domain/enum/date_granularity.dart';
import 'date_formatting/i_correction_form_input_formatter.dart';
import 'validation/i_correction_form_validator.dart';
import 'value_correction_form_state.dart';

class ValueCorrectionFormCubit extends Cubit<ValueCorrectionFormState> {
  final ICorrectionFormInputFormatter _inputFormatter;
  final ICorrectionFormValidator _validator;

  final initialDate = TextEditingController();
  final finalDate = TextEditingController();
  final percentage = TextEditingController();
  final value = TextEditingController();

  ValueCorrectionField? _lastEditedDateField;
  String _lastInitialText = '';
  String _lastFinalText = '';

  ValueCorrectionFormCubit(this._inputFormatter, this._validator)
    : super(ValueCorrectionFormState.initial()) {
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
    final validation = _validator.validate(
      index: state.index,
      initialDate: initialDate.text,
      finalDate: finalDate.text,
      percentage: percentage.text,
      lastEditedDateField: _lastEditedDateField,
    );
    final index = state.index;

    emit(
      state.copyWith(
        index: index,
        dateGranularity: index?.granularity ?? DateGranularity.month,
        showsPercentage: index == CorrectionIndex.cdi,
        canCalculate: validation.canCalculate,
        warningBannerMessage: validation.warningBannerMessage,
        fieldErrors: validation.fieldErrors,
      ),
    );
  }

  void setIndex(CorrectionIndex newIndex) {
    _resetDateTracking();
    _inputFormatter.normalizeDateFields(initialDate, finalDate, newIndex);
    _inputFormatter.applyIndexDefaults(percentage, newIndex);

    emit(
      state.copyWith(
        index: newIndex,
        dateGranularity: newIndex.granularity,
        showsPercentage: newIndex == CorrectionIndex.cdi,
        canCalculate: false,
      ),
    );
    _refreshValidation();
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
