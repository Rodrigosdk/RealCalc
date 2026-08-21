import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_calc/core/themes/extensions/financing_forms_theme.dart';
import 'package:real_calc/core/themes/spacing.dart';
import 'package:real_calc/core/utils/decimal_input_formatter.dart';
import 'package:real_calc/core/widgets/options_bottom_forms.dart';
import '../../../financing/presentation/widgets/input_forms_result_card.dart';
import '../../domain/entities/future_value.dart';
import '../cubit/future_value_cubit.dart';

class FutureValueForms extends StatefulWidget {
  const FutureValueForms({super.key});

  @override
  State<FutureValueForms> createState() => _FutureValueFormsState();
}

class _FutureValueFormsState extends State<FutureValueForms> {
  final _formKey = GlobalKey<FormState>();
  final _capitalController = TextEditingController();
  final _monthsController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _finalValueController = TextEditingController();

  String? _errorMessage;

  @override
  void dispose() {
    _capitalController.dispose();
    _monthsController.dispose();
    _interestRateController.dispose();
    _finalValueController.dispose();
    super.dispose();
  }

  void _clearForm() {
    setState(() => _errorMessage = null);
    _capitalController.clear();
    _monthsController.clear();
    _interestRateController.clear();
    _finalValueController.clear();
  }

  void _updateInputsFromState(FutureValue value) {
    final formatter = DecimalInputFormatter();
    _capitalController.value = (value.capital ?? 0) > 0
        ? formatter.formatEditUpdate(
            TextEditingValue.empty,
            TextEditingValue(
                text: (value.capital ?? 0).toStringAsFixed(2).replaceAll('.', '')),
          )
        : TextEditingValue.empty;
    _monthsController.text = (value.months ?? 0) > 0 ? (value.months ?? 0).toString() : '';
    _interestRateController.value = (value.interestRate ?? 0) > 0
        ? formatter.formatEditUpdate(
            TextEditingValue.empty,
            TextEditingValue(text: (value.interestRate ?? 0).toStringAsFixed(2).replaceAll('.', '')),
          )
        : TextEditingValue.empty;
    _finalValueController.value = (value.finalValue ?? 0) > 0
        ? formatter.formatEditUpdate(
            TextEditingValue.empty,
            TextEditingValue(text: (value.finalValue ?? 0).toStringAsFixed(2).replaceAll('.', '')),
          )
        : TextEditingValue.empty;
  }

  double _parseFormattedDouble(String text) {
    final cleaned = text.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0;
  }

  FutureValue _getEntityFromInputs() {
    return FutureValue(
      capital: _parseFormattedDouble(_capitalController.text),
      months: int.tryParse(_monthsController.text) ?? 0,
      interestRate: _parseFormattedDouble(_interestRateController.text),
      finalValue: _parseFormattedDouble(_finalValueController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<FutureValueCubit>(context);
    final styles = Theme.of(context).extension<FinancingFormsTheme>()!;

    return BlocConsumer<FutureValueCubit, FutureValueState>(
      listener: (context, state) {
        if (state is FutureValueCalculated) {
          setState(() => _errorMessage = null);
          _updateInputsFromState(state.value);
        }
        if (state is FutureValueError) {
          setState(() => _errorMessage = state.message);
        }
      },
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: styles.errorContainerPadding,
                  decoration: BoxDecoration(
                    color: styles.errorBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: styles.errorBorderColor),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: styles.errorTextStyle,
                  ),
                ),
              if (state is FutureValueLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: LinearProgressIndicator(
                    color: styles.progressIndicatorColor,
                  ),
                ),
              InputFormsResultCard(
                label: 'Capital (R\$)',
                hint: '0,00',
                controller: _capitalController,
                inputFormatters: [DecimalInputFormatter()],
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 14, right: 10),
                  child: Icon(Icons.attach_money, color: styles.iconColor),
                ),
                onTap: () => cubit.calculate(_getEntityFromInputs()),
              ),
              SizedBox(height: AppSpacing.md + 2),
              InputFormsResultCard(
                label: 'Prazo (meses)',
                hint: '0',
                controller: _monthsController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 14, right: 10),
                  child: Icon(Icons.calendar_today, color: styles.iconColor),
                ),
                onTap: () => cubit.calculate(_getEntityFromInputs()),
              ),
              SizedBox(height: AppSpacing.md + 2),
              InputFormsResultCard(
                label: 'Taxa de juros (% ao mês)',
                hint: '0,00',
                controller: _interestRateController,
                inputFormatters: [DecimalInputFormatter()],
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 14, right: 10),
                  child: Icon(Icons.percent, color: styles.iconColor),
                ),
                onTap: () => cubit.calculate(_getEntityFromInputs()),
              ),
              SizedBox(height: AppSpacing.md + 2),
              InputFormsResultCard(
                label: 'Valor final',
                hint: '0,00',
                controller: _finalValueController,
                inputFormatters: [DecimalInputFormatter()],
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 14, right: 10),
                  child: Icon(Icons.payments, color: styles.iconColor),
                ),
                onTap: () => cubit.calculate(_getEntityFromInputs()),
              ),
              SizedBox(height: AppSpacing.lg),
              OptionsBottomForms(
                onCalculate: () => cubit.calculate(_getEntityFromInputs()),
                onClear: _clearForm,
              ),
            ],
          ),
        );
      },
    );
  }
}
