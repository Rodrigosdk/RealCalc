import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_calc/core/routes/app_routes.dart';
import 'package:real_calc/core/seed_works/error.dart';
import 'package:real_calc/core/themes/color_tokens.dart';
import 'package:real_calc/core/themes/extensions/financing_forms_theme.dart';
import 'package:real_calc/core/themes/extensions/help_card_theme.dart';
import 'package:real_calc/core/themes/extensions/home_page_theme.dart';
import 'package:real_calc/core/themes/extensions/input_forms_result_card_theme.dart';
import 'package:real_calc/core/themes/extensions/menu_card_theme.dart';
import 'package:real_calc/core/themes/extensions/metric_card_theme.dart';
import 'package:real_calc/core/themes/extensions/options_bottom_forms_theme.dart';
import 'package:real_calc/core/themes/extensions/title_widget_theme.dart';
import 'package:real_calc/core/themes/text_styles.dart';
import 'package:real_calc/core/widgets/title_widget.dart';
import 'package:real_calc/modules/home/presentation/components/menu_card.dart';
import 'package:real_calc/modules/home/presentation/components/metric_card.dart';
import 'package:real_calc/modules/home/presentation/cubit/greeting_cubit.dart';
import 'package:real_calc/modules/home/presentation/cubit/selic_cubit.dart';
import 'package:real_calc/modules/home/presentation/page/page.dart';
import 'package:real_calc/modules/metrics/domain/entites/metric.dart';

class MockNavigator extends Mock implements IModularNavigator {}

class MockSelicCubit extends MockCubit<SelicState> implements SelicCubit {}

class MockGreetingCubit extends MockCubit<String> implements GreetingCubit {}

void main() {
  late MockNavigator mockNavigator;
  late MockSelicCubit mockSelicCubit;
  late MockGreetingCubit mockGreetingCubit;

  setUpAll(() {
    registerFallbackValue(SelicInitial());
  });

  setUp(() {
    mockNavigator = MockNavigator();
    Modular.navigatorDelegate = mockNavigator;

    mockSelicCubit = MockSelicCubit();
    whenListen(
      mockSelicCubit,
      const Stream<SelicState>.empty(),
      initialState: SelicLoaded(
        Metric(
          anualRate: 10.75,
          variationPercent: 0.25,
          sparklineData: const [10.5, 10.6, 10.75],
        ),
      ),
    );

    mockGreetingCubit = MockGreetingCubit();
    whenListen(
      mockGreetingCubit,
      const Stream<String>.empty(),
      initialState: 'Bom dia',
    );
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
            // ColorTokens.iconColor não existe no ColorTokens redefinido —
            // confirme o nome certo do token no seu projeto (ex: textSecondary).
            iconContainerColor: ColorTokens.textSecondary,
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
          MetricCardTheme(
            backgroundColor: ColorTokens.surface,
            borderColor: ColorTokens.accentAmber,
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
        child: MultiBlocProvider(
          providers: [
            BlocProvider<SelicCubit>.value(value: mockSelicCubit),
            BlocProvider<GreetingCubit>.value(value: mockGreetingCubit),
          ],
          child: const HomePage(),
        ),
      ),
    );
  }

  group('HomePage Widget Tests', () {
    testWidgets(
      'Deve renderizar os componentes base estruturais e textos principais',
      (tester) async {
        await tester.pumpWidget(buildTestableWidget());

        expect(find.byType(TitleWidget), findsOneWidget);
        expect(find.byType(MetricCard), findsOneWidget);
        expect(find.byType(MenuCard), findsNWidgets(4));
      },
    );

    testWidgets(
      'Deve navegar para a tela de depósitos regulares ao clicar no card correspondente',
      (tester) async {
        when(() => mockNavigator.pushNamed(any())).thenAnswer((_) async => null);
        await tester.pumpWidget(buildTestableWidget());

        final cardFinanciamento =
            find.widgetWithText(MenuCard, 'Depósitos Regulares');
        expect(cardFinanciamento, findsOneWidget);

        await tester.tap(cardFinanciamento);
        await tester.pumpAndSettle();

        verify(() => mockNavigator.pushNamed(AppRoutes.deposits)).called(1);
      },
    );

    testWidgets(
      'Deve navegar para a tela de valor futuro ao clicar no card correspondente',
      (tester) async {
        when(() => mockNavigator.pushNamed(any())).thenAnswer((_) async => null);
        await tester.pumpWidget(buildTestableWidget());

        final cardValorFuturo = find.widgetWithText(MenuCard, 'Valor Futuro');
        expect(cardValorFuturo, findsOneWidget);

        await tester.tap(cardValorFuturo);
        await tester.pumpAndSettle();

        verify(() => mockNavigator.pushNamed(AppRoutes.futureValue)).called(1);
      },
    );

    testWidgets(
      'Deve navegar para a tela de financiamento ao clicar no card correspondente',
      (tester) async {
        when(() => mockNavigator.pushNamed(any())).thenAnswer((_) async => null);
        await tester.pumpWidget(buildTestableWidget());

        final cardFinanciamento = find.widgetWithText(MenuCard, 'Financiamento');
        expect(cardFinanciamento, findsOneWidget);

        await tester.tap(cardFinanciamento);
        await tester.pumpAndSettle();

        verify(() => mockNavigator.pushNamed(AppRoutes.financing)).called(1);
      },
    );

    testWidgets(
      'Deve renderizar o divisor e os cards em duas colunas no mobile',
      (tester) async {
        await tester.pumpWidget(buildTestableWidget(width: 360.0));

        expect(find.byType(VerticalDivider), findsOneWidget);
        expect(find.byType(MenuCard), findsNWidgets(4));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Deve manter os cards e o divisor em telas largas',
      (tester) async {
        await tester.pumpWidget(buildTestableWidget(width: 1024.0));

        expect(find.byType(VerticalDivider), findsOneWidget);
        expect(find.byType(MenuCard), findsNWidgets(4));
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('HomePage — estados do card de métrica (SelicCubit)', () {
    testWidgets('mostra o skeleton quando o estado é SelicLoading', (tester) async {
      whenListen(
        mockSelicCubit,
        const Stream<SelicState>.empty(),
        initialState: SelicLoading(),
      );

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(MetricCard), findsOneWidget);
      // Não afirmamos o construtor exato (.loading) aqui porque MetricCard
      // não expõe publicamente qual variante está ativa — só confirmamos
      // que nenhum valor numérico da Selic aparece nesse estado.
      expect(find.textContaining('%'), findsNothing);
    });

    testWidgets('mostra o valor quando o estado é SelicLoaded', (tester) async {
      final metric = Metric(
        anualRate: 10.75,
        variationPercent: 0.25,
        sparklineData: const [10.5, 10.6, 10.75],
      );
      whenListen(
        mockSelicCubit,
        const Stream<SelicState>.empty(),
        initialState: SelicLoaded(metric),
      );

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      expect(find.textContaining('10,75'), findsOneWidget);
    });

    testWidgets(
      'mostra a mensagem de erro quando o estado é SelicError',
      (tester) async {
        whenListen(
          mockSelicCubit,
          const Stream<SelicState>.empty(),
          initialState: const SelicError(
             _FakeErrorMessage.noConnection,
          ),
        );

        await tester.pumpWidget(buildTestableWidget());
        await tester.pump();

        expect(find.text('Sem conexão'), findsOneWidget);
      },
    );
  });
}

enum _FakeErrorMessage implements ErrorMessages {
  noConnection('Sem conexão');

  const _FakeErrorMessage(this.message);

  @override
  final String message;
}