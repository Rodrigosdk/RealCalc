import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:real_calc/core/themes/spacing.dart';
import 'package:real_calc/core/widgets/page_header.dart';
import 'package:real_calc/core/widgets/title_widget.dart';
import 'package:real_calc/modules/financial_calculators/presentation/models/field_spec.dart';
import 'package:real_calc/modules/financial_calculators/presentation/widgets/forms_view.dart';
import 'package:real_calc/core/widgets/help_card.dart';

import '../../../../core/utils/decimal_input_formatter.dart';
import '../../domain/enum/financial_calculation_target.dart';
import '../../../../core/widgets/types/input_field_state.dart';
import '../cubit/financing/financing_cubit.dart';
import '../cubit/forms/financing_form_cubit.dart';

class FinancingPage extends StatelessWidget {
  static final List<FieldSpec<FinancialCalculationTarget>> _fieldSpecs = [
    FieldSpec(
      field: FinancialCalculationTarget.initialValue,
      label: 'Valor financiado (R\$)',
      hint: '0,00',
      icon: Icons.attach_money,
      formatters: [DecimalInputFormatter()],
    ),
    FieldSpec(
      field: FinancialCalculationTarget.periods,
      label: 'Prazo (meses)',
      hint: '0',
      icon: Icons.calendar_today,
      formatters: [FilteringTextInputFormatter.digitsOnly],
    ),
    FieldSpec(
      field: FinancialCalculationTarget.interestRate,
      label: 'Taxa de juros (% ao mês)',
      hint: '0,00',
      icon: Icons.percent,
      formatters: [DecimalInputFormatter()],
    ),
    FieldSpec(
      field: FinancialCalculationTarget.finalValue,
      label: 'Valor da prestação',
      hint: '0,00',
      icon: Icons.payments,
      formatters: [DecimalInputFormatter()],
    ),
  ];

  const FinancingPage({super.key});

  BlocListener<FinancingCubit, FinancingState> _buildForms() {
    return BlocListener<FinancingCubit, FinancingState>(
      listener: (context, state) {
        final formCubit = context.read<FinancingFormCubit>();
        if (state is FinancingCalculated) {
          formCubit.applyResult(state.value, state.calculatedField);
        } else if (state is FinancingError) {
          formCubit.invalidateCalculatedField();
        }
      },
      child: BlocBuilder<FinancingCubit, FinancingState>(
        builder: (context, financingState) {
          final formCubit = context.watch<FinancingFormCubit>();
          final formState = formCubit.state;

          void calculate() {
            if (formState.canCalculate) {
              context.read<FinancingCubit>().calculate(formCubit.financing);
            }
          }

          return FormsView<FinancialCalculationTarget>(
            fieldSpecs: _fieldSpecs,
            controllerFor: formCubit.controllerFor,
            stateOf: formState.stateOf,
            isLoading: financingState is FinancingLoading,
            errorMessage: financingState is FinancingError
                ? financingState.message ?? 'Erro ao calcular.'
                : null,
            onCalculate: calculate,
            onClear: formCubit.clear,
            onFieldTap: (field) {
              if (formState.stateOf(field) == InputFieldState.highlighted) {
                calculate();
              }
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PageHeader(title: 'Financiamento'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md + 4,
            vertical: AppSpacing.md + 4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.lg,
            children: [
              const TitleWidget(
                title: 'Financiamento',
                subtitle: 'Calcule o valor da prestação do seu financiamento.',
              ),
              const HelpCard(
                message:
                    'Preencha 3 campos e toque no 4° para calcular automaticamente',
              ),
              _buildForms(),
            ],
          ),
        ),
      ),
    );
  }
}