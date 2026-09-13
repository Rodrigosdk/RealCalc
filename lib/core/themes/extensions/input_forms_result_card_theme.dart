import 'package:flutter/material.dart';

class InputFormsResultCardTheme extends ThemeExtension<InputFormsResultCardTheme> {
  final Color neutralBorderColor;
  final Color neutralLabelColor;
  final Color neutralIconColor;
  final Color highlightedColor;
  final Color calculatedColor;
  final Color errorColor;
  final TextStyle badgeStyle;
  final double borderRadius;

  const InputFormsResultCardTheme({
    required this.neutralBorderColor,
    required this.neutralLabelColor,
    required this.neutralIconColor,
    required this.highlightedColor,
    required this.calculatedColor,
    required this.errorColor,
    required this.badgeStyle,
    this.borderRadius = 14,
  });

  @override
  InputFormsResultCardTheme copyWith({
    Color? neutralBorderColor,
    Color? neutralLabelColor,
    Color? neutralIconColor,
    Color? highlightedColor,
    Color? calculatedColor,
    Color? errorColor,
    TextStyle? badgeStyle,
    double? borderRadius,
  }) {
    return InputFormsResultCardTheme(
      neutralBorderColor: neutralBorderColor ?? this.neutralBorderColor,
      neutralLabelColor: neutralLabelColor ?? this.neutralLabelColor,
      neutralIconColor: neutralIconColor ?? this.neutralIconColor,
      highlightedColor: highlightedColor ?? this.highlightedColor,
      calculatedColor: calculatedColor ?? this.calculatedColor,
      errorColor: errorColor ?? this.errorColor,
      badgeStyle: badgeStyle ?? this.badgeStyle,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  InputFormsResultCardTheme lerp(
    ThemeExtension<InputFormsResultCardTheme>? other,
    double t,
  ) {
    if (other is! InputFormsResultCardTheme) return this;
    return InputFormsResultCardTheme(
      neutralBorderColor:
          Color.lerp(neutralBorderColor, other.neutralBorderColor, t)!,
      neutralLabelColor:
          Color.lerp(neutralLabelColor, other.neutralLabelColor, t)!,
      neutralIconColor:
          Color.lerp(neutralIconColor, other.neutralIconColor, t)!,
      highlightedColor: Color.lerp(highlightedColor, other.highlightedColor, t)!,
      calculatedColor: Color.lerp(calculatedColor, other.calculatedColor, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
      badgeStyle: TextStyle.lerp(badgeStyle, other.badgeStyle, t)!,
      borderRadius: borderRadius + (other.borderRadius - borderRadius) * t,
    );
  }
}