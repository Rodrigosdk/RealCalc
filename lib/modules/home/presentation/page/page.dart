import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:real_calc/core/routes/app_routes.dart';
import 'package:real_calc/core/themes/spacing.dart';
import 'package:real_calc/core/widgets/title_widget.dart';
import 'package:real_calc/modules/home/domain/enum/menu_card_variant.dart';
import '../../../../core/themes/extensions/home_page_theme.dart';
import '../components/menu_card.dart';
import '../components/metric_card.dart';
import '../cubit/greeting_cubit.dart';
import '../cubit/selic_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  BlocBuilder<GreetingCubit, String> _buildGreetingWidget(
    BuildContext context,
  ) {
    return BlocBuilder<GreetingCubit, String>(
      builder: (context, greeting) =>
          TitleWidget(title: greeting, subtitle: 'O que vamos calcular?', invert: true),
    );
  }

  BlocBuilder<SelicCubit, SelicState> _buildMetricCard(BuildContext context) {
    return BlocBuilder<SelicCubit, SelicState>(
      builder: (context, state) {
        if (state is SelicLoading || state is SelicInitial) {
          return const MetricCard.loading();
        }

        final metric = state.metric;
        if (state is SelicLoaded && metric != null) {
          return MetricCard.data(
            ratePercent: metric.anualRate,
            variationPercent: metric.variationPercent,
            sparklineData: metric.sparklineData,
            caption: 'Atualizada pelo Banco Central',
            onTap: BlocProvider.of<SelicCubit>(context).retry,
          );
        }

        return MetricCard.offline(
          ratePercent: metric?.anualRate,
          variationPercent: metric?.variationPercent,
          sparklineData: metric?.sparklineData ?? const [],
          caption: state is SelicError
              ? state.error.message
              : 'Não foi possível carregar a taxa Selic',
          onTap: BlocProvider.of<SelicCubit>(context).retry,
        );
      },
    );
  }

  Widget _buildOpitionForms(BuildContext context, HomePageTheme theme) {
    return Column(
      spacing: AppSpacing.md,
      children: [
        MenuCard(
          icon: Icons.account_balance,
          title: 'Financiamento',
          description: 'Prestações com juros compostos',
          cardColor: theme.cardColor,
          iconColor: theme.iconContainerColor,
          onTap: () => Modular.to.pushNamed(AppRoutes.financing),
          variant: MenuCardVariant.featured,
        ),
        SizedBox(
          height: 100,
          child: Row(
            children: [
              Expanded(
                child: MenuCard(
                  icon: Icons.account_balance,
                  title: 'Depósitos Regulares',
                  description: 'Prestações com juros compostos',
                  cardColor: theme.cardColor,
                  iconColor: theme.iconContainerColor,
                  onTap: () => Modular.to.pushNamed(AppRoutes.deposits),
                  variant: MenuCardVariant.standard,
                ),
              ),
              VerticalDivider(
                color: theme.lineColor,
                thickness: 1,
                width: AppSpacing.md,
              ),
              Expanded(
                child: MenuCard(
                  icon: Icons.bar_chart,
                  title: 'Valor Futuro',
                  description: 'Prestações com juros compostos',
                  cardColor: theme.cardColor,
                  iconColor: theme.iconContainerColor,
                  onTap: () => Modular.to.pushNamed(AppRoutes.futureValue),
                  variant: MenuCardVariant.standard,
                ),
              ),
            ],
          ),
        ),
        MenuCard(
          icon: Icons.trending_up,
          title: 'Correção de Valores',
          description: 'Atualize valores por índices de inflação',
          cardColor: theme.cardColor,
          iconColor: theme.iconContainerColor,
          onTap: null,
          variant: MenuCardVariant.disabled,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<HomePageTheme>()!;
    final spacing = 4;
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.xl,
            children: [
              SizedBox(height: AppSpacing.xs- spacing), 
              _buildGreetingWidget(context),
              _buildMetricCard(context),
              _buildOpitionForms(context, theme),
            ],
          ),
        ),
      ),
    );
  }
}
