import 'package:flutter/material.dart';
import 'package:real_calc/core/themes/spacing.dart';
import 'package:real_calc/core/widgets/title_widget.dart';
import 'package:real_calc/modules/financing/presentation/widgets/financing_forms.dart';
import 'package:real_calc/modules/financing/presentation/widgets/help_card.dart';

class FinancingPage extends StatefulWidget {
  const FinancingPage({super.key});

  @override
  State<FinancingPage> createState() => _FinancingPageState();
}

class _FinancingPageState extends State<FinancingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora de Financiamento')),
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
                subtitle:'Calcule o valor da prestação do seu financiamento.',
              ),
              const HelpCard(
                menssage: 'Preencha 3 campos e toque no 4° para calcular automaticamente',
              ),
              const FinancingForms(),
            ],
          ),
        ),
      ),
    );
  }
}