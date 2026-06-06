import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:real_calc/core/routes/app_routes.dart';
import 'package:real_calc/core/widgets/title_widget.dart';

import '../components/highlight_card.dart';
import '../components/menu_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0D1520);
    const cardColor = Color(0xFF16222F);
    const primaryBlue = Color(0xFF1E94F6);

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
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Logo e Nome do App
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2A3D),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: primaryBlue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.calculate,
                      color: primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'RealCalc',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Boas-vindas
              TitleWidget(
                title: 'Olá, Cidadão',
                subtitle: 'Qual cálculo deseja realizar hoje?',
              ),
              const SizedBox(height: 32),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: funcinalidades.length,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: larguraMaximaDoCard, // Passando a largura física em pixels
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0, // Garante formato quadrado ideal
                ),
                itemBuilder: (context, index) {
                  final item = funcinalidades[index];
                  return MenuCard(
                    icon: item['icon'] as IconData,
                    title: item['title'] as String,
                    description: item['description'] as String,
                    cardColor: cardColor,
                    iconColor: primaryBlue,
                    onTap: item['onTap'] as VoidCallback?,
                  );
                },
              ),
              const SizedBox(height: 24),

              HighlightCard(),
              const SizedBox(height: 24),

              // Seção Acesso Rápido
              Text(
                'ACESSO RÁPIDO',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              // Item de Histórico Recente
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Último cálculo: Financiamento Imob.',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF090D14),
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.white.withValues(alpha: 0.4),
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'INÍCIO'),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_toggle_off),
            label: 'HISTÓRICO',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'AJUSTES'),
        ],
      ),
    );
  }
}
