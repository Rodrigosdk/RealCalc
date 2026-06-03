import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  String? _errorMessage; // Apenas armazena o que vier do Cubit

  @override
  void dispose() {
    _initialValueController.dispose();
    _monthsController.dispose();
    _rateController.dispose();
    _finalValueController.dispose();
    super.dispose();
  }

  void _clearForm() {
    setState(() {
      _errorMessage = null;
    });
    _initialValueController.clear();
    _monthsController.clear();
    _rateController.clear();
    _finalValueController.clear();
  }

  void _updateInputsFromState(Financing financing) {
    _initialValueController.text = financing.initialValue > 0 ? financing.initialValue.toStringAsFixed(2) : '';
    _monthsController.text = financing.months > 0 ? financing.months.toString() : '';
    _rateController.text = financing.rate > 0 ? financing.rate.toStringAsFixed(2) : '';
    _finalValueController.text = financing.finalValue > 0 ? financing.finalValue.toStringAsFixed(2) : '';
  }

  Financing _getFinancingFromInputs() {
    return Financing(
      initialValue: double.tryParse(_initialValueController.text) ?? 0,
      months: int.tryParse(_monthsController.text) ?? 0,
      rate: double.tryParse(_rateController.text) ?? 0,
      finalValue: double.tryParse(_finalValueController.text) ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final financingCubit = BlocProvider.of<FinancingCubit>(context);
    
    return BlocConsumer<FinancingCubit, FinancingState>(
      listener: (context, state) {
        if (state is FinancingCalculated) {
          setState(() { _errorMessage = null; });
          _updateInputsFromState(state.value);
        }
        if (state is FinancingError) {
          setState(() {
            _errorMessage = state.message;
          });
        }
      },
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              spacing: 18,
              children: [
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
            
                if (state is FinancingLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator(color: Color(0xFF1E94F6)),
                  ),
            
                InputFormsResultCard(
                  label: 'Valor financiado (R\$)',
                  hint: '0,00',
                  controller: _initialValueController,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 14, right: 10),
                    child: Icon(Icons.attach_money, color: Color(0xFF1E94F6)),
                  ),
                  onTap: () => financingCubit.calculate(_getFinancingFromInputs()),
                ),
                InputFormsResultCard(
                  label: 'Prazo (meses)',
                  hint: '0',
                  controller: _monthsController,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 14, right: 10),
                    child: Icon(Icons.calendar_today, color: Color(0xFF1E94F6)),
                  ),
                  onTap: () => financingCubit.calculate(_getFinancingFromInputs()),
                ),
                InputFormsResultCard(
                  label: 'Taxa de juros (% ao mês)',
                  hint: '0,00',
                  controller: _rateController,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 14, right: 10),
                    child: Icon(Icons.percent, color: Color(0xFF1E94F6)),
                  ),
                  onTap: () => financingCubit.calculate(_getFinancingFromInputs()),
                ),
                InputFormsResultCard(
                  label: 'Valor da prestação',
                  hint: '0,00',
                  controller: _finalValueController,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 14, right: 10),
                    child: Icon(Icons.payments, color: Color(0xFF1E94F6)),
                  ),
                  onTap: () => financingCubit.calculate(_getFinancingFromInputs()),
                ),
                
                OptionsBottomForms(
                  onCalculate: () => financingCubit.calculate(_getFinancingFromInputs()),
                  onClear: _clearForm,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
