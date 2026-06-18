import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_calc/core/themes/extensions/financing_forms_theme.dart';
import 'package:real_calc/core/themes/spacing.dart';
import 'package:real_calc/core/utils/decimal_input_formatter.dart';
import 'package:real_calc/core/widgets/options_bottom_forms.dart';
import '../../domain/entities/financing.dart';
import '../cubit/financing_cubit.dart';
import 'input_forms_result_card.dart';

class FinancingForms extends StatefulWidget {
  const FinancingForms({super.key});

  @override
  State<FinancingForms> createState() => _FinancingFormsState();
}

class _FinancingFormsState extends State<FinancingForms> {
  final _formKey = GlobalKey<FormState>();
  final _initialValueController = TextEditingController();
  final _monthsController = TextEditingController();
  final _rateController = TextEditingController();
  final _finalValueController = TextEditingController();

  String? _errorMessage;

  @override
  void dispose() {
    _initialValueController.dispose();
    _monthsController.dispose();
    _rateController.dispose();
    _finalValueController.dispose();
    super.dispose();
  }

  void _clearForm() {
    setState(() => _errorMessage = null);
    _initialValueController.clear();
    _monthsController.clear();
    _rateController.clear();
    _finalValueController.clear();
  }

  void _updateInputsFromState(Financing financing) {
    final formatter = DecimalInputFormatter();
    _initialValueController.value = financing.initialValue > 0
        ? formatter.formatEditUpdate(
            TextEditingValue.empty,
            TextEditingValue(
                text: financing.initialValue
                    .toStringAsFixed(2)
                    .replaceAll('.', '')),
          )
        : TextEditingValue.empty;
    _monthsController.text =
        financing.months > 0 ? financing.months.toString() : '';
    _rateController.value = financing.rate > 0
        ? formatter.formatEditUpdate(
            TextEditingValue.empty,
            TextEditingValue(
                text:
                    financing.rate.toStringAsFixed(2).replaceAll('.', '')),
          )
        : TextEditingValue.empty;
    _finalValueController.value = financing.finalValue > 0
        ? formatter.formatEditUpdate(
            TextEditingValue.empty,
            TextEditingValue(
                text: financing.finalValue
                    .toStringAsFixed(2)
                    .replaceAll('.', '')),
          )
        : TextEditingValue.empty;
  }

  double _parseFormattedDouble(String text) {
    final cleaned = text.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0;
  }

  Financing _getFinancingFromInputs() {
    return Financing(
      initialValue: _parseFormattedDouble(_initialValueController.text),
      months: int.tryParse(_monthsController.text) ?? 0,
      rate: _parseFormattedDouble(_rateController.text),
      finalValue: _parseFormattedDouble(_finalValueController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final financingCubit = BlocProvider.of<FinancingCubit>(context);
    final styles = Theme.of(context).extension<FinancingFormsTheme>()!;

    return BlocConsumer<FinancingCubit, FinancingState>(
      listener: (context, state) {
        if (state is FinancingCalculated) {
          setState(() => _errorMessage = null);
          _updateInputsFromState(state.value);
        }
        if (state is FinancingError) {
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
              if (state is FinancingLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: LinearProgressIndicator(
                    color: styles.progressIndicatorColor,
                  ),
                ),
              InputFormsResultCard(
                label: 'Valor financiado (R\$)',
                hint: '0,00',
                controller: _initialValueController,
                inputFormatters: [DecimalInputFormatter()],
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 14, right: 10),
                  child: Icon(Icons.attach_money, color: styles.iconColor),
                ),
                onTap: () =>
                    financingCubit.calculate(_getFinancingFromInputs()),
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
                onTap: () =>
                    financingCubit.calculate(_getFinancingFromInputs()),
              ),
              SizedBox(height: AppSpacing.md + 2),
              InputFormsResultCard(
                label: 'Taxa de juros (% ao mês)',
                hint: '0,00',
                controller: _rateController,
                inputFormatters: [DecimalInputFormatter()],
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 14, right: 10),
                  child: Icon(Icons.percent, color: styles.iconColor),
                ),
                onTap: () =>
                    financingCubit.calculate(_getFinancingFromInputs()),
              ),
              SizedBox(height: AppSpacing.md + 2),
              InputFormsResultCard(
                label: 'Valor da prestação',
                hint: '0,00',
                controller: _finalValueController,
                inputFormatters: [DecimalInputFormatter()],
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 14, right: 10),
                  child: Icon(Icons.payments, color: styles.iconColor),
                ),
                onTap: () =>
                    financingCubit.calculate(_getFinancingFromInputs()),
              ),
              SizedBox(height: AppSpacing.lg),
              OptionsBottomForms(
                onCalculate: () =>
                    financingCubit.calculate(_getFinancingFromInputs()),
                onClear: _clearForm,
              ),
            ],
          ),
        );
      },
    );
  }
}