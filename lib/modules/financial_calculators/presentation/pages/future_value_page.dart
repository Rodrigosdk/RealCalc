import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_calc/core/services/result_sharer.dart';
import 'package:real_calc/core/services/share_plus_result_sharer.dart';
import 'package:real_calc/core/themes/calculator_palette.dart';
import 'package:real_calc/core/themes/calculator_scope.dart';
import 'package:real_calc/core/utils/decimal_input_formatter.dart';

import '../../domain/enum/financial_calculation_target.dart';
import '../cubit/forms/financing_form_cubit.dart';
import '../cubit/future_value/future_value_cubit.dart';
import '../utils/future_value_statement.dart';
import '../utils/result_summaries.dart';
import '../utils/share_texts.dart';
import '../widgets/calculator_form_view.dart';

class FutureValuePage extends StatelessWidget {
  static const title = 'Valor Futuro';

  static final fields = [
    CalculatorFieldConfig(
      target: FinancialCalculationTarget.initialValue,
      label: 'Valor aplicado',
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
      label: 'Valor futuro',
      prefix: 'R\$',
      hint: '0,00',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      formatters: [DecimalInputFormatter()],
    ),
  ];

  final ResultSharer sharer;

  const FutureValuePage({
    super.key,
    this.sharer = const SharePlusResultSharer(),
  });

  @override
  Widget build(BuildContext context) {
    return CalculatorScope(
      kind: CalculatorKind.futureValue,
      child: BlocConsumer<FutureValueCubit, FutureValueState>(
        listener: (context, state) {
          final formCubit = context.read<FinancingFormCubit>();
          if (state is FutureValueCalculated) {
            formCubit.applyResult(state.value, state.calculatedField);
          } else if (state is FutureValueError) {
            formCubit.invalidateCalculatedField();
          }
        },
        builder: (context, state) => CalculatorFormView(
          kind: CalculatorKind.futureValue,
          title: title,
          fields: fields,
          statement: futureValueStatement,
          missingMessage: futureValueMissingFieldsMessage,
          summary: futureValueResultSummary,
          onCalculate: context.read<FutureValueCubit>().calculate,
          shareText: futureValueShareText,
          sharer: sharer,
          errorMessage: state is FutureValueError
              ? state.message ?? 'Confira os valores.'
              : null,
        ),
      ),
    );
  }
}
