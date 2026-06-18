import 'package:flutter/material.dart';

class HelpCardTheme extends ThemeExtension<HelpCardTheme> {
  final TextStyle messageStyle;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconBackgroundColor;
  final Color iconColor;
  final double iconSize;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const HelpCardTheme({
    required this.messageStyle,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconBackgroundColor,
    required this.iconColor,
    this.iconSize = 22,
    this.borderRadius = 18,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  ThemeExtension<HelpCardTheme> copyWith({
    TextStyle? messageStyle,
    Color? backgroundColor,
    Color? borderColor,
    Color? iconBackgroundColor,
    Color? iconColor,
    double? iconSize,
    double? borderRadius,
    EdgeInsetsGeometry? padding,
  }) {
    return HelpCardTheme(
      messageStyle: messageStyle ?? this.messageStyle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      iconBackgroundColor: iconBackgroundColor ?? this.iconBackgroundColor,
      iconColor: iconColor ?? this.iconColor,
      iconSize: iconSize ?? this.iconSize,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
    );
  }

  @override
  ThemeExtension<HelpCardTheme> lerp(
    ThemeExtension<HelpCardTheme>? other,
    double t,
  ) {
    if (other is! HelpCardTheme) return this;
    return HelpCardTheme(
      messageStyle: TextStyle.lerp(messageStyle, other.messageStyle, t)!,
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      iconBackgroundColor:
          Color.lerp(iconBackgroundColor, other.iconBackgroundColor, t)!,
      iconColor: Color.lerp(iconColor, other.iconColor, t)!,
      iconSize: other.iconSize,
      borderRadius: other.borderRadius,
      padding: other.padding,
    );
  }
}