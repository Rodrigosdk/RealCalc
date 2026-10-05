import 'package:flutter/material.dart';

class ValueCorrectionResultTheme extends ThemeExtension<ValueCorrectionResultTheme> {
  final Color cardBackgroundColor;
  final Color cardBorderColor;
  final Color spotlightBackground;
  final Color spotlightBorderColor;
  final Color variationPositiveColor;
  final Color shareButtonColor;
  final Color editButtonColor;
  final TextStyle titleStyle;
  final TextStyle subtitleStyle;
  final TextStyle spotlightLabelStyle;
  final TextStyle spotlightValueStyle;
  final TextStyle spotlightVariationStyle;
  final TextStyle detailLabelStyle;
  final TextStyle detailValueStyle;
  final TextStyle linkStyle;

  const ValueCorrectionResultTheme({
    required this.cardBackgroundColor,
    required this.cardBorderColor,
    required this.spotlightBackground,
    required this.spotlightBorderColor,
    required this.variationPositiveColor,
    required this.shareButtonColor,
    required this.editButtonColor,
    required this.titleStyle,
    required this.subtitleStyle,
    required this.spotlightLabelStyle,
    required this.spotlightValueStyle,
    required this.spotlightVariationStyle,
    required this.detailLabelStyle,
    required this.detailValueStyle,
    required this.linkStyle,
  });

  @override
  ThemeExtension<ValueCorrectionResultTheme> copyWith({
    Color? cardBackgroundColor,
    Color? cardBorderColor,
    Color? spotlightBackground,
    Color? spotlightBorderColor,
    Color? variationPositiveColor,
    Color? shareButtonColor,
    Color? editButtonColor,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
    TextStyle? spotlightLabelStyle,
    TextStyle? spotlightValueStyle,
    TextStyle? spotlightVariationStyle,
    TextStyle? detailLabelStyle,
    TextStyle? detailValueStyle,
    TextStyle? linkStyle,
  }) {
    return ValueCorrectionResultTheme(
      cardBackgroundColor: cardBackgroundColor ?? this.cardBackgroundColor,
      cardBorderColor: cardBorderColor ?? this.cardBorderColor,
      spotlightBackground: spotlightBackground ?? this.spotlightBackground,
      spotlightBorderColor: spotlightBorderColor ?? this.spotlightBorderColor,
      variationPositiveColor:
          variationPositiveColor ?? this.variationPositiveColor,
      shareButtonColor: shareButtonColor ?? this.shareButtonColor,
      editButtonColor: editButtonColor ?? this.editButtonColor,
      titleStyle: titleStyle ?? this.titleStyle,
      subtitleStyle: subtitleStyle ?? this.subtitleStyle,
      spotlightLabelStyle: spotlightLabelStyle ?? this.spotlightLabelStyle,
      spotlightValueStyle: spotlightValueStyle ?? this.spotlightValueStyle,
      spotlightVariationStyle:
          spotlightVariationStyle ?? this.spotlightVariationStyle,
      detailLabelStyle: detailLabelStyle ?? this.detailLabelStyle,
      detailValueStyle: detailValueStyle ?? this.detailValueStyle,
      linkStyle: linkStyle ?? this.linkStyle,
    );
  }

  @override
  ThemeExtension<ValueCorrectionResultTheme> lerp(
    ThemeExtension<ValueCorrectionResultTheme>? other,
    double t,
  ) {
    if (other is! ValueCorrectionResultTheme) return this;

    return ValueCorrectionResultTheme(
      cardBackgroundColor: Color.lerp(cardBackgroundColor, other.cardBackgroundColor, t)!,
      cardBorderColor: Color.lerp(cardBorderColor, other.cardBorderColor, t)!,
      spotlightBackground: Color.lerp(spotlightBackground, other.spotlightBackground, t)!,
      spotlightBorderColor: Color.lerp(spotlightBorderColor, other.spotlightBorderColor, t)!,
      variationPositiveColor: Color.lerp(variationPositiveColor, other.variationPositiveColor, t)!,
      shareButtonColor: Color.lerp(shareButtonColor, other.shareButtonColor, t)!,
      editButtonColor: Color.lerp(editButtonColor, other.editButtonColor, t)!,
      titleStyle: TextStyle.lerp(titleStyle, other.titleStyle, t)!,
      subtitleStyle: TextStyle.lerp(subtitleStyle, other.subtitleStyle, t)!,
      spotlightLabelStyle: TextStyle.lerp(spotlightLabelStyle, other.spotlightLabelStyle, t)!,
      spotlightValueStyle: TextStyle.lerp(spotlightValueStyle, other.spotlightValueStyle, t)!,
      spotlightVariationStyle: TextStyle.lerp(spotlightVariationStyle, other.spotlightVariationStyle, t)!,
      detailLabelStyle: TextStyle.lerp(detailLabelStyle, other.detailLabelStyle, t)!,
      detailValueStyle: TextStyle.lerp(detailValueStyle, other.detailValueStyle, t)!,
      linkStyle: TextStyle.lerp(linkStyle, other.linkStyle, t)!,
    );
  }
}
