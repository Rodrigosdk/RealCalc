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
import 'package:real_calc/modules/home/components/highlight_card.dart';
import 'package:real_calc/modules/home/components/menu_card.dart';
import 'package:real_calc/modules/home/page/page.dart';

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
            iconContainerColor: ColorTokens.iconColor,
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

    testWidgets('Deve calcular largura do card para Mobile quando a tela for menor que 600px', (tester) async {
      await tester.pumpWidget(buildTestableWidget(width: 360.0));

      final gridViewFinder = find.byType(GridView);
      final GridView gridViewWidget = tester.widget(gridViewFinder);
      final delegate = gridViewWidget.gridDelegate as SliverGridDelegateWithMaxCrossAxisExtent;

      expect(delegate.maxCrossAxisExtent, closeTo(98.66, 0.01));
    });

    testWidgets('Deve cravar largura máxima do card em 180px quando for Desktop/Web (width > 600px)', (tester) async {
      await tester.pumpWidget(buildTestableWidget(width: 1024.0));

      final gridViewFinder = find.byType(GridView);
      final GridView gridViewWidget = tester.widget(gridViewFinder);
      final delegate = gridViewWidget.gridDelegate as SliverGridDelegateWithMaxCrossAxisExtent;

      expect(delegate.maxCrossAxisExtent, 180.0);
    });
  });
}