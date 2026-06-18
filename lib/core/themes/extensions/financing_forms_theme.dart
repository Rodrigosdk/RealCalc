import 'package:flutter/material.dart';

class FinancingFormsTheme extends ThemeExtension<FinancingFormsTheme> {
  final Color iconColor;
  final Color progressIndicatorColor;
  final Color errorBackgroundColor;
  final Color errorBorderColor;
  final TextStyle errorTextStyle;
  final EdgeInsetsGeometry errorContainerPadding;

  const FinancingFormsTheme({
    required this.iconColor,
    required this.progressIndicatorColor,
    required this.errorBackgroundColor,
    required this.errorBorderColor,
    required this.errorTextStyle,
    this.errorContainerPadding = const EdgeInsets.all(12),
  });

  @override
  ThemeExtension<FinancingFormsTheme> copyWith({
    Color? iconColor,
    Color? progressIndicatorColor,
    Color? errorBackgroundColor,
    Color? errorBorderColor,
    TextStyle? errorTextStyle,
    EdgeInsetsGeometry? errorContainerPadding,
  }) {
    return FinancingFormsTheme(
      iconColor: iconColor ?? this.iconColor,
      progressIndicatorColor:
          progressIndicatorColor ?? this.progressIndicatorColor,
      errorBackgroundColor:
          errorBackgroundColor ?? this.errorBackgroundColor,
      errorBorderColor: errorBorderColor ?? this.errorBorderColor,
      errorTextStyle: errorTextStyle ?? this.errorTextStyle,
      errorContainerPadding:
          errorContainerPadding ?? this.errorContainerPadding,
    );
  }

  @override
  ThemeExtension<FinancingFormsTheme> lerp(
    ThemeExtension<FinancingFormsTheme>? other,
    double t,
  ) {
    if (other is! FinancingFormsTheme) return this;
    return FinancingFormsTheme(
      iconColor: Color.lerp(iconColor, other.iconColor, t)!,
      progressIndicatorColor:
          Color.lerp(progressIndicatorColor, other.progressIndicatorColor, t)!,
      errorBackgroundColor:
          Color.lerp(errorBackgroundColor, other.errorBackgroundColor, t)!,
      errorBorderColor:
          Color.lerp(errorBorderColor, other.errorBorderColor, t)!,
      errorTextStyle:
          TextStyle.lerp(errorTextStyle, other.errorTextStyle, t)!,
      errorContainerPadding: other.errorContainerPadding,
    );
  }
}