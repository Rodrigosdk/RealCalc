import 'package:flutter/material.dart';

class MenuCardTheme extends ThemeExtension<MenuCardTheme> {
  final TextStyle titleStyle;
  final TextStyle descriptionStyle;
  final Color iconContainerColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry compactPadding;
  final double heightThreshold;

  const MenuCardTheme({
    required this.titleStyle,
    required this.descriptionStyle,
    required this.iconContainerColor,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(12),
    this.compactPadding = const EdgeInsets.all(8),
    this.heightThreshold = 100,
  });

  @override
  ThemeExtension<MenuCardTheme> copyWith({
    TextStyle? titleStyle,
    TextStyle? descriptionStyle,
    Color? iconContainerColor,
    double? borderRadius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? compactPadding,
    double? heightThreshold,
  }) {
    return MenuCardTheme(
      titleStyle: titleStyle ?? this.titleStyle,
      descriptionStyle: descriptionStyle ?? this.descriptionStyle,
      iconContainerColor: iconContainerColor ?? this.iconContainerColor,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      compactPadding: compactPadding ?? this.compactPadding,
      heightThreshold: heightThreshold ?? this.heightThreshold,
    );
  }

  @override
  ThemeExtension<MenuCardTheme> lerp(
    ThemeExtension<MenuCardTheme>? other,
    double t,
  ) {
    if (other is! MenuCardTheme) return this;
    return MenuCardTheme(
      titleStyle: TextStyle.lerp(titleStyle, other.titleStyle, t)!,
      descriptionStyle: TextStyle.lerp(descriptionStyle, other.descriptionStyle, t)!,
      iconContainerColor: Color.lerp(iconContainerColor, other.iconContainerColor, t)!,
      borderRadius: other.borderRadius,
      padding: other.padding,
      compactPadding: other.compactPadding,
      heightThreshold: other.heightThreshold,
    );
  }
}