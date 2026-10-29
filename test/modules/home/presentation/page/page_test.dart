import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/core/routes/app_routes.dart';
import 'package:real_calc/core/themes/app_colors.dart';
import 'package:real_calc/core/themes/app_theme.dart';
import 'package:real_calc/core/themes/calculator_palette.dart';
import 'package:real_calc/core/widgets/app_logo.dart';
import 'package:real_calc/core/widgets/theme_toggle_button.dart';
import 'package:real_calc/modules/home/presentation/components/calculator_list_item.dart';
import 'package:real_calc/modules/home/presentation/components/selic_band.dart';
import 'package:real_calc/modules/home/presentation/cubit/greeting_cubit.dart';
import 'package:real_calc/modules/home/presentation/cubit/selic_cubit.dart';
import 'package:real_calc/modules/home/presentation/page/page.dart';
import 'package:real_calc/modules/metrics/domain/entites/metric.dart';

class MockNavigator extends Mock implements IModularNavigator {}

class MockSelicCubit extends MockCubit<SelicState> implements SelicCubit {}

class MockGreetingCubit extends MockCubit<String> implements GreetingCubit {}

void main() {
  late MockNavigator navigator;
  late MockSelicCubit selicCubit;
  late MockGreetingCubit greetingCubit;

  final metric = Metric(
    anualRate: 13.75,
    variationPercent: 0.25,
    sparklineData: const [13.5, 13.75],
  );

  setUp(() {
    navigator = MockNavigator();
    Modular.navigatorDelegate = navigator;
    when(() => navigator.pushNamed(any())).thenAnswer((_) async => null);

    selicCubit = MockSelicCubit();
    whenListen(
      selicCubit,
      const Stream<SelicState>.empty(),
      initialState: SelicLoaded(metric),
    );
    when(() => selicCubit.retry()).thenAnswer((_) async {});

    greetingCubit = MockGreetingCubit();
    whenListen(
      greetingCubit,
      const Stream<String>.empty(),
      initialState: 'Bom dia',
    );
  });

  Future<void> pump(
    WidgetTester tester, {
    ThemeMode themeMode = ThemeMode.light,
    Size size = const Size(400, 900),
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: MultiBlocProvider(
          providers: [
            BlocProvider<SelicCubit>.value(value: selicCubit),
            BlocProvider<GreetingCubit>.value(value: greetingCubit),
          ],
          child: const HomePage(),
        ),
      ),
    );
  }

  group('HomePage', () {
    testWidgets('faixa com logo, tema e Selic, e ícones claros na barra de '
        'status', (tester) async {
      await pump(tester);

      expect(find.byType(AppLogo), findsOneWidget);
      expect(find.byType(ThemeToggleButton), findsOneWidget);
      expect(find.byType(SelicBand), findsOneWidget);
      expect(find.text('13,75%'), findsOneWidget);

      final band = tester.widget<ColoredBox>(
        find
            .ancestor(
              of: find.byType(AppLogo),
              matching: find.byType(ColoredBox),
            )
            .first,
      );
      expect(band.color, AppColors.light.bandHome);
      expect(tester.getTopLeft(find.byWidget(band)).dy, 0);

      final region = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
        find
            .ancestor(
              of: find.byType(AppLogo),
              matching: find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
            )
            .first,
      );
      expect(region.value.statusBarIconBrightness, Brightness.light);
    });

    testWidgets('saudação, título, lista e rodapé', (tester) async {
      await pump(tester);

      expect(find.text('Bom dia'), findsOneWidget);
      expect(find.text('O que vamos calcular hoje?'), findsOneWidget);
      expect(find.byType(CalculatorListItem), findsNWidgets(4));
      for (final (title, description) in [
        ('Financiamento', 'Prestação, prazo ou taxa'),
        ('Depósitos Regulares', 'Quanto você acumula todo mês'),
        ('Valor Futuro', 'Quanto rende um valor aplicado'),
        ('Correção de Valores', 'Pela inflação, juros ou poupança'),
      ]) {
        expect(find.text(title), findsOneWidget);
        expect(find.text(description), findsOneWidget);
      }
      expect(find.text(HomePage.footer), findsOneWidget);
    });

    testWidgets('itens de 72px com o quadrado na cor de cada calculadora', (
      tester,
    ) async {
      await pump(tester);

      for (final item in tester.widgetList<CalculatorListItem>(
        find.byType(CalculatorListItem),
      )) {
        final finder = find.byWidget(item);
        expect(tester.getSize(finder).height, greaterThanOrEqualTo(72));
        final tile = tester.widget<Container>(
          find.descendant(of: finder, matching: find.byType(Container)).at(1),
        );
        expect(
          (tile.decoration! as BoxDecoration).color,
          CalculatorPalette.of(item.kind).solid,
        );
      }
    });

    for (final (title, route) in [
      ('Financiamento', AppRoutes.financing),
      ('Depósitos Regulares', AppRoutes.deposits),
      ('Valor Futuro', AppRoutes.futureValue),
      ('Correção de Valores', AppRoutes.correction),
    ]) {
      testWidgets('tocar em qualquer parte de "$title" abre a calculadora', (
        tester,
      ) async {
        await pump(tester);

        final item = find.ancestor(
          of: find.text(title),
          matching: find.byType(CalculatorListItem),
        );
        await tester.ensureVisible(item);
        await tester.tapAt(tester.getTopRight(item) + const Offset(-4, 4));

        verify(() => navigator.pushNamed(route)).called(1);
      });
    }

    testWidgets('o TalkBack lê nome e descrição como um botão', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester);

      expect(
        tester.getSemantics(
          find.ancestor(
            of: find.text('Valor Futuro'),
            matching: find.byType(CalculatorListItem),
          ),
        ),
        isSemantics(
          label: 'Valor Futuro\nQuanto rende um valor aplicado',
          isButton: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('"Tentar de novo" na Selic chama o retry', (tester) async {
      whenListen(
        selicCubit,
        const Stream<SelicState>.empty(),
        initialState: SelicError(ServerErrorMessages.connectionError),
      );
      await pump(tester);

      await tester.tap(find.text('Tentar de novo'));
      verify(() => selicCubit.retry()).called(1);
    });

    for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('em 360dp e fonte em 130% no tema ${themeMode.name}, as '
          'descrições quebram sem cortar', (tester) async {
        await pump(
          tester,
          themeMode: themeMode,
          size: const Size(360, 780),
          textScale: 1.3,
        );

        expect(tester.takeException(), isNull);

        final description = find.text('Quanto você acumula todo mês');
        await tester.ensureVisible(description);
        final item = tester.getRect(
          find.ancestor(
            of: description,
            matching: find.byType(CalculatorListItem),
          ),
        );
        final text = tester.getRect(description);
        expect(text.height, greaterThan(13 * 1.3 * 1.5));
        expect(text.right, lessThanOrEqualTo(item.right));
      });
    }
  });
}
