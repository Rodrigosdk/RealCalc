import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_calc/core/themes/calculator_palette.dart';
import 'package:real_calc/core/themes/calculator_scope.dart';
import 'package:real_calc/core/utils/decimal_input_formatter.dart';

import '../../domain/enum/financial_calculation_target.dart';
import '../cubit/financing/financing_cubit.dart';
import '../cubit/forms/financing_form_cubit.dart';
import '../utils/financing_statement.dart';
import '../utils/result_summaries.dart';
import '../widgets/calculator_form_view.dart';

class FinancingPage extends StatelessWidget {
  static const title = 'Financiamento';

  static final fields = [
    CalculatorFieldConfig(
      target: FinancialCalculationTarget.initialValue,
      label: 'Valor financiado',
      prefix: 'R\$',
      hint: '0,00',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      formatters: [DecimalInputFormatter()],
    ),
    CalculatorFieldConfig(
      target: FinancialCalculationTarget.periods,
      label: 'Prazo',
      unit: 'meses',
      hint: '0',
      keyboardType: TextInputType.number,
      formatters: [FilteringTextInputFormatter.digitsOnly],
    ),
    CalculatorFieldConfig(
      target: FinancialCalculationTarget.interestRate,
      label: 'Taxa de juros',
      unit: '% a.m.',
      hint: '0,00',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      formatters: [DecimalInputFormatter()],
    ),
    CalculatorFieldConfig(
      target: FinancialCalculationTarget.finalValue,
      label: 'Prestação',
      prefix: 'R\$',
      secondLine: 'todo mês',
      hint: '0,00',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      formatters: [DecimalInputFormatter()],
    ),
  ];

  const FinancingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CalculatorScope(
      kind: CalculatorKind.financing,
      child: BlocConsumer<FinancingCubit, FinancingState>(
        listener: (context, state) {
          final formCubit = context.read<FinancingFormCubit>();
          if (state is FinancingCalculated) {
            formCubit.applyResult(state.value, state.calculatedField);
          } else if (state is FinancingError) {
            formCubit.invalidateCalculatedField();
          }
        },
        builder: (context, state) => CalculatorFormView(
          kind: CalculatorKind.financing,
          title: title,
          fields: fields,
          statement: financingStatement,
          missingMessage: financingMissingFieldsMessage,
          summary: financingResultSummary,
          onCalculate: context.read<FinancingCubit>().calculate,
          errorMessage: state is FinancingError
              ? state.message ?? 'Confira os valores.'
              : null,
        ),
      ),
    );
  }
}
