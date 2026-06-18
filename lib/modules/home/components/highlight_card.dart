import 'package:flutter/material.dart';
import 'package:real_calc/core/themes/extensions/highlight_card_theme.dart';

class HighlightCard extends StatelessWidget {
  final VoidCallback? onTap;

  const HighlightCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<HighlightCardTheme>()!;

    return Container(
      width: double.infinity,
      padding: theme.padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(theme.borderRadius),
        gradient: LinearGradient(
          colors: theme.gradientColors,
          begin: theme.gradientBegin,
          end: theme.gradientEnd,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Selic e Índices', style: theme.titleStyle),
          const SizedBox(height: 8),
          Text(
            'Acompanhe as taxas oficiais atualizadas diariamente pelo Banco Central.',
            style: theme.subtitleStyle.copyWith(
              color: theme.subtitleStyle.color?.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.buttonBackgroundColor.withValues(alpha: 0.2),
              foregroundColor: theme.buttonForegroundColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('CONSULTAR TAXAS', style: theme.buttonTextStyle),
          ),
        ],
      ),
    );
  }
}