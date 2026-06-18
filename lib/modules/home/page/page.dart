import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:real_calc/core/routes/app_routes.dart';
import 'package:real_calc/core/themes/spacing.dart';
import 'package:real_calc/core/widgets/title_widget.dart';
import '../../../core/themes/extensions/home_page_theme.dart';
import '../components/highlight_card.dart';
import '../components/menu_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<HomePageTheme>()!;

    final funcinalidades = [
      {
        'icon': Icons.trending_up,
        'title': 'Correção de Valores',
        'description': 'Atualize valores por índices de inflação',
        'onTap': null,
      },
      {
        'icon': Icons.account_balance,
        'title': 'Financiamento',
        'description': 'Prestações fixas com juros compostos',
        'onTap': () => Modular.to.pushNamed(AppRoutes.financing),
      },
      {
        'icon': Icons.savings,
        'title': 'Depósitos Regulares',
        'description': 'Aplicação mensal com rendimentos',
        'onTap': null,
      },
      {
        'icon': Icons.bar_chart,
        'title': 'Valor Futuro',
        'description': 'Calcule o capital ao final do prazo',
        'onTap': null,
      },
    ];

    final double larguraMaximaDoCard = MediaQuery.of(context).size.width > 600
        ? 180
        : (MediaQuery.of(context).size.width - 64) / 3;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: theme.iconContainerColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.primaryBlue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      Icons.calculate,
                      color: theme.primaryBlue,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm + 4),
                  Text('RealCalc', style: theme.appNameStyle),
                ],
              ),
              SizedBox(height: AppSpacing.xl),
              TitleWidget(
                title: 'Olá, Cidadão',
                subtitle: 'Qual cálculo deseja realizar hoje?',
              ),
              SizedBox(height: AppSpacing.xl),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: funcinalidades.length,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: larguraMaximaDoCard,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  final item = funcinalidades[index];
                  return MenuCard(
                    icon: item['icon'] as IconData,
                    title: item['title'] as String,
                    description: item['description'] as String,
                    cardColor: theme.cardColor,
                    iconColor: theme.primaryBlue,
                    onTap: item['onTap'] as VoidCallback?,
                  );
                },
              ),
              SizedBox(height: AppSpacing.lg),
              HighlightCard(),
              SizedBox(height: AppSpacing.lg),
              Text(
                'ACESSO RÁPIDO',
                style: theme.sectionHeaderStyle.copyWith(
                  color: theme.sectionHeaderStyle.color?.withValues(alpha: 0.4),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: theme.historyItemIconColor.withValues(alpha: 0.6),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Último cálculo: Financiamento Imob.',
                        style: theme.historyItemStyle,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: theme.historyItemArrowColor.withValues(alpha: 0.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: theme.bottomNavBackgroundColor,
        selectedItemColor: theme.bottomNavSelectedColor,
        unselectedItemColor: theme.bottomNavUnselectedColor.withValues(alpha: 0.4),
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'INÍCIO'),
          BottomNavigationBarItem(icon: Icon(Icons.history_toggle_off), label: 'HISTÓRICO'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'AJUSTES'),
        ],
      ),
    );
  }
}