import 'package:flutter/material.dart';
import 'package:real_calc/core/themes/extensions/options_bottom_forms_theme.dart';
import 'package:real_calc/core/themes/spacing.dart';

class OptionsBottomForms extends StatelessWidget {
  final VoidCallback? onCalculate;
  final VoidCallback? onClear;

  const OptionsBottomForms({
    super.key,
    this.onCalculate,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final optionsTheme = theme.extension<OptionsBottomFormsTheme>()!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.sm + 4,
      children: [
        Expanded(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onCalculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: optionsTheme.calculateButtonBackground,
                foregroundColor: optionsTheme.calculateButtonForeground,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child:  Text('Calcular',style: theme.textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w600, color: Colors.black),),
              ),
            ),
          ),
        ),
        Expanded(
          child: ElevatedButton(
            onPressed: onClear,
            style: ElevatedButton.styleFrom(
              backgroundColor: optionsTheme.actionButtonBackground,
              foregroundColor: optionsTheme.actionButtonForeground,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              textStyle: theme.textTheme.labelLarge
                  ?.copyWith(fontWeight: FontWeight.w500),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: optionsTheme.borderButtonColor)
              ),
            ),
           child: Padding(
             padding: const EdgeInsets.all(8.0),
             child: const Text('Limpar'),
           ),
          ),
        ),
      ],
    );
  }
}