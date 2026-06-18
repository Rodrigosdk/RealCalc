import 'package:flutter/material.dart';
import 'package:real_calc/core/themes/extensions/help_card_theme.dart';
import 'package:real_calc/core/themes/extensions/highlight_card_theme.dart';
import 'package:real_calc/core/themes/extensions/menu_card_theme.dart';
import 'package:real_calc/core/themes/extensions/options_bottom_forms_theme.dart';
import 'color_tokens.dart';
import 'extensions/financing_forms_theme.dart';
import 'extensions/home_page_theme.dart';
import 'extensions/input_forms_result_card_theme.dart';
import 'extensions/title_widget_theme.dart';
import 'text_styles.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,

      // Cores base
      primaryColor: ColorTokens.primary,
      scaffoldBackgroundColor: ColorTokens.background,

      // ColorScheme do Material 3
      colorScheme: const ColorScheme.dark(
        primary: ColorTokens.primary,
        secondary: ColorTokens.primaryVariant,
        surface: ColorTokens.surface,
        error: ColorTokens.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: ColorTokens.textPrimary,
        onError: Colors.black,
      ),

      // AppBar global
      appBarTheme: AppBarTheme(
        backgroundColor: ColorTokens.surface,
        elevation: 0,
        centerTitle: true,
        actionsIconTheme: const IconThemeData(color: ColorTokens.accent),
        titleTextStyle: AppTextStyles.headlineMedium,
        iconTheme: IconThemeData(color: ColorTokens.primary),
      ),

      // TextTheme
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        labelLarge: AppTextStyles.labelLarge,
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColorTokens.surfaceDark,
        hintStyle: TextStyle(color: ColorTokens.textHint),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: ColorTokens.border, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: ColorTokens.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: ColorTokens.error, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: ColorTokens.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
      ),

      // Botões elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorTokens.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // BottomNavigationBar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ColorTokens.surface,
        selectedItemColor: ColorTokens.primary,
        unselectedItemColor: ColorTokens.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ColorTokens.surfaceVariant,
        contentTextStyle: const TextStyle(color: ColorTokens.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),

      extensions: [
        const OptionsBottomFormsTheme(
          calculateButtonBackground: ColorTokens.accent,
          calculateButtonForeground: Colors.white,
          actionButtonBackground: ColorTokens.surfaceVariant,
          actionButtonForeground: ColorTokens.textSecondary,
        ),
        TitleWidgetTheme(
          titleStyle: AppTextStyles.headlineMedium.copyWith(
            color: ColorTokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          subtitleStyle: AppTextStyles.bodyMedium.copyWith(
            color: ColorTokens.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        HelpCardTheme(
          messageStyle: AppTextStyles.helpCardMessage,
          backgroundColor: ColorTokens.helpCardBackground,
          borderColor: ColorTokens.accent,
          iconBackgroundColor: ColorTokens.accent,
          iconColor: Colors.white,
        ),
        // app_theme.dart (dentro de extensions:)
        InputFormsResultCardTheme(
          suffixIconColor: ColorTokens.textHint,
          helperTextStyle: AppTextStyles.inputHelperText,
        ),

        HomePageTheme(
          scaffoldBackgroundColor: ColorTokens.homeScaffoldBackground,
          cardColor: ColorTokens.homeCard,
          primaryBlue: ColorTokens.accent, // ← era homePrimaryBlue
          iconContainerColor: ColorTokens.homeIconContainer,
          appNameStyle: AppTextStyles.appName,
          sectionHeaderStyle: AppTextStyles.sectionHeader,
          historyItemStyle: AppTextStyles.historyItem,
          historyItemIconColor: Colors.white,
          historyItemArrowColor: Colors.white,
          bottomNavBackgroundColor: ColorTokens.bottomNavBackground,
          bottomNavSelectedColor: ColorTokens.accent,
          bottomNavUnselectedColor: Colors.white,
        ),
        FinancingFormsTheme(
          iconColor: ColorTokens.accent,
          progressIndicatorColor: ColorTokens.accent,
          errorBackgroundColor: ColorTokens.errorContainerBg,
          errorBorderColor: ColorTokens.errorContainerBorder,
          errorTextStyle: AppTextStyles.errorBannerText,
        ),
        HighlightCardTheme(
          gradientColors: [ColorTokens.gradientStart, ColorTokens.gradientEnd],
          titleStyle: AppTextStyles.highlightCardTitle,
          subtitleStyle: AppTextStyles.highlightCardSubtitle,
          buttonBackgroundColor: Colors.white,
          buttonForegroundColor: Colors.white,
          buttonTextStyle: AppTextStyles.highlightCardButton,
        ),

        MenuCardTheme(
          titleStyle: AppTextStyles.menuCardTitle,
          descriptionStyle: AppTextStyles.menuCardDescription,
          iconContainerColor: ColorTokens.menuCardIconContainer,
        ),
      ],
    );
  }

  static ThemeData get lightTheme {
    return darkTheme;
  }
}
