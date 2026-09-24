import 'package:flutter/material.dart';

import '../../../../core/themes/spacing.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/title_widget.dart';

class ValueCorrectionPage extends StatelessWidget {
  const ValueCorrectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageHeader(title: "Correção de Valores"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md + 4,
          vertical: AppSpacing.md + 4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.lg,
          children: [
            TitleWidget(
              title: 'Correção de Valores',
              subtitle: 'Calcule o valor da correção de valores.',
            ),
          ],
        ),
      ),
    );
  }
}
