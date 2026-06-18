import 'package:flutter/material.dart';

class TitleWidgetTheme extends ThemeExtension<TitleWidgetTheme> {
  final TextStyle titleStyle;
  final TextStyle subtitleStyle;

  const TitleWidgetTheme({
    required this.titleStyle,
    required this.subtitleStyle,
  });

  @override
  ThemeExtension<TitleWidgetTheme> copyWith({
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
  }) {
    return TitleWidgetTheme(
      titleStyle: titleStyle ?? this.titleStyle,
      subtitleStyle: subtitleStyle ?? this.subtitleStyle,
    );
  }

  @override
  ThemeExtension<TitleWidgetTheme> lerp(
    ThemeExtension<TitleWidgetTheme>? other,
    double t,
  ) {
    if (other is! TitleWidgetTheme) return this;
    return TitleWidgetTheme(
      titleStyle: TextStyle.lerp(titleStyle, other.titleStyle, t)!,
      subtitleStyle: TextStyle.lerp(subtitleStyle, other.subtitleStyle, t)!,
    );
  }
}