import 'package:flutter/material.dart';
import 'package:real_calc/core/widgets/app_icon.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:real_calc/core/routes/app_routes.dart';
import 'package:real_calc/core/themes/app_colors.dart';
import 'package:real_calc/core/themes/calculator_palette.dart';
import 'package:real_calc/core/themes/spacing.dart';
import 'package:real_calc/core/themes/text_styles.dart';
import 'package:real_calc/core/widgets/app_logo.dart';
import 'package:real_calc/core/widgets/calculator_band/calculator_band.dart';
import 'package:real_calc/core/widgets/theme_toggle_button.dart';

import '../components/calculator_list_item.dart';
import '../components/selic_band.dart';
import '../cubit/greeting_cubit.dart';
import '../cubit/selic_cubit.dart';

class HomePage extends StatelessWidget {
  static const footer =
      'Mesma metodologia da Calculadora do Cidadão, do Banco Central.';

  static const calculators = [
    (
      kind: CalculatorKind.financing,
      icon: AppIcons.bank,
      title: 'Financiamento',
      description: 'Prestação, prazo ou taxa',
      route: AppRoutes.financing,
    ),
    (
      kind: CalculatorKind.deposits,
      icon: AppIcons.piggyBank,
      title: 'Depósitos Regulares',
      description: 'Quanto você acumula todo mês',
      route: AppRoutes.deposits,
    ),
    (
      kind: CalculatorKind.futureValue,
      icon: AppIcons.trendingUp,
      title: 'Valor Futuro',
      description: 'Quanto rende um valor aplicado',
      route: AppRoutes.futureValue,
    ),
    (
      kind: CalculatorKind.correction,
      icon: AppIcons.cycle,
      title: 'Correção de Valores',
      description: 'Pela inflação, juros ou poupança',
      route: AppRoutes.correction,
    ),
  ];

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnnotatedRegion<SystemUiOverlayStyle>(
            value: CalculatorBand.statusBarStyle,
            child: ColoredBox(
              color: colors.bandHome,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    AppSpacing.sm,
                    AppSpacing.screen - 10,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Row(
                        children: [AppLogo(), Spacer(), ThemeToggleButton()],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: BlocBuilder<SelicCubit, SelicState>(
                          builder: (context, state) => SelicBand(
                            state: state,
                            onRetry: BlocProvider.of<SelicCubit>(context).retry,
                            onPeriodChanged: BlocProvider.of<SelicCubit>(
                              context,
                            ).changePeriod,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.lg,
                AppSpacing.screen,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BlocBuilder<GreetingCubit, String>(
                    builder: (context, greeting) => Text(
                      greeting,
                      style: AppTextStyles.body.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  Semantics(
                    header: true,
                    child: Text(
                      'O que vamos calcular hoje?',
                      style: AppTextStyles.screenTitle.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: colors.hairline)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final calculator in calculators)
                          CalculatorListItem(
                            kind: calculator.kind,
                            iconAsset: calculator.icon,
                            title: calculator.title,
                            description: calculator.description,
                            onTap: () => Modular.to.pushNamed(calculator.route),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    footer,
                    style: AppTextStyles.caption.copyWith(
                      color: colors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
