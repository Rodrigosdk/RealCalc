import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_calc/core/themes/calculator_palette.dart';
import 'package:real_calc/core/themes/spacing.dart';
import 'package:real_calc/core/widgets/bottom_action_bar.dart';
import 'package:real_calc/core/widgets/calculator_band/band_statement.dart';
import 'package:real_calc/core/widgets/calculator_band/calculator_band.dart';
import 'package:real_calc/core/widgets/field_list/field_list.dart';
import 'package:real_calc/core/widgets/field_list/field_row.dart';
import 'package:real_calc/core/widgets/form_notice.dart';
import 'package:real_calc/core/widgets/help_sheet/help_sheet.dart';
import 'package:real_calc/core/widgets/result_details/result_details.dart';
import 'package:real_calc/core/widgets/result_details/result_summary.dart';

import '../../domain/entities/financial_calculation.dart';
import '../../domain/enum/financial_calculation_target.dart';
import '../cubit/forms/financing_form_cubit.dart';

class CalculatorFieldConfig {
  final FinancialCalculationTarget target;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter> formatters;
  final String? prefix;
  final String? unit;
  final String? secondLine;

  const CalculatorFieldConfig({
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

typedef StatementBuilder =
    BandStatement Function({
      required Set<FinancialCalculationTarget> emptyFields,
      required FinancialCalculation values,
      FinancialCalculationTarget? calculatedField,
    });

class CalculatorFormView extends StatelessWidget {
  final CalculatorKind kind;
  final String title;
  final List<CalculatorFieldConfig> fields;
  final StatementBuilder statement;
  final String Function(Set<FinancialCalculationTarget>) missingMessage;
  final ResultSummary Function(FinancialCalculation) summary;
  final ValueChanged<FinancialCalculation> onCalculate;
  final String? errorMessage;

  const CalculatorFormView({
    super.key,
    required this.kind,
    required this.title,
    required this.fields,
    required this.statement,
    required this.missingMessage,
    required this.summary,
    required this.onCalculate,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final formCubit = context.watch<FinancingFormCubit>();
    final formState = formCubit.state;

    final emptyFields = {
      for (final field in FinancialCalculationTarget.values)
        if (formCubit.controllerFor(field).text.trim().isEmpty) field,
    };
    final calculatedField = formState.calculatedField;
    final values = formCubit.financing;
    final filled =
        FinancialCalculationTarget.values.length - emptyFields.length;

    void calculate() {
      if (formCubit.state.canCalculate) onCalculate(formCubit.financing);
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
            title: title,
            statement: statement(
              emptyFields: emptyFields,
              values: values,
              calculatedField: calculatedField,
            ),
            onHelp: () => showHelpSheet(context, kind),
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
                      for (final field in fields)
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
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: FormNotice(
                        title: 'Não foi possível calcular',
                        message: errorMessage!,
                        isError: true,
                      ),
                    )
                  else if (filled > 0 && filled < 3)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: FormNotice(
                        title: 'Faltam dados para calcular',
                        message: missingMessage(emptyFields),
                      ),
                    ),
                  if (calculatedField != null)
                    ResultDetails(summary: summary(values)),
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
