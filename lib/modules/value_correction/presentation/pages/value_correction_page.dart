import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart' as modular;

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
import '../../../../core/widgets/error_banner.dart';
import '../../../../core/widgets/warning_banner.dart';
import '../../../../core/routes/app_routes.dart';
import '../../domain/enum/correction_index.dart';
import '../../domain/enum/date_granularity.dart';
import '../cubit/value_correction/value_correction_cubit.dart';
import '../cubit/value_correction/value_correction_state.dart';
import '../../presentation/cubit/forms/value_correction_form_cubit.dart';
import '../../presentation/cubit/forms/value_correction_form_state.dart';
import '../widgets/correction_index_picker.dart';

class ValueCorrectionPage extends StatelessWidget {
  const ValueCorrectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formCubit = WatchContext(context).watch<ValueCorrectionFormCubit>();
    final formState = formCubit.state;
    final calculationState = WatchContext(
      context,
    ).watch<ValueCorrectionCubit>().state;

    final dateInputFormatter =
        formState.dateGranularity == DateGranularity.month
        ? MonthYearInputFormatter()
        : DateInputFormatter();
    final indexController = TextEditingController(
      text: formState.index?.label ?? CorrectionIndex.ipca.label,
    );

    void runCalculation(CorrectionIndex index) {
      ReadContext(context).read<ValueCorrectionCubit>().calculate(
        index: index,
        initialDate: formCubit.initialDate.text,
        finalDate: formCubit.finalDate.text,
        percentage: formCubit.percentage.text,
        value: formCubit.value.text,
      );
    }

    void calculate() {
      final currentFormState = formCubit.state;
      final index = currentFormState.index;
      if (!currentFormState.canCalculate || index == null) return;
      runCalculation(index);
    }

    void retryCalculation() {
      final index = formCubit.state.index;
      if (index == null) return;
      runCalculation(index);
    }

    void clear() {
      formCubit.clear();
      ReadContext(context).read<ValueCorrectionCubit>().reset();
    }

    void openIndexPicker() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) {
          return CorrectionIndexPicker(
            selectedIndex: formState.index,
            onSelected: (index) {
              formCubit.setIndex(index);
            },
          );
        },
      );
    }

    return BlocListener<ValueCorrectionCubit, ValueCorrectionState>(
      listener: (context, state) {
        if (state is ValueCorrectionCalculated) {
          modular.Modular.to.pushNamed(
            AppRoutes.correctionResult,
            arguments: state.result,
          );
        }
      },
      child: Form(
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
                    onTap: openIndexPicker,
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
                          state:
                              formState.fieldErrors[ValueCorrectionField
                                      .initialDate] !=
                                  null
                              ? InputFieldState.error
                              : InputFieldState.neutral,
                          validator: (_) => formState
                              .fieldErrors[ValueCorrectionField.initialDate],
                        ),
                      ),
                      Expanded(
                        child: InputFormsResultCard(
                          label: 'Data final',
                          hint: '12/2025',
                          icon: Icons.calendar_today,
                          controller: formCubit.finalDate,
                          inputFormatters: [dateInputFormatter],
                          state:
                              formState.fieldErrors[ValueCorrectionField
                                      .finalDate] !=
                                  null
                              ? InputFieldState.error
                              : InputFieldState.neutral,
                          validator: (_) => formState
                              .fieldErrors[ValueCorrectionField.finalDate],
                        ),
                      ),
                    ],
                  ),
                  if (formState.warningBannerMessage.isNotEmpty)
                    WarningBanner(message: formState.warningBannerMessage),
                  if (formState.showsPercentage)
                    InputFormsResultCard(
                      label: 'Percentual',
                      hint: '0,00',
                      icon: Icons.percent,
                      controller: formCubit.percentage,
                      inputFormatters: [DecimalInputFormatter()],
                      state:
                          formState.fieldErrors[ValueCorrectionField
                                  .percentage] !=
                              null
                          ? InputFieldState.error
                          : InputFieldState.neutral,
                      validator: (_) => formState
                          .fieldErrors[ValueCorrectionField.percentage],
                    ),
                  InputFormsResultCard(
                    label: 'Valor a ser corrigido (R\$)',
                    hint: '5.000,00',
                    icon: Icons.attach_money,
                    controller: formCubit.value,
                    inputFormatters: [DecimalInputFormatter()],
                    state:
                        formState.fieldErrors[ValueCorrectionField.value] !=
                            null
                        ? InputFieldState.error
                        : InputFieldState.neutral,
                    trailingBadge: 'opcional',
                    validator: (_) =>
                        formState.fieldErrors[ValueCorrectionField.value],
                  ),
                  if (calculationState is ValueCorrectionLoading)
                    const LinearProgressIndicator(),
                  if (calculationState is ValueCorrectionError)
                    ErrorBanner(
                      message: calculationState.message,
                      onRetry: retryCalculation,
                    ),
                  OptionsBottomForms(
                    onCalculate: formState.canCalculate ? calculate : null,
                    onClear: clear,
                    calculateLabel: 'Corrigir valor',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
