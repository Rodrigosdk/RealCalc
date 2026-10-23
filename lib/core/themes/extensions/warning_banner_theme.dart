import 'package:flutter/material.dart';

class WarningBannerTheme extends ThemeExtension<WarningBannerTheme> {
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final TextStyle textStyle;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double iconSize;
  final double iconTextSpacing;

  const WarningBannerTheme({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.textStyle,
    this.padding = const EdgeInsets.all(12),
    this.borderRadius = 12,
    this.iconSize = 18,
    this.iconTextSpacing = 10,
  });

  @override
  WarningBannerTheme copyWith({
    Color? backgroundColor,
    Color? borderColor,
    Color? iconColor,
    TextStyle? textStyle,
    EdgeInsetsGeometry? padding,
    double? borderRadius,
    double? iconSize,
    double? iconTextSpacing,
  }) {
    return WarningBannerTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      iconColor: iconColor ?? this.iconColor,
      textStyle: textStyle ?? this.textStyle,
      padding: padding ?? this.padding,
      borderRadius: borderRadius ?? this.borderRadius,
      iconSize: iconSize ?? this.iconSize,
      iconTextSpacing: iconTextSpacing ?? this.iconTextSpacing,
    );
  }

  @override
  WarningBannerTheme lerp(
    covariant ThemeExtension<WarningBannerTheme>? other,
    double t,
  ) {
    if (other is! WarningBannerTheme) return this;

    return WarningBannerTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      iconColor: Color.lerp(iconColor, other.iconColor, t)!,
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t)!,
      padding: EdgeInsetsGeometry.lerp(padding, other.padding, t)!,
      borderRadius: borderRadius + (other.borderRadius - borderRadius) * t,
      iconSize: iconSize + (other.iconSize - iconSize) * t,
      iconTextSpacing:
          iconTextSpacing + (other.iconTextSpacing - iconTextSpacing) * t,
    );
  }
}
