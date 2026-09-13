import 'dart:ui';
import 'package:flutter/material.dart';

class MetricCardTheme extends ThemeExtension<MetricCardTheme> {
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  final TextStyle labelStyle;
  final TextStyle valueStyle;
  final TextStyle valueUnitStyle;
  final TextStyle captionStyle;
  final TextStyle variationTextStyle;

  final Color variationPositiveColor;
  final Color variationNegativeColor;
  final Color variationNeutralColor;

  final double sparklineStrokeWidth;
  final Color skeletonColor;

  const MetricCardTheme({
    required this.backgroundColor,
    required this.borderColor,
    required this.labelStyle,
    required this.valueStyle,
    required this.valueUnitStyle,
    required this.captionStyle,
    required this.variationTextStyle,
    required this.variationPositiveColor,
    required this.variationNegativeColor,
    required this.variationNeutralColor,
    required this.skeletonColor,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(16),
    this.sparklineStrokeWidth = 1.6,
  });

  @override
  MetricCardTheme copyWith({
    Color? backgroundColor,
    Color? borderColor,
    double? borderRadius,
    EdgeInsetsGeometry? padding,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
    TextStyle? valueUnitStyle,
    TextStyle? captionStyle,
    TextStyle? variationTextStyle,
    Color? variationPositiveColor,
    Color? variationNegativeColor,
    Color? variationNeutralColor,
    Color? skeletonColor,
    double? sparklineStrokeWidth,
  }) {
    return MetricCardTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      labelStyle: labelStyle ?? this.labelStyle,
      valueStyle: valueStyle ?? this.valueStyle,
      valueUnitStyle: valueUnitStyle ?? this.valueUnitStyle,
      captionStyle: captionStyle ?? this.captionStyle,
      variationTextStyle: variationTextStyle ?? this.variationTextStyle,
      variationPositiveColor:
          variationPositiveColor ?? this.variationPositiveColor,
      variationNegativeColor:
          variationNegativeColor ?? this.variationNegativeColor,
      variationNeutralColor:
          variationNeutralColor ?? this.variationNeutralColor,
      skeletonColor: skeletonColor ?? this.skeletonColor,
      sparklineStrokeWidth: sparklineStrokeWidth ?? this.sparklineStrokeWidth,
    );
  }

  @override
  MetricCardTheme lerp(
    ThemeExtension<MetricCardTheme>? other,
    double t,
  ) {
    if (other is! MetricCardTheme) return this;
    return MetricCardTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      borderRadius: lerpDouble(borderRadius, other.borderRadius, t)!,
      padding: EdgeInsetsGeometry.lerp(padding, other.padding, t)!,
      labelStyle: TextStyle.lerp(labelStyle, other.labelStyle, t)!,
      valueStyle: TextStyle.lerp(valueStyle, other.valueStyle, t)!,
      valueUnitStyle: TextStyle.lerp(valueUnitStyle, other.valueUnitStyle, t)!,
      captionStyle: TextStyle.lerp(captionStyle, other.captionStyle, t)!,
      variationTextStyle:
          TextStyle.lerp(variationTextStyle, other.variationTextStyle, t)!,
      variationPositiveColor: Color.lerp(
          variationPositiveColor, other.variationPositiveColor, t)!,
      variationNegativeColor: Color.lerp(
          variationNegativeColor, other.variationNegativeColor, t)!,
      variationNeutralColor: Color.lerp(
          variationNeutralColor, other.variationNeutralColor, t)!,
      skeletonColor: Color.lerp(skeletonColor, other.skeletonColor, t)!,
      sparklineStrokeWidth:
          lerpDouble(sparklineStrokeWidth, other.sparklineStrokeWidth, t)!,
    );
  }
}