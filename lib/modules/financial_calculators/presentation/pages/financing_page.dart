import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_calc/core/themes/calculator_palette.dart';
import 'package:real_calc/core/themes/calculator_scope.dart';
import 'package:real_calc/core/themes/spacing.dart';
import 'package:real_calc/core/utils/decimal_input_formatter.dart';
import 'package:real_calc/core/widgets/bottom_action_bar.dart';
import 'package:real_calc/core/widgets/calculator_band/calculator_band.dart';
import 'package:real_calc/core/widgets/field_list/field_list.dart';
import 'package:real_calc/core/widgets/field_list/field_row.dart';
import 'package:real_calc/core/widgets/form_notice.dart';
import 'package:real_calc/core/widgets/help_sheet/help_sheet.dart';
import 'package:real_calc/core/widgets/result_details/result_details.dart';

import '../../domain/enum/financial_calculation_target.dart';
import '../cubit/financing/financing_cubit.dart';
import '../cubit/forms/financing_form_cubit.dart';
import '../utils/financing_statement.dart';
import '../utils/result_summaries.dart';

class _FieldConfig {
  final FinancialCalculationTarget target;
  final String label;
  final String? prefix;
  final String? unit;
  final String? secondLine;
  final String hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter> formatters;

  const _FieldConfig({
    required this.target,
    required this.label,
    required this.hint,
    required this.keyboardType,
    required this.formatters,
    this.prefix,
    this.unit,
    this.secondLine,
  });
}

class FinancingPage extends StatelessWidget {
  static const title = 'Financiamento';

  static final _fields = [
    _FieldConfig(
      target: FinancialCalculationTarget.initialValue,
      label: 'Valor financiado',
      prefix: 'R\$',
      hint: '0,00',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      formatters: [DecimalInputFormatter()],
    ),
    _FieldConfig(
      target: FinancialCalculationTarget.periods,
      label: 'Prazo',
      unit: 'meses',
      hint: '0',
      keyboardType: TextInputType.number,
      formatters: [FilteringTextInputFormatter.digitsOnly],
    ),
    _FieldConfig(
      target: FinancialCalculationTarget.interestRate,
      label: 'Taxa de juros',
      unit: '% a.m.',
      hint: '0,00',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      formatters: [DecimalInputFormatter()],
    ),
    _FieldConfig(
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
      child: BlocListener<FinancingCubit, FinancingState>(
        listener: (context, state) {
          final formCubit = context.read<FinancingFormCubit>();
          if (state is FinancingCalculated) {
            formCubit.applyResult(state.value, state.calculatedField);
          } else if (state is FinancingError) {
            formCubit.invalidateCalculatedField();
          }
        },
        child: const _FinancingView(),
      ),
    );
  }
}

class _FinancingView extends StatelessWidget {
  const _FinancingView();

  @override
  Widget build(BuildContext context) {
    final formCubit = context.watch<FinancingFormCubit>();
    final formState = formCubit.state;
    final financingState = context.watch<FinancingCubit>().state;

    final emptyFields = {
      for (final field in FinancialCalculationTarget.values)
        if (formCubit.controllerFor(field).text.trim().isEmpty) field,
    };
    final calculatedField = formState.calculatedField;
    final values = formCubit.financing;
    final filled =
        FinancialCalculationTarget.values.length - emptyFields.length;
    final error = financingState is FinancingError ? financingState : null;

    void calculate() {
      if (formCubit.state.canCalculate) {
        context.read<FinancingCubit>().calculate(formCubit.financing);
      }
    }

    void clear() {
      final snapshot = {
        for (final field in FinancialCalculationTarget.values)
          field: formCubit.controllerFor(field).text,
      };
      final previouslyCalculated = formCubit.state.calculatedField;
      FocusScope.of(context).unfocus();
      formCubit.clear();
      showFieldsClearedSnackBar(
        context,
        onUndo: () {
          for (final MapEntry(key: field, value: text) in snapshot.entries) {
            if (field != previouslyCalculated) {
              formCubit.controllerFor(field).text = text;
            }
          }
          if (previouslyCalculated != null) calculate();
        },
      );
    }

    return Scaffold(
      body: Column(
        children: [
          CalculatorBand(
            title: FinancingPage.title,
            statement: financingStatement(
              emptyFields: emptyFields,
              values: values,
              calculatedField: calculatedField,
            ),
            onHelp: () => showHelpSheet(context, CalculatorKind.financing),
            onClear: clear,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.sm,
                AppSpacing.screen,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FieldList(
                    children: [
                      for (final field in FinancingPage._fields)
                        FieldRow(
                          key: ValueKey(field.target),
                          label: field.label,
                          controller: formCubit.controllerFor(field.target),
                          state: formState.stateOf(field.target),
                          prefix: field.prefix,
                          unit: field.unit,
                          secondLine: field.secondLine,
                          hint: field.hint,
                          keyboardType: field.keyboardType,
                          inputFormatters: field.formatters,
                          onCalculate: calculate,
                        ),
                    ],
                  ),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: FormNotice(
                        title: 'Não foi possível calcular',
                        message: error.message ?? 'Confira os valores.',
                        isError: true,
                      ),
                    )
                  else if (filled > 0 && filled < 3)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: FormNotice(
                        title: 'Faltam dados para calcular',
                        message: financingMissingFieldsMessage(emptyFields),
                      ),
                    ),
                  if (calculatedField != null)
                    ResultDetails(summary: financingResultSummary(values)),
                ],
              ),
            ),
          ),
          BottomActionBar(
            primaryLabel: 'Calcular',
            onPrimary: formState.canCalculate ? calculate : null,
          ),
        ],
      ),
    );
  }
}
