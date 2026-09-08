import 'package:flutter/material.dart';
import 'package:real_calc/core/themes/extensions/help_card_theme.dart';
import 'package:real_calc/core/themes/extensions/highlight_card_theme.dart';
import 'package:real_calc/core/themes/extensions/menu_card_theme.dart';
import 'package:real_calc/core/themes/extensions/options_bottom_forms_theme.dart';
import 'color_tokens.dart';
import 'extensions/financing_forms_theme.dart';
import 'extensions/home_page_theme.dart';
import 'extensions/input_forms_result_card_theme.dart';
import 'extensions/metric_card_theme.dart';
import 'extensions/page_header_theme.dart';
import 'extensions/title_widget_theme.dart';
import 'text_styles.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,

      // Cores base
      scaffoldBackgroundColor: ColorTokens.background,

      // ColorScheme do Material 3
      colorScheme: const ColorScheme.dark(
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
        actionsIconTheme: const IconThemeData(color: ColorTokens.accentAmber),
        titleTextStyle: AppTextStyles.headlineMedium,
        iconTheme: IconThemeData(color: ColorTokens.iconColor),
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
        fillColor: ColorTokens.surface,
        hintStyle: TextStyle(color: ColorTokens.textHint),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: ColorTokens.border, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: ColorTokens.accentAmber,
            width: 1.5,
          ),
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
          backgroundColor: ColorTokens.surface,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // BottomNavigationBar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ColorTokens.background,
        selectedItemColor: ColorTokens.surface,
        unselectedItemColor: ColorTokens.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ColorTokens.surface,
        contentTextStyle: const TextStyle(color: ColorTokens.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),

      extensions: [
        const OptionsBottomFormsTheme(
          calculateButtonBackground: ColorTokens.accentAmber,
          calculateButtonForeground: Colors.white,
          actionButtonBackground: ColorTokens.surface,
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
          backgroundColor: ColorTokens.surface,
          borderColor: ColorTokens.accentAmber,
          iconBackgroundColor: ColorTokens.surface,
          iconColor: Colors.white,
        ),
        // app_theme.dart (dentro de extensions:)
        InputFormsResultCardTheme(
          suffixIconColor: ColorTokens.textHint,
          helperTextStyle: AppTextStyles.inputHelperText,
        ),

        HomePageTheme(
          scaffoldBackgroundColor: ColorTokens.background,
          cardColor: ColorTokens.background,
          iconContainerColor: ColorTokens.iconColor,
          appNameStyle: AppTextStyles.appName,
          sectionHeaderStyle: AppTextStyles.sectionHeader,
          historyItemStyle: AppTextStyles.historyItem,
          historyItemIconColor: Colors.white,
          historyItemArrowColor: Colors.white,
          bottomNavBackgroundColor: ColorTokens.surface,
          bottomNavSelectedColor: ColorTokens.accentAmber,
          bottomNavUnselectedColor: Colors.white,
          lineColor: ColorTokens.border,
        ),
        FinancingFormsTheme(
          iconColor: ColorTokens.iconColor,
          progressIndicatorColor: ColorTokens.accentAmber,
          errorBackgroundColor: ColorTokens.errorContainerBg,
          errorBorderColor: ColorTokens.errorContainerBorder,
          errorTextStyle: AppTextStyles.errorBannerText,
        ),
        HighlightCardTheme(
          gradientColors: [
            ColorTokens.surface,
            ColorTokens.accentAmber.withValues(alpha: 0.32),
          ],
          titleStyle: AppTextStyles.menuCardTitleFeatured,
          subtitleStyle: AppTextStyles.menuCardDescriptionFeatured,
          buttonBackgroundColor: Colors.white,
          buttonForegroundColor: Colors.white,
          buttonTextStyle: AppTextStyles.menuCardDescriptionFeatured,
        ),

        MenuCardTheme(
          titleStyle: AppTextStyles.menuCardTitle,
          descriptionStyle: AppTextStyles.menuCardDescription,
          titleStyleCompact: AppTextStyles.menuCardTitleCompact,
          descriptionStyleCompact: AppTextStyles.menuCardDescriptionCompact,
          titleStyleFeatured: AppTextStyles.menuCardTitleFeatured,
          descriptionStyleFeatured: AppTextStyles.menuCardDescriptionFeatured,
          featuredBorderColor: ColorTokens.accentAmber,
          disabledLabelColor: ColorTokens.textHint,
          disabledTextStyle: AppTextStyles.menuCardDescription,
        ),

        MetricCardTheme(
          backgroundColor: ColorTokens.surface,
          borderColor: ColorTokens.accentAmber.withValues(alpha: 0.25),
          labelStyle: AppTextStyles.metricLabel,
          valueStyle: AppTextStyles.metricValue,
          valueUnitStyle: AppTextStyles.metricLabel,
          captionStyle: AppTextStyles.metricCaption,
          variationTextStyle: AppTextStyles.stateBadge,
          variationPositiveColor: ColorTokens.success,
          variationNegativeColor: ColorTokens.error,
          variationNeutralColor: ColorTokens.textSecondary,
          skeletonColor: ColorTokens.surfaceVariant,
          
        ),
        PageHeaderTheme(
          backgroundColor: ColorTokens.background,
          iconColor: ColorTokens.textSecondary,
          titleStyle: AppTextStyles.headlineMedium.copyWith(
            color: ColorTokens.textPrimary,
          ),
        ),
      ],
    );
  }

  static ThemeData get lightTheme {
    return darkTheme;
  }
}
