// core/themes/theme_extensions/input_forms_result_card_theme.dart
import 'package:flutter/material.dart';

class InputFormsResultCardTheme extends ThemeExtension<InputFormsResultCardTheme> {
  final Color suffixIconColor;
  final TextStyle helperTextStyle;

  const InputFormsResultCardTheme({
    required this.suffixIconColor,
    required this.helperTextStyle,
  });

  @override
  ThemeExtension<InputFormsResultCardTheme> copyWith({
    Color? suffixIconColor,
    TextStyle? helperTextStyle,
  }) {
    return InputFormsResultCardTheme(
      suffixIconColor: suffixIconColor ?? this.suffixIconColor,
      helperTextStyle: helperTextStyle ?? this.helperTextStyle,
    );
  }

  @override
  ThemeExtension<InputFormsResultCardTheme> lerp(
    ThemeExtension<InputFormsResultCardTheme>? other,
    double t,
  ) {
    if (other is! InputFormsResultCardTheme) return this;
    return InputFormsResultCardTheme(
      suffixIconColor: Color.lerp(suffixIconColor, other.suffixIconColor, t)!,
      helperTextStyle: TextStyle.lerp(helperTextStyle, other.helperTextStyle, t)!,
    );
  }
}