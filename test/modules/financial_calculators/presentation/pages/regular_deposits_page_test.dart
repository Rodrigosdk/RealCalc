import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/themes/app_theme.dart';
import 'package:real_calc/core/themes/calculator_palette.dart';
import 'package:real_calc/core/widgets/bottom_action_bar.dart';
import 'package:real_calc/core/widgets/calculator_band/calculator_band.dart';
import 'package:real_calc/core/widgets/field_list/field_row.dart';
import 'package:real_calc/core/widgets/result_details/result_details.dart';
import 'package:real_calc/modules/financial_calculators/domain/enum/financial_calculation_target.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/forms/financing_form_cubit.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/regular_deposits/regular_deposits_cubit.dart';
import 'package:real_calc/modules/financial_calculators/presentation/pages/regular_deposits_page.dart';
import 'package:real_calc/modules/financial_calculators/use_case/regular_deposits/calculate_deposit.dart';

void main() {
  late RegularDepositsCubit depositsCubit;
  late FinancingFormCubit formCubit;

  setUp(() {
    depositsCubit = RegularDepositsCubit(CalculateDeposit());
    formCubit = FinancingFormCubit();
  });

  tearDown(() async {
    await depositsCubit.close();
    await formCubit.close();
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
            BlocProvider.value(value: depositsCubit),
            BlocProvider.value(value: formCubit),
          ],
          child: const RegularDepositsPage(),
        ),
      ),
    );
  }

  Finder row(FinancialCalculationTarget field) => find.byKey(ValueKey(field));

  Future<void> type(
    WidgetTester tester,
    FinancialCalculationTarget field,
    String text,
  ) async {
    await tester.enterText(
      find.descendant(of: row(field), matching: find.byType(TextField)),
      text,
    );
    await tester.pump();
  }

  Future<void> fillExample(WidgetTester tester) async {
    await type(tester, FinancialCalculationTarget.initialValue, '20000');
    await type(tester, FinancialCalculationTarget.periods, '24');
    await type(tester, FinancialCalculationTarget.interestRate, '080');
  }

  Finder inBand(String text) => find.descendant(
    of: find.byType(CalculatorBand),
    matching: find.text(text),
  );

  group('RegularDepositsPage', () {
    testWidgets('monta a tela na cor dos Depósitos', (tester) async {
      await pump(tester);

      expect(find.text('Depósitos Regulares'), findsOneWidget);
      expect(find.byType(FieldRow), findsNWidgets(4));
      for (final label in [
        'Depósito',
        'Prazo',
        'Taxa de juros',
        'Valor final',
      ]) {
        expect(find.text(label), findsOneWidget);
      }
      expect(find.text('todo mês'), findsOneWidget);
      expect(inBand('e descubra o quarto'), findsOneWidget);

      final band = tester.widget<ColoredBox>(
        find
            .descendant(
              of: find.byType(CalculatorBand),
              matching: find.byType(ColoredBox),
            )
            .first,
      );
      expect(band.color, CalculatorPalette.of(CalculatorKind.deposits).solid);
    });

    testWidgets('com três campos, pergunta pelo valor final', (tester) async {
      await pump(tester);
      await fillExample(tester);

      expect(inBand('Você quer descobrir'), findsOneWidget);
      expect(inBand('o valor final'), findsOneWidget);
    });

    testWidgets('200 / 24 / 0,80%: valor final, depositado, rendimento, '
        'taxa anual e barra 90/10', (tester) async {
      await pump(tester);
      await fillExample(tester);

      await tester.tap(find.text('Calcular'));
      await tester.pumpAndSettle();

      expect(inBand('5.310,78'), findsOneWidget);
      expect(formCubit.finalValue.text, '5.310,78');
      expect(find.text('Do valor final'), findsOneWidget);
      expect(find.textContaining('4.800,00'), findsOneWidget);
      expect(find.textContaining('510,78'), findsNWidgets(2));
      expect(find.text('10,03% a.a.'), findsOneWidget);
      expect(find.text('Depositado 90%'), findsOneWidget);
      expect(find.text('Rendimento 10%'), findsOneWidget);
    });

    testWidgets('calcula o depósito a partir do valor final', (tester) async {
      await pump(tester);
      await type(tester, FinancialCalculationTarget.periods, '24');
      await type(tester, FinancialCalculationTarget.interestRate, '080');
      await type(tester, FinancialCalculationTarget.finalValue, '531078');

      await tester.tap(find.text(FieldRow.calculateText));
      await tester.pumpAndSettle();

      expect(inBand('Para juntar R\$\u00A05.310,78, guarde por mês'), findsOne);
      expect(inBand('200,00'), findsOneWidget);
    });

    testWidgets('com menos de três campos, mostra o aviso', (tester) async {
      await pump(tester);
      await type(tester, FinancialCalculationTarget.initialValue, '20000');

      expect(find.text('Faltam dados para calcular'), findsOneWidget);
      expect(
        find.text(
          'Preencha o prazo, a taxa de juros ou o valor final. '
          'O campo que ficar em branco é calculado.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('limpar e desfazer', (tester) async {
      await pump(tester);
      await fillExample(tester);
      await tester.tap(find.text('Calcular'));
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel(CalculatorBand.clearLabel));
      await tester.pumpAndSettle();
      expect(find.byType(ResultDetails), findsNothing);

      await tester.tap(find.text('Desfazer'));
      await tester.pumpAndSettle();
      expect(inBand('5.310,78'), findsOneWidget);
    });

    for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('em 360dp com fonte em 130% no tema ${themeMode.name}', (
        tester,
      ) async {
        await pump(
          tester,
          themeMode: themeMode,
          size: const Size(360, 780),
          textScale: 1.3,
        );
        await fillExample(tester);
        await tester.tap(find.text('Calcular'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(inBand('5.310,78'), findsOneWidget);
      });
    }

    testWidgets('o teclado não cobre o campo em foco', (tester) async {
      await pump(tester, size: const Size(360, 700));

      await tester.showKeyboard(
        find.descendant(
          of: row(FinancialCalculationTarget.finalValue),
          matching: find.byType(TextField),
        ),
      );
      tester.view.viewInsets = const FakeViewPadding(bottom: 320);
      await tester.pumpAndSettle();

      final field = tester.getRect(row(FinancialCalculationTarget.finalValue));
      final bar = tester.getRect(find.byType(BottomActionBar));
      expect(bar.bottom, 700 - 320);
      expect(field.bottom, lessThanOrEqualTo(bar.top));
    });
  });
}
