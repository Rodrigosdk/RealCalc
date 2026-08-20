import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_calc/core/themes/spacing.dart';
import 'package:real_calc/core/utils/decimal_input_formatter.dart';
import 'package:real_calc/core/widgets/options_bottom_forms.dart';
import 'package:real_calc/modules/financing/presentation/widgets/input_forms_result_card.dart';
import 'package:real_calc/modules/regular_deposits/domain/entities/regular_deposit.dart';
import '../cubit/regular_deposits_cubit.dart';

class RegularDepositsForms extends StatefulWidget {
  const RegularDepositsForms({super.key});

  @override
  State<RegularDepositsForms> createState() => _RegularDepositsFormsState();
}

class _RegularDepositsFormsState extends State<RegularDepositsForms> {
  final _formKey = GlobalKey<FormState>();
  final _depositAmountController = TextEditingController();
  final _monthsController = TextEditingController();
  final _rateController = TextEditingController();
  final _finalValueController = TextEditingController();

  String? _errorMessage;

  @override
  void dispose() {
    _depositAmountController.dispose();
    _monthsController.dispose();
    _rateController.dispose();
    _finalValueController.dispose();
    super.dispose();
  }

  void _clearForm() {
    setState(() => _errorMessage = null);
    _depositAmountController.clear();
    _monthsController.clear();
    _rateController.clear();
    _finalValueController.clear();
  }

  void _updateInputsFromState(RegularDeposit deposit) {
    final formatter = DecimalInputFormatter();

    _depositAmountController.value = deposit.depositAmount > 0
        ? formatter.formatEditUpdate(
            TextEditingValue.empty,
            TextEditingValue(
              text: deposit.depositAmount.toStringAsFixed(2).replaceAll('.', ''),
            ),
          )
        : TextEditingValue.empty;

    _monthsController.text = deposit.months > 0 ? deposit.months.toString() : '';

    _rateController.value = deposit.rate > 0
        ? formatter.formatEditUpdate(
            TextEditingValue.empty,
            TextEditingValue(
              text: deposit.rate.toStringAsFixed(2).replaceAll('.', ''),
            ),
          )
        : TextEditingValue.empty;

    _finalValueController.value = deposit.finalValue > 0
        ? formatter.formatEditUpdate(
            TextEditingValue.empty,
            TextEditingValue(
              text: deposit.finalValue.toStringAsFixed(2).replaceAll('.', ''),
            ),
          )
        : TextEditingValue.empty;
  }

  double _parseFormattedDouble(String text) {
    final cleaned = text.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0;
  }

  RegularDeposit _getRegularDepositFromInputs() {
    return RegularDeposit(
      depositAmount: _parseFormattedDouble(_depositAmountController.text),
      months: int.tryParse(_monthsController.text) ?? 0,
      rate: _parseFormattedDouble(_rateController.text),
      finalValue: _parseFormattedDouble(_finalValueController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<RegularDepositsCubit>(context);

    return BlocConsumer<RegularDepositsCubit, RegularDepositsState>(
      listener: (context, state) {
        if (state is RegularDepositsCalculated) {
          setState(() => _errorMessage = null);
          _updateInputsFromState(state.value);
        }
        if (state is RegularDepositsError) {
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              if (state is RegularDepositsLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: LinearProgressIndicator(),
                ),
              InputFormsResultCard(
                label: 'Valor do depósito (R\$)',
                hint: '0,00',
                controller: _depositAmountController,
                inputFormatters: [DecimalInputFormatter()],
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 14, right: 10),
                  child: Icon(Icons.savings_outlined),
                ),
                onTap: () => cubit.calculate(_getRegularDepositFromInputs()),
              ),
              SizedBox(height: AppSpacing.md + 2),
              InputFormsResultCard(
                label: 'Prazo (meses)',
                hint: '0',
                controller: _monthsController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 14, right: 10),
                  child: Icon(Icons.calendar_today_outlined),
                ),
                onTap: () => cubit.calculate(_getRegularDepositFromInputs()),
              ),
              SizedBox(height: AppSpacing.md + 2),
              InputFormsResultCard(
                label: 'Taxa de juros (% ao mês)',
                hint: '0,00',
                controller: _rateController,
                inputFormatters: [DecimalInputFormatter()],
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 14, right: 10),
                  child: Icon(Icons.percent),
                ),
                onTap: () => cubit.calculate(_getRegularDepositFromInputs()),
              ),
              SizedBox(height: AppSpacing.md + 2),
              InputFormsResultCard(
                label: 'Valor final',
                hint: '0,00',
                controller: _finalValueController,
                inputFormatters: [DecimalInputFormatter()],
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 14, right: 10),
                  child: Icon(Icons.wallet_outlined),
                ),
                onTap: () => cubit.calculate(_getRegularDepositFromInputs()),
              ),
              SizedBox(height: AppSpacing.lg),
              OptionsBottomForms(
                onCalculate: () => cubit.calculate(_getRegularDepositFromInputs()),
                onClear: _clearForm,
              ),
            ],
          ),
        );
      },
    );
  }
}
