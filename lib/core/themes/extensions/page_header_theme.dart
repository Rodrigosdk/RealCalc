import 'package:flutter/material.dart';

class PageHeaderTheme extends ThemeExtension<PageHeaderTheme> {
  final Color backgroundColor;
  final Color iconColor;
  final TextStyle titleStyle;

  const PageHeaderTheme({
    required this.backgroundColor,
    required this.iconColor,
    required this.titleStyle,
  });

  @override
  PageHeaderTheme copyWith({
    Color? backgroundColor,
    Color? iconColor,
    TextStyle? titleStyle,
  }) {
    return PageHeaderTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      iconColor: iconColor ?? this.iconColor,
      titleStyle: titleStyle ?? this.titleStyle,
    );
  }

  @override
  PageHeaderTheme lerp(ThemeExtension<PageHeaderTheme>? other, double t) {
    if (other is! PageHeaderTheme) return this;
    return PageHeaderTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      iconColor: Color.lerp(iconColor, other.iconColor, t)!,
      titleStyle: TextStyle.lerp(titleStyle, other.titleStyle, t)!,
    );
  }
}