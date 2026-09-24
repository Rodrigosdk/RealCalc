import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_calc/core/themes/spacing.dart';
import 'package:real_calc/core/widgets/page_header.dart';
import 'package:real_calc/core/widgets/title_widget.dart';
import 'package:real_calc/modules/financial_calculators/presentation/models/field_spec.dart';
import 'package:real_calc/core/widgets/help_card.dart';

import '../../../../core/utils/decimal_input_formatter.dart';
import '../../domain/enum/financial_calculation_target.dart';
import '../../../../core/widgets/types/input_field_state.dart';
import '../cubit/forms/financing_form_cubit.dart';
import '../cubit/future_value/future_value_cubit.dart';
import '../widgets/forms_view.dart';

class FutureValuePage extends StatelessWidget {
  static final List<FieldSpec<FinancialCalculationTarget>> _fieldSpecs = [
    FieldSpec(
      field: FinancialCalculationTarget.initialValue,
      label: 'Capital (R\$)',
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
      label: 'Valor final',
      hint: '0,00',
      icon: Icons.payments,
      formatters: [DecimalInputFormatter()],
    ),
  ];

  const FutureValuePage({super.key});

  BlocListener<FutureValueCubit, FutureValueState> _buildForms() {
    return BlocListener<FutureValueCubit, FutureValueState>(
      listener: (context, state) {
        final formCubit = context.read<FinancingFormCubit>();
        if (state is FutureValueCalculated) {
          formCubit.applyResult(state.value, state.calculatedField);
        } else if (state is FutureValueError) {
          formCubit.invalidateCalculatedField();
        }
      },
      child: BlocBuilder<FutureValueCubit, FutureValueState>(
        builder: (context, financingState) {
          final formCubit = context.watch<FinancingFormCubit>();
          final formState = formCubit.state;

          void calculate() {
            if (formState.canCalculate) {
              context.read<FutureValueCubit>().calculate(formCubit.financing);
            }
          }

          return FormsView<FinancialCalculationTarget>(
            fieldSpecs: _fieldSpecs,
            controllerFor: formCubit.controllerFor,
            stateOf: formState.stateOf,
            isLoading: financingState is FutureValueLoading,
            errorMessage: financingState is FutureValueError
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
      appBar: PageHeader(title: 'Valor Futuro'),
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
                title: 'Valor Futuro',
                subtitle: 'Calcule o valor futuro do seu capital.',
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
