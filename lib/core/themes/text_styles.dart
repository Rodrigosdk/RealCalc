import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'color_tokens.dart';

class AppTextStyles {
  static TextStyle headlineLarge = GoogleFonts.manrope(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static TextStyle headlineMedium = GoogleFonts.manrope(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle helpCardMessage = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: ColorTokens.textPrimary,
  );

  // core/themes/text_styles.dart (adicione o novo estilo)
static const TextStyle inputHelperText = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w400,
  color: ColorTokens.textHint,
);

  static TextStyle bodyLarge = GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static TextStyle bodyMedium = GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static TextStyle labelLarge = GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

   static  TextStyle errorBannerText = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: ColorTokens.error, // ou defina cor de erro específica
  );
}
