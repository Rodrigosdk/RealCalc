import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/themes/app_colors.dart';
import 'package:real_calc/core/themes/app_image.dart';
import 'package:real_calc/core/themes/app_theme.dart';
import 'package:real_calc/core/themes/text_styles.dart';
import 'package:real_calc/core/widgets/app_logo.dart';

void main() {
  Future<void> pump(WidgetTester tester, AppLogo logo) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: Center(child: logo)),
    ),
  );

  String assetOf(WidgetTester tester) =>
      (tester.widget<SvgPicture>(find.byType(SvgPicture)).bytesLoader
              as SvgAssetLoader)
          .assetName;

  group('AppLogo', () {
    testWidgets('símbolo em brandAmber e nome com "Real" branco e "Calc" '
        'âmbar', (tester) async {
      await pump(tester, const AppLogo());

      final symbol = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(
        symbol.colorFilter,
        const ColorFilter.mode(Color(0xFFD4A657), BlendMode.srcIn),
      );

      final text = tester.widget<RichText>(
        find.descendant(
          of: find.byType(AppLogo),
          matching: find.byType(RichText),
        ),
      );
      final parts = <TextSpan>[];
      text.text.visitChildren((span) {
        if (span is TextSpan && span.text != null) parts.add(span);
        return true;
      });
      expect(text.text.style!.fontFamily, AppTextStyles.wordmark.fontFamily);
      expect(parts.map((part) => part.text), ['Real', 'Calc']);
      expect(parts.first.style!.color, Colors.white);
      expect(parts.last.style!.color, AppColors.dark.brandAmber);
    });

    testWidgets('usa o símbolo normal acima de 24px e o pequeno até 24px', (
      tester,
    ) async {
      await pump(tester, const AppLogo(symbolHeight: 32));
      expect(assetOf(tester), AppImage.appLogo);

      await pump(tester, const AppLogo(symbolHeight: 24));
      expect(assetOf(tester), AppImage.appLogoSmall);
    });

    testWidgets('sem o nome, mostra só o símbolo', (tester) async {
      await pump(tester, const AppLogo(showWordmark: false));

      expect(find.byType(SvgPicture), findsOneWidget);
      expect(find.byType(RichText), findsNothing);
    });

    testWidgets('é anunciado como "RealCalc"', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, const AppLogo());

      expect(find.bySemanticsLabel('RealCalc'), findsOneWidget);
      handle.dispose();
    });

    test('os caminhos dos logos não têm barra dupla', () {
      expect(AppImage.appLogo, 'assets/branding/app_icon.svg');
      expect(AppImage.appLogoSmall, 'assets/branding/app_icon_pequeno.svg');
    });
  });
}
