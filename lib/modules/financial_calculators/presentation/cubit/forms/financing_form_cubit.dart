import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_calc/core/utils/decimal_input_formatter.dart';
import '../../../domain/entities/financial_calculation.dart';
import '../../../domain/enum/financial_calculation_target.dart';
import '../../../domain/enum/input_field_state.dart';
import 'financing_form_state.dart';

class FinancingFormCubit extends Cubit<FinancingFormState> {
  final initialValue = TextEditingController();
  final months = TextEditingController();
  final rate = TextEditingController();
  final finalValue = TextEditingController();

  bool _suppressRecompute = false;

  FinancingFormCubit() : super(FinancingFormState.initial()) {
    for (final controller in _controllers) {
      controller.addListener(_onControllerChanged);
    }
  }

  List<TextEditingController> get _controllers =>
      [initialValue, months, rate, finalValue];

  TextEditingController controllerFor(FinancialCalculationTarget field) => switch (field) {
        FinancialCalculationTarget.initialValue => initialValue,
        FinancialCalculationTarget.periods => months,
        FinancialCalculationTarget.interestRate => rate,
        FinancialCalculationTarget.finalValue => finalValue,
      };

  bool _isEmpty(FinancialCalculationTarget field) =>
      controllerFor(field).text.trim().isEmpty;

  double _parseFormattedDouble(String text) {
    final cleaned = text.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0;
  }

  /// Snapshot atual dos campos, pra mandar pro FinancingCubit calcular.
  FinancialCalculation get financing => FinancialCalculation(
        initialValue: _parseFormattedDouble(initialValue.text),
        periods: int.tryParse(months.text) ?? 0,
        rate: _parseFormattedDouble(rate.text),
        finalValue: _parseFormattedDouble(finalValue.text),
      );

  void _onControllerChanged() {
    if (_suppressRecompute) return;
    _recompute(clearCalculatedField: true);
  }

  void _recompute({
    FinancialCalculationTarget? calculatedFieldOverride,
    bool clearCalculatedField = false,
  }) {
    final calculatedField = clearCalculatedField
        ? null
        : calculatedFieldOverride ?? state.calculatedField;
    final emptyCount = FinancialCalculationTarget.values.where(_isEmpty).length;

    final fieldStates = <FinancialCalculationTarget, InputFieldState>{
      for (final field in FinancialCalculationTarget.values)
        field: _stateFor(field, calculatedField, emptyCount),
    };

    emit(FinancingFormState(
      calculatedField: calculatedField,
      fieldStates: fieldStates,
      canCalculate: emptyCount == 1,
    ));
  }

  InputFieldState _stateFor(
    FinancialCalculationTarget field,
    FinancialCalculationTarget? calculatedField,
    int emptyCount,
  ) {
    if (!_isEmpty(field)) {
      return field == calculatedField
          ? InputFieldState.calculated
          : InputFieldState.neutral;
    }
    if (emptyCount != 1) {
      return InputFieldState.neutral;
    }

    return InputFieldState.highlighted;
  }

  void _setFormattedValue(
    TextEditingController controller,
    double value, {
    int fractionDigits = 2,
  }) {
    if (value <= 0) {
      controller.value = TextEditingValue.empty;
      return;
    }
    final formatter = DecimalInputFormatter();
    final parts = value.toStringAsFixed(fractionDigits).split('.');
    var decimals = parts[1].replaceFirst(RegExp(r'0+$'), '');
    while (decimals.length < 2) {
      decimals += '0';
    }
    controller.value = formatter.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(text: '${parts[0]},$decimals'),
    );
  }

  /// Chamado quando o FinancingCubit termina de calcular com sucesso —
  /// preenche o campo resolvido e marca ele como "calculated". Os 4 sets
  /// de texto são feitos com o recompute suprimido, pra emitir um único
  /// estado no final em vez de 4 emissões intermediárias.
  void applyResult(FinancialCalculation result, FinancialCalculationTarget calculatedField) {
    _suppressRecompute = true;
    _setFormattedValue(initialValue, result.initialValue);
    months.text = result.periods > 0 ? result.periods.toString() : '';
    _setFormattedValue(rate, result.rate, fractionDigits: 4);
    _setFormattedValue(finalValue, result.finalValue);
    _suppressRecompute = false;

    _recompute(calculatedFieldOverride: calculatedField);
  }

  /// Chamado quando o FinancingCubit emite erro — o destaque de "calculado"
  /// não faz mais sentido depois de um erro novo.
  void invalidateCalculatedField() {
    _recompute(clearCalculatedField: true);
  }

  void clear() {
    _suppressRecompute = true;
    for (final controller in _controllers) {
      controller.clear();
    }
    _suppressRecompute = false;

    _recompute(clearCalculatedField: true);
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