import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color sheet;
  final Color elevated;
  final Color hairline;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color error;
  final Color scrim;
  final Color bandHome;
  final Color onBandSoft;
  final Color brandAmber;
  final Color onCalc;

  const AppColors({
    required this.background,
    required this.sheet,
    required this.elevated,
    required this.hairline,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.error,
    required this.scrim,
    required this.bandHome,
    required this.onBandSoft,
    required this.brandAmber,
    required this.onCalc,
  });

  static const light = AppColors(
    background: Color(0xFFFFFFFF),
    sheet: Color(0xFFFFFFFF),
    elevated: Color(0xFFF2F2F5),
    hairline: Color(0xFFE8E8EE),
    textPrimary: Color(0xFF14121F),
    textSecondary: Color(0xFF57546A),
    textHint: Color(0xFF6E6B82),
    error: Color(0xFFC92A2A),
    scrim: Color(0x7314121F),
    bandHome: Color(0xFF14121F),
    onBandSoft: Color(0xFFB4B1C4),
    brandAmber: Color(0xFFD4A657),
    onCalc: Color(0xFFFFFFFF),
  );

  static const dark = AppColors(
    background: Color(0xFF100E19),
    sheet: Color(0xFF1B1926),
    elevated: Color(0xFF262333),
    hairline: Color(0x17FFFFFF),
    textPrimary: Color(0xFFF5F4FA),
    textSecondary: Color(0xFFB4B1C4),
    textHint: Color(0xFF918DA5),
    error: Color(0xFFFF8A8A),
    scrim: Color(0xA805040A),
    bandHome: Color(0xFF221F2E),
    onBandSoft: Color(0xFFB4B1C4),
    brandAmber: Color(0xFFD4A657),
    onCalc: Color(0xFFFFFFFF),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? sheet,
    Color? elevated,
    Color? hairline,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? error,
    Color? scrim,
    Color? bandHome,
    Color? onBandSoft,
    Color? brandAmber,
    Color? onCalc,
  }) {
    return AppColors(
      background: background ?? this.background,
      sheet: sheet ?? this.sheet,
      elevated: elevated ?? this.elevated,
      hairline: hairline ?? this.hairline,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      error: error ?? this.error,
      scrim: scrim ?? this.scrim,
      bandHome: bandHome ?? this.bandHome,
      onBandSoft: onBandSoft ?? this.onBandSoft,
      brandAmber: brandAmber ?? this.brandAmber,
      onCalc: onCalc ?? this.onCalc,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      sheet: Color.lerp(sheet, other.sheet, t)!,
      elevated: Color.lerp(elevated, other.elevated, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      error: Color.lerp(error, other.error, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      bandHome: Color.lerp(bandHome, other.bandHome, t)!,
      onBandSoft: Color.lerp(onBandSoft, other.onBandSoft, t)!,
      brandAmber: Color.lerp(brandAmber, other.brandAmber, t)!,
      onCalc: Color.lerp(onCalc, other.onCalc, t)!,
    );
  }
}
