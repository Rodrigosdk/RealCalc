import 'package:flutter/material.dart';

class HomePageTheme extends ThemeExtension<HomePageTheme> {
  final Color scaffoldBackgroundColor;
  final Color cardColor;
  final Color iconContainerColor;
  final TextStyle appNameStyle;
  final TextStyle sectionHeaderStyle;
  final TextStyle historyItemStyle;
  final Color historyItemIconColor;
  final Color historyItemArrowColor;
  final Color bottomNavBackgroundColor;
  final Color bottomNavSelectedColor;
  final Color bottomNavUnselectedColor;
  final Color lineColor;

  const HomePageTheme({
    required this.scaffoldBackgroundColor,
    required this.cardColor,
    required this.iconContainerColor,
    required this.appNameStyle,
    required this.sectionHeaderStyle,
    required this.historyItemStyle,
    required this.historyItemIconColor,
    required this.historyItemArrowColor,
    required this.bottomNavBackgroundColor,
    required this.bottomNavSelectedColor,
    required this.bottomNavUnselectedColor,
    required this.lineColor,
  });

  @override
  ThemeExtension<HomePageTheme> copyWith({
    Color? scaffoldBackgroundColor,
    Color? cardColor,
    Color? primaryBlue,
    TextStyle? appNameStyle,
    TextStyle? sectionHeaderStyle,
    TextStyle? historyItemStyle,
    Color? historyItemIconColor,
    Color? historyItemArrowColor,
    Color? bottomNavBackgroundColor,
    Color? bottomNavSelectedColor,
    Color? bottomNavUnselectedColor,
    Color? iconContainerColor,
    Color? lineColor,
  }) {
    return HomePageTheme(
      scaffoldBackgroundColor: scaffoldBackgroundColor ?? this.scaffoldBackgroundColor,
      cardColor: cardColor ?? this.cardColor,
      iconContainerColor: iconContainerColor ?? this.iconContainerColor,
      appNameStyle: appNameStyle ?? this.appNameStyle,
      sectionHeaderStyle: sectionHeaderStyle ?? this.sectionHeaderStyle,
      historyItemStyle: historyItemStyle ?? this.historyItemStyle,
      historyItemIconColor: historyItemIconColor ?? this.historyItemIconColor,
      historyItemArrowColor: historyItemArrowColor ?? this.historyItemArrowColor,
      bottomNavBackgroundColor: bottomNavBackgroundColor ?? this.bottomNavBackgroundColor,
      bottomNavSelectedColor: bottomNavSelectedColor ?? this.bottomNavSelectedColor,
      bottomNavUnselectedColor: bottomNavUnselectedColor ?? this.bottomNavUnselectedColor,
      lineColor: lineColor ?? this.lineColor,
    );
  }

  @override
  ThemeExtension<HomePageTheme> lerp(ThemeExtension<HomePageTheme>? other, double t) {
    if (other is! HomePageTheme) return this;
    return HomePageTheme(
      scaffoldBackgroundColor: Color.lerp(scaffoldBackgroundColor, other.scaffoldBackgroundColor, t)!,
      cardColor: Color.lerp(cardColor, other.cardColor, t)!,
      iconContainerColor: Color.lerp(iconContainerColor, other.iconContainerColor, t)!,
      appNameStyle: TextStyle.lerp(appNameStyle, other.appNameStyle, t)!,
      sectionHeaderStyle: TextStyle.lerp(sectionHeaderStyle, other.sectionHeaderStyle, t)!,
      historyItemStyle: TextStyle.lerp(historyItemStyle, other.historyItemStyle, t)!,
      historyItemIconColor: Color.lerp(historyItemIconColor, other.historyItemIconColor, t)!,
      historyItemArrowColor: Color.lerp(historyItemArrowColor, other.historyItemArrowColor, t)!,
      bottomNavBackgroundColor: Color.lerp(bottomNavBackgroundColor, other.bottomNavBackgroundColor, t)!,
      bottomNavSelectedColor: Color.lerp(bottomNavSelectedColor, other.bottomNavSelectedColor, t)!,
      bottomNavUnselectedColor: Color.lerp(bottomNavUnselectedColor, other.bottomNavUnselectedColor, t)!,
      lineColor: Color.lerp(lineColor, other.lineColor, t)!,
    );
  }
}