import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:real_calc/core/themes/extensions/input_forms_result_card_theme.dart';

import 'types/input_field_state.dart';

class InputFormsResultCard extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final InputFieldState state;
  final VoidCallback? onTap;

  const InputFormsResultCard({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.validator,
    this.inputFormatters,
    this.state = InputFieldState.neutral,
    this.onTap,
  });
  bool get _isHighlightedAndEmptyText {
    if (state == InputFieldState.highlighted && controller.text.isEmpty) {
      return true;
    }
    return false;
  }

  Color _accentColor(InputFormsResultCardTheme theme) {
    return switch (state) {
      InputFieldState.neutral => theme.neutralIconColor,
      InputFieldState.highlighted => theme.highlightedColor,
      InputFieldState.calculated => theme.calculatedColor,
      InputFieldState.error => theme.errorColor,
    };
  }

  String? get _badgeText => switch (state) {
    InputFieldState.highlighted => 'vazio',
    InputFieldState.calculated => 'calculado',
    InputFieldState.neutral || InputFieldState.error => null,
  };

  String get _effectiveHint {
    if (_isHighlightedAndEmptyText) {
      return 'toque para calcular';
    }
    return hint;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<InputFormsResultCardTheme>()!;
    final bool isNeutral = state == InputFieldState.neutral;
    final Color accent = _accentColor(theme);
    final String? badgeText = _badgeText;

    final bool isHintMessage = _isHighlightedAndEmptyText == true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isNeutral ? null : accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(theme.borderRadius),
        border: Border.all(
          color: isNeutral ? theme.neutralBorderColor : accent,
          width: isNeutral ? 0.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isNeutral ? theme.neutralLabelColor : accent,
                ),
              ),
              if (badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeText,
                    style: theme.badgeStyle.copyWith(color: accent),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isNeutral ? theme.neutralIconColor : accent,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  onTap: onTap,
                  validator: validator,
                  inputFormatters: inputFormatters,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: _effectiveHint,
                    hintStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: isHintMessage
                          ? accent // cor de destaque quando é mensagem
                          : theme.neutralLabelColor, // cor normal do hint
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
