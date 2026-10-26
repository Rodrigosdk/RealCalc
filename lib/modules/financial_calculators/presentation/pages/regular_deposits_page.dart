import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_calc/core/themes/calculator_palette.dart';
import 'package:real_calc/core/themes/calculator_scope.dart';
import 'package:real_calc/core/utils/decimal_input_formatter.dart';

import '../../domain/enum/financial_calculation_target.dart';
import '../cubit/forms/financing_form_cubit.dart';
import '../cubit/regular_deposits/regular_deposits_cubit.dart';
import '../utils/deposits_statement.dart';
import '../utils/result_summaries.dart';
import '../widgets/calculator_form_view.dart';

class RegularDepositsPage extends StatelessWidget {
  static const title = 'Depósitos Regulares';

  static final fields = [
    CalculatorFieldConfig(
      target: FinancialCalculationTarget.initialValue,
      label: 'Depósito',
      prefix: 'R\$',
      secondLine: 'todo mês',
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
      label: 'Valor final',
      prefix: 'R\$',
      hint: '0,00',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      formatters: [DecimalInputFormatter()],
    ),
  ];

  const RegularDepositsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CalculatorScope(
      kind: CalculatorKind.deposits,
      child: BlocConsumer<RegularDepositsCubit, RegularDepositsState>(
        listener: (context, state) {
          final formCubit = context.read<FinancingFormCubit>();
          if (state is RegularDepositsCalculated) {
            formCubit.applyResult(state.value, state.calculatedField);
          } else if (state is RegularDepositsError) {
            formCubit.invalidateCalculatedField();
          }
        },
        builder: (context, state) => CalculatorFormView(
          kind: CalculatorKind.deposits,
          title: title,
          fields: fields,
          statement: depositsStatement,
          missingMessage: depositsMissingFieldsMessage,
          summary: regularDepositsResultSummary,
          onCalculate: context.read<RegularDepositsCubit>().calculate,
          errorMessage: state is RegularDepositsError
              ? state.message ?? 'Confira os valores.'
              : null,
        ),
      ),
    );
  }
}
