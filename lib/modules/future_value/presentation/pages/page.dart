import 'package:flutter/material.dart';
import 'package:real_calc/core/themes/spacing.dart';
import 'package:real_calc/core/widgets/page_header.dart';
import 'package:real_calc/core/widgets/title_widget.dart';
import 'package:real_calc/modules/future_value/presentation/widgets/future_value_forms.dart';
import 'package:real_calc/modules/future_value/presentation/widgets/help_card.dart';

class FutureValuePage extends StatefulWidget {
  const FutureValuePage({super.key});

  @override
  State<FutureValuePage> createState() => _FutureValuePageState();
}

class _FutureValuePageState extends State<FutureValuePage> {
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
                menssage: 'Preencha 3 campos e toque no 4° para calcular automaticamente',
              ),
              const FutureValueForms(),
            ],
          ),
        ),
      ),
    );
  }
}
