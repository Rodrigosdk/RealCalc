import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_tokens.dart';

class AppTextStyles {
  static final TextStyle _base = GoogleFonts.manrope();
  static final TextStyle _baseWhite = _base.copyWith(color: Colors.white);

  // Headlines
  static final TextStyle headlineLarge = _base.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );
  static final TextStyle headlineMedium = _baseWhite.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  // Body
  static final TextStyle bodyLarge = _base.copyWith(fontSize: 16);
  static final TextStyle bodyMedium = _base.copyWith(fontSize: 14);
  static final TextStyle labelLarge = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // Componentes
  static final TextStyle helpCardMessage = _base.copyWith(
    fontSize: 14,
    color: ColorTokens.textPrimary,
    fontWeight:  FontWeight.w400
  );
  static final TextStyle inputHelperText = _base.copyWith(
    fontSize: 12,
    color: ColorTokens.textHint,
  );
  static final TextStyle errorBannerText = _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: ColorTokens.error,
  );

  // HighlightCard
  static final TextStyle highlightCardTitle = _baseWhite.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );
  static final TextStyle highlightCardSubtitle = _baseWhite.copyWith(
    fontSize: 14,
  );
  static final TextStyle highlightCardButton = _baseWhite.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  // MenuCard
  static final TextStyle menuCardTitle = _baseWhite.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.bold,
  );
  static final TextStyle menuCardTitleCompact = _baseWhite.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.bold,
  );
  static final TextStyle menuCardDescription = _baseWhite.copyWith(
    fontSize: 10,
    height: 1.1,
  );
  static final TextStyle menuCardDescriptionCompact = _baseWhite.copyWith(
    fontSize: 9,
    height: 1.1,
  );

  // Home
  static final TextStyle appName = _baseWhite.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
  static final TextStyle sectionHeader = _baseWhite.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  );
  static final TextStyle historyItem = _baseWhite.copyWith(fontSize: 14);
}
