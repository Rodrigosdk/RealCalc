import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:real_calc/core/themes/color_tokens.dart';
import 'package:real_calc/core/themes/spacing.dart';

class InputForms extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final Widget prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final GestureTapCallback? onTap;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  const InputForms({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.textInputAction,
    this.keyboardType = TextInputType.number,
    this.validator,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.sm,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: ColorTokens.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextFormField(
          validator: validator,
          controller: controller,
          inputFormatters: inputFormatters,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onTap: onTap,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: ColorTokens.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                theme.inputDecorationTheme.hintStyle ??
                TextStyle(color: ColorTokens.textHint),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
