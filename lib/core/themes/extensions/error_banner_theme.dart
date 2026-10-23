import 'package:flutter/material.dart';

class ErrorBannerTheme extends ThemeExtension<ErrorBannerTheme> {
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color retryTextColor;
  final TextStyle messageStyle;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double iconSize;
  final double iconMessageSpacing;
  final double retrySpacing;

  const ErrorBannerTheme({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.retryTextColor,
    required this.messageStyle,
    this.padding = const EdgeInsets.all(12),
    this.borderRadius = 12,
    this.iconSize = 18,
    this.iconMessageSpacing = 10,
    this.retrySpacing = 8,
  });

  @override
  ErrorBannerTheme copyWith({
    Color? backgroundColor,
    Color? borderColor,
    Color? iconColor,
    Color? retryTextColor,
    TextStyle? messageStyle,
    EdgeInsetsGeometry? padding,
    double? borderRadius,
    double? iconSize,
    double? iconMessageSpacing,
    double? retrySpacing,
  }) {
    return ErrorBannerTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      iconColor: iconColor ?? this.iconColor,
      retryTextColor: retryTextColor ?? this.retryTextColor,
      messageStyle: messageStyle ?? this.messageStyle,
      padding: padding ?? this.padding,
      borderRadius: borderRadius ?? this.borderRadius,
      iconSize: iconSize ?? this.iconSize,
      iconMessageSpacing: iconMessageSpacing ?? this.iconMessageSpacing,
      retrySpacing: retrySpacing ?? this.retrySpacing,
    );
  }

  @override
  ErrorBannerTheme lerp(
    covariant ThemeExtension<ErrorBannerTheme>? other,
    double t,
  ) {
    if (other is! ErrorBannerTheme) return this;

    return ErrorBannerTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      iconColor: Color.lerp(iconColor, other.iconColor, t)!,
      retryTextColor: Color.lerp(retryTextColor, other.retryTextColor, t)!,
      messageStyle: TextStyle.lerp(messageStyle, other.messageStyle, t)!,
      padding: EdgeInsetsGeometry.lerp(padding, other.padding, t)!,
      borderRadius: borderRadius + (other.borderRadius - borderRadius) * t,
      iconSize: iconSize + (other.iconSize - iconSize) * t,
      iconMessageSpacing:
          iconMessageSpacing +
          (other.iconMessageSpacing - iconMessageSpacing) * t,
      retrySpacing: retrySpacing + (other.retrySpacing - retrySpacing) * t,
    );
  }
}
