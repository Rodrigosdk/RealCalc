import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:real_calc/core/themes/spacing.dart';
import 'package:real_calc/core/widgets/input_forms.dart';

import '../../../../core/themes/extensions/input_forms_result_card_theme.dart';

class InputFormsResultCard extends StatelessWidget {
  final String label;
  final String hint;
  final Widget prefixIcon;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final TextEditingController controller;
  final List<TextInputFormatter>? inputFormatters;

  const InputFormsResultCard({
    super.key,
    required this.controller,
    this.onTap,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.validator,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<InputFormsResultCardTheme>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputForms(
          label: label,
          hint: hint,
          controller: controller,
          inputFormatters: inputFormatters,
          prefixIcon: prefixIcon,
          validator: validator,
          textInputAction: TextInputAction.done,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          suffixIcon: GestureDetector(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Icon(Icons.chevron_right, color: theme.suffixIconColor),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          'Toque para calcular automaticamente',
          style: theme.helperTextStyle,
        ),
      ],
    );
  }
}