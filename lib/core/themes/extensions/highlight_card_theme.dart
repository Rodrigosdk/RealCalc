import 'package:flutter/material.dart';

class HighlightCardTheme extends ThemeExtension<HighlightCardTheme> {
  final List<Color> gradientColors;
  final AlignmentGeometry gradientBegin;
  final AlignmentGeometry gradientEnd;
  final TextStyle titleStyle;
  final TextStyle subtitleStyle;
  final Color buttonBackgroundColor;
  final Color buttonForegroundColor;
  final TextStyle buttonTextStyle;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const HighlightCardTheme({
    required this.gradientColors,
    this.gradientBegin = Alignment.topLeft,
    this.gradientEnd = Alignment.bottomRight,
    required this.titleStyle,
    required this.subtitleStyle,
    required this.buttonBackgroundColor,
    required this.buttonForegroundColor,
    required this.buttonTextStyle,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  ThemeExtension<HighlightCardTheme> copyWith({
    List<Color>? gradientColors,
    AlignmentGeometry? gradientBegin,
    AlignmentGeometry? gradientEnd,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
    Color? buttonBackgroundColor,
    Color? buttonForegroundColor,
    TextStyle? buttonTextStyle,
    double? borderRadius,
    EdgeInsetsGeometry? padding,
  }) {
    return HighlightCardTheme(
      gradientColors: gradientColors ?? this.gradientColors,
      gradientBegin: gradientBegin ?? this.gradientBegin,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      titleStyle: titleStyle ?? this.titleStyle,
      subtitleStyle: subtitleStyle ?? this.subtitleStyle,
      buttonBackgroundColor:
          buttonBackgroundColor ?? this.buttonBackgroundColor,
      buttonForegroundColor:
          buttonForegroundColor ?? this.buttonForegroundColor,
      buttonTextStyle: buttonTextStyle ?? this.buttonTextStyle,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
    );
  }

  @override
  ThemeExtension<HighlightCardTheme> lerp(
    ThemeExtension<HighlightCardTheme>? other,
    double t,
  ) {
    if (other is! HighlightCardTheme) return this;
    return HighlightCardTheme(
      gradientColors: other.gradientColors,
      gradientBegin: other.gradientBegin,
      gradientEnd: other.gradientEnd,
      titleStyle: TextStyle.lerp(titleStyle, other.titleStyle, t)!,
      subtitleStyle: TextStyle.lerp(subtitleStyle, other.subtitleStyle, t)!,
      buttonBackgroundColor:
          Color.lerp(buttonBackgroundColor, other.buttonBackgroundColor, t)!,
      buttonForegroundColor:
          Color.lerp(buttonForegroundColor, other.buttonForegroundColor, t)!,
      buttonTextStyle:
          TextStyle.lerp(buttonTextStyle, other.buttonTextStyle, t)!,
      borderRadius: other.borderRadius,
      padding: other.padding,
    );
  }
}