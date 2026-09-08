import 'package:flutter/material.dart';
import 'package:real_calc/core/themes/spacing.dart';
import 'package:real_calc/core/widgets/page_header.dart';
import 'package:real_calc/core/widgets/title_widget.dart';
import 'package:real_calc/modules/financing/presentation/widgets/help_card.dart';
import '../widgets/regular_deposits_forms.dart';

class RegularDepositsPage extends StatefulWidget {
  const RegularDepositsPage({super.key});

  @override
  State<RegularDepositsPage> createState() => _RegularDepositsPageState();
}

class _RegularDepositsPageState extends State<RegularDepositsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageHeader(title:'Depósitos Regulares'),
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
                title: 'Depósitos Regulares',
                subtitle: 'Calcule o valor futuro, a taxa, o prazo ou o depósito mensal.',
              ),
              const HelpCard(
                menssage: 'Preencha 3 campos e toque no 4° para calcular automaticamente',
              ),
              const RegularDepositsForms(),
            ],
          ),
        ),
      ),
    );
  }
}
