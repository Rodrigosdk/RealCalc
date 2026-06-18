import 'package:flutter/material.dart';
import 'package:real_calc/core/themes/extensions/options_bottom_forms_theme.dart';
import 'package:real_calc/core/themes/spacing.dart';

class OptionsBottomForms extends StatelessWidget {
  final VoidCallback? onCalculate;
  final VoidCallback? onClear;
  final VoidCallback? onShare;

  const OptionsBottomForms({
    super.key,
    this.onCalculate,
    this.onClear,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final optionsTheme = theme.extension<OptionsBottomFormsTheme>()!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.sm + 4,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onCalculate,
            icon: const Icon(Icons.calculate_outlined),
            label: const Text('Calcular'),
            style: ElevatedButton.styleFrom(
              backgroundColor: optionsTheme.calculateButtonBackground,
              foregroundColor: optionsTheme.calculateButtonForeground,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              textStyle: theme.textTheme.labelLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        Row(
          spacing: AppSpacing.sm + 4,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Limpar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: optionsTheme.actionButtonBackground,
                  foregroundColor: optionsTheme.actionButtonForeground,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  textStyle: theme.textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.w500),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.share_outlined),
                label: const Text('Compartilhar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: optionsTheme.actionButtonBackground,
                  foregroundColor: optionsTheme.actionButtonForeground,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  textStyle: theme.textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.w500),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}