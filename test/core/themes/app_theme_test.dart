import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/themes/app_colors.dart';
import 'package:real_calc/core/themes/app_theme.dart';

void main() {
  Widget createSut(ThemeMode themeMode) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const Scaffold(body: SizedBox()),
    );
  }

  group('AppTheme', () {
    testWidgets('disponibiliza os tokens corretos no tema claro', (
      tester,
    ) async {
      await tester.pumpWidget(createSut(ThemeMode.light));

      final context = tester.element(find.byType(Scaffold));
      final theme = Theme.of(context);
      final colors = theme.extension<AppColors>()!;

      expect(colors.background, AppColors.light.background);
      expect(colors.sheet, AppColors.light.sheet);
      expect(colors.elevated, AppColors.light.elevated);
      expect(colors.hairline, AppColors.light.hairline);
      expect(colors.textPrimary, AppColors.light.textPrimary);
      expect(colors.textSecondary, AppColors.light.textSecondary);
      expect(colors.textHint, AppColors.light.textHint);
      expect(colors.error, AppColors.light.error);
      expect(colors.scrim, AppColors.light.scrim);
      expect(colors.bandHome, AppColors.light.bandHome);
      expect(colors.onBandSoft, AppColors.light.onBandSoft);
      expect(colors.brandAmber, AppColors.light.brandAmber);
      expect(colors.onCalc, AppColors.light.onCalc);
      expect(theme.colorScheme.primary, AppColors.light.textPrimary);
      expect(tester.takeException(), isNull);
    });

    testWidgets('disponibiliza os tokens corretos no tema escuro', (
      tester,
    ) async {
      await tester.pumpWidget(createSut(ThemeMode.dark));

      final context = tester.element(find.byType(Scaffold));
      final theme = Theme.of(context);
      final colors = theme.extension<AppColors>()!;

      expect(colors.background, AppColors.dark.background);
      expect(colors.sheet, AppColors.dark.sheet);
      expect(colors.elevated, AppColors.dark.elevated);
      expect(colors.hairline, AppColors.dark.hairline);
      expect(colors.textPrimary, AppColors.dark.textPrimary);
      expect(colors.textSecondary, AppColors.dark.textSecondary);
      expect(colors.textHint, AppColors.dark.textHint);
      expect(colors.error, AppColors.dark.error);
      expect(colors.scrim, AppColors.dark.scrim);
      expect(colors.bandHome, AppColors.dark.bandHome);
      expect(colors.onBandSoft, AppColors.dark.onBandSoft);
      expect(colors.brandAmber, AppColors.dark.brandAmber);
      expect(colors.onCalc, AppColors.dark.onCalc);
      expect(theme.colorScheme.primary, AppColors.dark.textPrimary);
      expect(tester.takeException(), isNull);
    });

    test('AppColors suporta copyWith e interpolação', () {
      final changed = AppColors.light.copyWith(background: Colors.blue);
      expect(changed.background, Colors.blue);
      expect(changed.textPrimary, AppColors.light.textPrimary);

      final middle = AppColors.light.lerp(AppColors.dark, 0.5);
      expect(
        middle.background,
        Color.lerp(AppColors.light.background, AppColors.dark.background, 0.5),
      );
    });
  });
}
