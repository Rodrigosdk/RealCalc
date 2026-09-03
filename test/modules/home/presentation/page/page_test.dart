import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_calc/core/routes/app_routes.dart';
import 'package:real_calc/core/themes/color_tokens.dart';
import 'package:real_calc/core/themes/extensions/financing_forms_theme.dart';
import 'package:real_calc/core/themes/extensions/help_card_theme.dart';
import 'package:real_calc/core/themes/extensions/highlight_card_theme.dart';
import 'package:real_calc/core/themes/extensions/home_page_theme.dart';
import 'package:real_calc/core/themes/extensions/input_forms_result_card_theme.dart';
import 'package:real_calc/core/themes/extensions/menu_card_theme.dart';
import 'package:real_calc/core/themes/extensions/options_bottom_forms_theme.dart';
import 'package:real_calc/core/themes/extensions/title_widget_theme.dart';
import 'package:real_calc/core/themes/text_styles.dart';
import 'package:real_calc/core/widgets/title_widget.dart';
import 'package:real_calc/modules/home/presentation/components/highlight_card.dart';
import 'package:real_calc/modules/home/presentation/components/menu_card.dart';
import 'package:real_calc/modules/home/presentation/page/page.dart';

class MockNavigator extends Mock implements IModularNavigator {}

void main() {
  late MockNavigator mockNavigator;

  setUp(() {
    mockNavigator = MockNavigator();
    Modular.navigatorDelegate = mockNavigator;
  });

  Widget buildTestableWidget({double width = 360.0, double height = 800.0}) {
    return MaterialApp(
      theme: ThemeData(
        extensions: [
          OptionsBottomFormsTheme(
            calculateButtonBackground: ColorTokens.accentAmber,
            calculateButtonForeground: Colors.white,
            actionButtonBackground: ColorTokens.surface,
            actionButtonForeground: ColorTokens.textSecondary,
          ),
          TitleWidgetTheme(
            titleStyle: AppTextStyles.headlineMedium,
            subtitleStyle: AppTextStyles.bodyMedium,
          ),
          HelpCardTheme(
            messageStyle: AppTextStyles.helpCardMessage,
            backgroundColor: ColorTokens.surface,
            borderColor: ColorTokens.accentAmber,
            iconBackgroundColor: ColorTokens.accentAmber,
            iconColor: Colors.white,
          ),
          InputFormsResultCardTheme(
            suffixIconColor: ColorTokens.textHint,
            helperTextStyle: AppTextStyles.inputHelperText,
          ),
          HomePageTheme(
            scaffoldBackgroundColor: ColorTokens.background,
            cardColor: ColorTokens.surface,
            iconContainerColor: ColorTokens.iconColor,
            appNameStyle: AppTextStyles.appName,
            sectionHeaderStyle: AppTextStyles.sectionHeader,
            historyItemStyle: AppTextStyles.historyItem,
            historyItemIconColor: Colors.white,
            historyItemArrowColor: Colors.white,
            bottomNavBackgroundColor: ColorTokens.surface,
            bottomNavSelectedColor: ColorTokens.accentAmber,
            bottomNavUnselectedColor: Colors.white,
            lineColor: ColorTokens.surface,
          ),
          FinancingFormsTheme(
            iconColor: ColorTokens.accentAmber,
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
        ],
      ),
      home: MediaQuery(
        data: MediaQueryData(size: Size(width, height)),
        child: const HomePage(),
      ),
    );
  }

  group('HomePage Widget Tests', () {
    testWidgets('Deve renderizar os componentes base estruturais e textos principais', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('RealCalc'), findsOneWidget);
      expect(find.byIcon(Icons.calculate), findsOneWidget);
      expect(find.byType(TitleWidget), findsOneWidget);
      expect(find.byType(HighlightCard), findsOneWidget);
      expect(find.byType(MenuCard), findsNWidgets(4));
      expect(find.text('ACESSO RÁPIDO'), findsOneWidget);
      expect(find.text('Último cálculo: Financiamento Imob.'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('INÍCIO'), findsOneWidget);
      expect(find.text('HISTÓRICO'), findsOneWidget);
      expect(find.text('AJUSTES'), findsOneWidget);
    });

        testWidgets('Deve navegar para a tela de depósitos regulares ao clicar no card correspondente', (tester) async {
      when(() => mockNavigator.pushNamed(any())).thenAnswer((_) async => null);
      await tester.pumpWidget(buildTestableWidget());

      final cardFinanciamento = find.widgetWithText(MenuCard, 'Depósitos Regulares');
      expect(cardFinanciamento, findsOneWidget);

      await tester.tap(cardFinanciamento);
      await tester.pumpAndSettle();

      verify(() => mockNavigator.pushNamed(AppRoutes.deposits)).called(1);
    });

    testWidgets('Deve navegar para a tela de valor futuro ao clicar no card correspondente', (tester) async {
      when(() => mockNavigator.pushNamed(any())).thenAnswer((_) async => null);
      await tester.pumpWidget(buildTestableWidget());

      final cardFinanciamento = find.widgetWithText(MenuCard, 'Valor Futuro');
      expect(cardFinanciamento, findsOneWidget);

      await tester.tap(cardFinanciamento);
      await tester.pumpAndSettle();

      verify(() => mockNavigator.pushNamed(AppRoutes.futureValue)).called(1);
    });

    testWidgets('Deve navegar para a tela de financiamento ao clicar no card correspondente', (tester) async {
      when(() => mockNavigator.pushNamed(any())).thenAnswer((_) async => null);
      await tester.pumpWidget(buildTestableWidget());

      final cardFinanciamento = find.widgetWithText(MenuCard, 'Financiamento');
      expect(cardFinanciamento, findsOneWidget);

      await tester.tap(cardFinanciamento);
      await tester.pumpAndSettle();

      verify(() => mockNavigator.pushNamed(AppRoutes.financing)).called(1);
    });

    testWidgets('Deve renderizar o divisor e os cards em duas colunas no mobile', (tester) async {
      await tester.pumpWidget(buildTestableWidget(width: 360.0));

      expect(find.byType(VerticalDivider), findsOneWidget);
      expect(find.byType(MenuCard), findsNWidgets(4));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Deve manter os cards e o divisor em telas largas', (tester) async {
      await tester.pumpWidget(buildTestableWidget(width: 1024.0));

      expect(find.byType(VerticalDivider), findsOneWidget);
      expect(find.byType(MenuCard), findsNWidgets(4));
      expect(tester.takeException(), isNull);
    });
  });
}