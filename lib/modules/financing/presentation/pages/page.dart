import 'package:flutter/material.dart';
import 'package:real_calc/core/widgets/app_bar_forms.dart';
import 'package:real_calc/modules/financing/presentation/widgets/help_card.dart';
import '../widgets/financing_forms.dart';
import '../../../../core/widgets/title_widget.dart';

class FinancingPage extends StatefulWidget {
  const FinancingPage({super.key});

  @override
  State<FinancingPage> createState() => _FinancingPageState();
}

class _FinancingPageState extends State<FinancingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1422),
      appBar: AppBarForms(title: 'Calculadora de Financiamento'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 24,
            children: [
              TitleWidget(
                title: 'Financiamento',
                subtitle: 'Calcule o valor da prestação do seu financiamento.',
              ),
              HelpCard(menssage: 'Preencha 3 campos e toque no 4° para calcular automaticamente',),
              FinancingForms(),
              const Text(
                'Este cálculo utiliza o sistema Price. Os resultados são simulações estimadas e podem sofrer alterações conforme taxas bancárias, impostos (IOF) e seguros.',
                style: TextStyle(
                  color: Color(0xFF5B6874),
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
