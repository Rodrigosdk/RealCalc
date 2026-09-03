import 'dart:ui';
import 'package:flutter/material.dart';

class MenuCardTheme extends ThemeExtension<MenuCardTheme> {
  // Variante standard (grid 2 colunas)
  final TextStyle titleStyle;
  final TextStyle descriptionStyle;
  final TextStyle titleStyleCompact;
  final TextStyle descriptionStyleCompact;
  final double iconSize;
  final double iconSizeCompact;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry compactPadding;
  final double heightThreshold;

  // Variante featured (tile full-width, texto maior por ter mais espaço)
  final TextStyle titleStyleFeatured;
  final TextStyle descriptionStyleFeatured;
  final Color featuredBorderColor;

  // Variante disabled
  final Color disabledLabelColor;
  final TextStyle disabledTextStyle;

  const MenuCardTheme({
    required this.titleStyle,
    required this.descriptionStyle,
    required this.titleStyleCompact,
    required this.descriptionStyleCompact,
    required this.titleStyleFeatured,
    required this.descriptionStyleFeatured,
    required this.featuredBorderColor,
    required this.disabledLabelColor,
    required this.disabledTextStyle,
    this.iconSize = 24,
    this.iconSizeCompact = 20,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    this.compactPadding = const EdgeInsets.all(8),
    this.heightThreshold = 100,
  });

  @override
  MenuCardTheme copyWith({
    TextStyle? titleStyle,
    TextStyle? descriptionStyle,
    TextStyle? titleStyleCompact,
    TextStyle? descriptionStyleCompact,
    TextStyle? titleStyleFeatured,
    TextStyle? descriptionStyleFeatured,
    Color? featuredBorderColor,
    Color? disabledLabelColor,
    TextStyle? disabledTextStyle,
    double? iconSize,
    double? iconSizeCompact,
    double? borderRadius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? compactPadding,
    double? heightThreshold,
  }) {
    return MenuCardTheme(
      titleStyle: titleStyle ?? this.titleStyle,
      descriptionStyle: descriptionStyle ?? this.descriptionStyle,
      titleStyleCompact: titleStyleCompact ?? this.titleStyleCompact,
      descriptionStyleCompact:
          descriptionStyleCompact ?? this.descriptionStyleCompact,
      titleStyleFeatured: titleStyleFeatured ?? this.titleStyleFeatured,
      descriptionStyleFeatured:
          descriptionStyleFeatured ?? this.descriptionStyleFeatured,
      featuredBorderColor: featuredBorderColor ?? this.featuredBorderColor,
      disabledLabelColor: disabledLabelColor ?? this.disabledLabelColor,
      disabledTextStyle: disabledTextStyle ?? this.disabledTextStyle,
      iconSize: iconSize ?? this.iconSize,
      iconSizeCompact: iconSizeCompact ?? this.iconSizeCompact,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      compactPadding: compactPadding ?? this.compactPadding,
      heightThreshold: heightThreshold ?? this.heightThreshold,
    );
  }

  @override
  MenuCardTheme lerp(ThemeExtension<MenuCardTheme>? other, double t) {
    if (other is! MenuCardTheme) return this;
    return MenuCardTheme(
      titleStyle: TextStyle.lerp(titleStyle, other.titleStyle, t)!,
      descriptionStyle: TextStyle.lerp(
        descriptionStyle,
        other.descriptionStyle,
        t,
      )!,
      titleStyleCompact: TextStyle.lerp(
        titleStyleCompact,
        other.titleStyleCompact,
        t,
      )!,
      descriptionStyleCompact: TextStyle.lerp(
        descriptionStyleCompact,
        other.descriptionStyleCompact,
        t,
      )!,
      titleStyleFeatured: TextStyle.lerp(
        titleStyleFeatured,
        other.titleStyleFeatured,
        t,
      )!,
      descriptionStyleFeatured: TextStyle.lerp(
        descriptionStyleFeatured,
        other.descriptionStyleFeatured,
        t,
      )!,
      featuredBorderColor: Color.lerp(
        featuredBorderColor,
        other.featuredBorderColor,
        t,
      )!,
      disabledLabelColor: Color.lerp(
        disabledLabelColor,
        other.disabledLabelColor,
        t,
      )!,
      disabledTextStyle: TextStyle.lerp(
        disabledTextStyle,
        other.disabledTextStyle,
        t,
      )!,
      iconSize: lerpDouble(iconSize, other.iconSize, t)!,
      iconSizeCompact: lerpDouble(iconSizeCompact, other.iconSizeCompact, t)!,
      borderRadius: lerpDouble(borderRadius, other.borderRadius, t)!,
      padding: EdgeInsetsGeometry.lerp(padding, other.padding, t)!,
      compactPadding: EdgeInsetsGeometry.lerp(
        compactPadding,
        other.compactPadding,
        t,
      )!,
      heightThreshold: lerpDouble(heightThreshold, other.heightThreshold, t)!,
    );
  }
}
