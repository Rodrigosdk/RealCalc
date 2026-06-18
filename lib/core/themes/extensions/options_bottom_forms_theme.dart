// core/themes/theme_extensions/options_bottom_forms_theme.dart
import 'package:flutter/material.dart';

class OptionsBottomFormsTheme extends ThemeExtension<OptionsBottomFormsTheme> {
  final Color calculateButtonBackground;
  final Color calculateButtonForeground;
  final Color actionButtonBackground;
  final Color actionButtonForeground;

  const OptionsBottomFormsTheme({
    required this.calculateButtonBackground,
    required this.calculateButtonForeground,
    required this.actionButtonBackground,
    required this.actionButtonForeground,
  });

  @override
  ThemeExtension<OptionsBottomFormsTheme> copyWith({
    Color? calculateButtonBackground,
    Color? calculateButtonForeground,
    Color? actionButtonBackground,
    Color? actionButtonForeground,
  }) {
    return OptionsBottomFormsTheme(
      calculateButtonBackground: calculateButtonBackground ?? this.calculateButtonBackground,
      calculateButtonForeground: calculateButtonForeground ?? this.calculateButtonForeground,
      actionButtonBackground: actionButtonBackground ?? this.actionButtonBackground,
      actionButtonForeground: actionButtonForeground ?? this.actionButtonForeground,
    );
  }

  @override
  ThemeExtension<OptionsBottomFormsTheme> lerp(
    ThemeExtension<OptionsBottomFormsTheme>? other,
    double t,
  ) {
    if (other is! OptionsBottomFormsTheme) return this;
    return OptionsBottomFormsTheme(
      calculateButtonBackground: Color.lerp(calculateButtonBackground, other.calculateButtonBackground, t)!,
      calculateButtonForeground: Color.lerp(calculateButtonForeground, other.calculateButtonForeground, t)!,
      actionButtonBackground: Color.lerp(actionButtonBackground, other.actionButtonBackground, t)!,
      actionButtonForeground: Color.lerp(actionButtonForeground, other.actionButtonForeground, t)!,
    );
  }
}