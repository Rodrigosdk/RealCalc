import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'text_styles.dart';

class AppTheme {
  static ThemeData get darkTheme {
    const colors = AppColors.dark;
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      fontFamily: AppTextStyles.manropeFamily,

      // Cores base
      scaffoldBackgroundColor: colors.background,

      // ColorScheme do Material 3
      colorScheme: ColorScheme.dark(
        primary: colors.textPrimary,
        surface: colors.sheet,
        error: colors.error,
        onPrimary: colors.background,
        onSecondary: colors.background,
        onSurface: colors.textPrimary,
        onError: Colors.black,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.textPrimary,
        selectionColor: colors.textPrimary.withValues(alpha: 0.32),
        selectionHandleColor: colors.textPrimary,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.bandHome,
        contentTextStyle: AppTextStyles.detailLabel.copyWith(
          color: Colors.white,
        ),
        actionTextColor: colors.brandAmber,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),

      extensions: const [colors],
    );
  }

  static ThemeData get lightTheme {
    final base = darkTheme;
    const colors = AppColors.light;
    return base.copyWith(
      brightness: Brightness.light,
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme.light(
        primary: colors.textPrimary,
        surface: colors.sheet,
        error: colors.error,
        onPrimary: colors.onCalc,
        onSecondary: colors.onCalc,
        onSurface: colors.textPrimary,
        onError: colors.onCalc,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.textPrimary,
        selectionColor: colors.textPrimary.withValues(alpha: 0.32),
        selectionHandleColor: colors.textPrimary,
      ),
      snackBarTheme: base.snackBarTheme.copyWith(
        backgroundColor: colors.bandHome,
      ),
      extensions: const [colors],
    );
  }

  static SystemUiOverlayStyle systemUiOverlayStyle(AppColors colors) {
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: colors.background,
      systemNavigationBarIconBrightness: colors == AppColors.light
          ? Brightness.dark
          : Brightness.light,
      systemNavigationBarDividerColor: colors.background,
      systemNavigationBarContrastEnforced: false,
    );
  }
}
