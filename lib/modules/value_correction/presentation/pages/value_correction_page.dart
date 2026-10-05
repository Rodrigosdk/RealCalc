import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/themes/extensions/financing_forms_theme.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../core/utils/date_input_formatter.dart';
import '../../../../core/utils/decimal_input_formatter.dart';
import '../../../../core/utils/month_year_input_formatter.dart';
import '../../../../core/widgets/help_card.dart';
import '../../../../core/widgets/input_forms_result_card.dart';
import '../../../../core/widgets/options_bottom_forms.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/title_widget.dart';
import '../../../../core/widgets/types/input_field_state.dart';
import '../../domain/enum/correction_index.dart';
import '../../domain/enum/date_granularity.dart';
import '../../domain/entites/value_correction.dart';
import '../cubit/value_correction/value_correction_cubit.dart';
import '../cubit/value_correction/value_correction_state.dart';
import '../../presentation/cubit/forms/value_correction_form_cubit.dart';
import '../../presentation/cubit/forms/value_correction_form_state.dart';

class ValueCorrectionPage extends StatelessWidget {
  const ValueCorrectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formCubit = context.watch<ValueCorrectionFormCubit>();
    final formState = formCubit.state;
    final calculationState = context.watch<ValueCorrectionCubit>().state;
    final formsTheme = Theme.of(context).extension<FinancingFormsTheme>()!;
    final dateInputFormatter =
        formState.dateGranularity == DateGranularity.month
            ? MonthYearInputFormatter()
            : DateInputFormatter();
    final indexController = TextEditingController(
      text: formState.index?.label ?? CorrectionIndex.ipca.label,
    );

    void calculate() {
      if (!formState.canCalculate || formState.index == null) return;

      context.read<ValueCorrectionCubit>().calculate(
        index: formState.index!,
        initialDate: formCubit.initialDate.text,
        finalDate: formCubit.finalDate.text,
        percentage: formCubit.percentage.text,
        value: formCubit.value.text,
      );
    }

    void clear() {
      formCubit.clear();
      context.read<ValueCorrectionCubit>().reset();
    }

    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Scaffold(
        appBar: const PageHeader(title: 'Correção de Valores'),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md + 4,
              vertical: AppSpacing.md + 4,
            ),
            child: Column(
              spacing: AppSpacing.md,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TitleWidget(
                  title: 'Correção de Valores',
                  subtitle:
                      'Atualize um valor por índices de inflação, juros ou poupança.',
                ),
                const HelpCard(
                  message:
                      'Escolha o índice e o período. Sem informar o valor, mostraremos só o fator de correção.',
                ),
                InputFormsResultCard(
                  label: 'Índice de correção',
                  hint: formState.index?.label ?? CorrectionIndex.ipca.label,
                  icon: Icons.trending_up,
                  controller: indexController,
                  state: InputFieldState.neutral,
                  readOnly: true,
                  onTap: () {},
                ),
                Row(
                  spacing: AppSpacing.sm,
                  children: [
                    Expanded(
                      child: InputFormsResultCard(
                        label: 'Data inicial',
                        hint: '01/2023',
                        icon: Icons.calendar_today,
                        controller: formCubit.initialDate,
                        inputFormatters: [dateInputFormatter],
                        state: formState.fieldErrors[ValueCorrectionField.initialDate] != null
                            ? InputFieldState.error
                            : InputFieldState.neutral,
                        validator: (_) =>
                            formState.fieldErrors[ValueCorrectionField.initialDate],
                      ),
                    ),
                    Expanded(
                      child: InputFormsResultCard(
                        label: 'Data final',
                        hint: '12/2025',
                        icon: Icons.calendar_today,
                        controller: formCubit.finalDate,
                        inputFormatters: [dateInputFormatter],
                        state: formState.fieldErrors[ValueCorrectionField.finalDate] != null
                            ? InputFieldState.error
                            : InputFieldState.neutral,
                        validator: (_) =>
                            formState.fieldErrors[ValueCorrectionField.finalDate],
                      ),
                    ),
                  ],
                ),
                if (formState.showsCurrencyWarning)
                  _CurrencyWarningBanner(formsTheme: formsTheme),
                if (formState.showsPercentage)
                  InputFormsResultCard(
                    label: 'Percentual',
                    hint: '0,00',
                    icon: Icons.percent,
                    controller: formCubit.percentage,
                    inputFormatters: [DecimalInputFormatter()],
                    state: formState.fieldErrors[ValueCorrectionField.percentage] != null
                        ? InputFieldState.error
                        : InputFieldState.neutral,
                    validator: (_) =>
                        formState.fieldErrors[ValueCorrectionField.percentage],
                  ),
                InputFormsResultCard(
                  label: 'Valor a ser corrigido (R\$)',
                  hint: '5.000,00',
                  icon: Icons.attach_money,
                  controller: formCubit.value,
                  inputFormatters: [DecimalInputFormatter()],
                  state: formState.fieldErrors[ValueCorrectionField.value] != null
                      ? InputFieldState.error
                      : InputFieldState.neutral,
                  trailingBadge: 'opcional',
                  validator: (_) => formState.fieldErrors[ValueCorrectionField.value],
                ),
                if (calculationState is ValueCorrectionLoading)
                  const LinearProgressIndicator(),
                if (calculationState is ValueCorrectionError)
                  Text(
                    calculationState.message,
                    style: formsTheme.errorTextStyle,
                  ),
                OptionsBottomForms(
                  onCalculate: formState.canCalculate ? calculate : null,
                  onClear: clear,
                  calculateLabel: 'Corrigir valor',
                ),
                if (calculationState is ValueCorrectionCalculated)
                  _CorrectionResultCard(result: calculationState.result),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CorrectionResultCard extends StatelessWidget {
  final ValueCorrection result;

  const _CorrectionResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resultado da correção', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text('Fator de correção: ${result.factor.toStringAsFixed(6)}'),
            Text('Variação acumulada: ${result.variation.toStringAsFixed(2)}%'),
            if (result.adjustedValue != null)
              Text('Valor corrigido: ${currencyFormat.format(result.adjustedValue)}'),
          ],
        ),
      ),
    );
  }
}

class _CurrencyWarningBanner extends StatelessWidget {
  final FinancingFormsTheme formsTheme;

  const _CurrencyWarningBanner({required this.formsTheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: formsTheme.errorContainerPadding,
      decoration: BoxDecoration(
        color: formsTheme.errorBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: formsTheme.errorBorderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: formsTheme.errorBorderColor,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Atenção: antes de 07/1994, o valor deve ser informado na moeda vigente no início do período.',
              style: formsTheme.errorTextStyle,
            ),
          ),
        ],
      ),
    );
  }
}
