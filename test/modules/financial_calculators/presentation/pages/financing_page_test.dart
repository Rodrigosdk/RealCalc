import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/services/result_sharer.dart';
import 'package:real_calc/core/themes/app_theme.dart';
import 'package:real_calc/core/widgets/bottom_action_bar.dart';
import 'package:real_calc/core/widgets/calculator_band/calculator_band.dart';
import 'package:real_calc/core/widgets/field_list/field_row.dart';
import 'package:real_calc/core/widgets/form_notice.dart';
import 'package:real_calc/core/widgets/result_details/result_details.dart';
import 'package:real_calc/modules/financial_calculators/domain/enum/financial_calculation_target.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/financing/financing_cubit.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/forms/financing_form_cubit.dart';
import 'package:real_calc/modules/financial_calculators/presentation/pages/financing_page.dart';
import 'package:real_calc/modules/financial_calculators/use_case/financing/calculate_financing.dart';

class _FakeSharer implements ResultSharer {
  final shared = <(String, Rect?)>[];

  @override
  Future<void> share(String text, {Rect? origin}) async =>
      shared.add((text, origin));
}

void main() {
  late _FakeSharer sharer;
  late FinancingCubit financingCubit;
  late FinancingFormCubit formCubit;

  setUp(() {
    sharer = _FakeSharer();
    financingCubit = FinancingCubit(CalculateFinancing());
    formCubit = FinancingFormCubit();
  });

  tearDown(() async {
    await financingCubit.close();
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
            BlocProvider.value(value: financingCubit),
            BlocProvider.value(value: formCubit),
          ],
          child: FinancingPage(sharer: sharer),
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
    await type(tester, FinancialCalculationTarget.initialValue, '250000');
    await type(tester, FinancialCalculationTarget.periods, '12');
    await type(tester, FinancialCalculationTarget.interestRate, '200');
  }

  Finder inBand(String text) => find.descendant(
    of: find.byType(CalculatorBand),
    matching: find.text(text),
  );

  group('FinancingPage', () {
    testWidgets('monta faixa, lista de campos e barra de ações', (
      tester,
    ) async {
      await pump(tester);

      expect(find.byType(CalculatorBand), findsOneWidget);
      expect(find.byType(FieldRow), findsNWidgets(4));
      expect(find.byType(BottomActionBar), findsOneWidget);
      expect(find.text('Financiamento'), findsOneWidget);
      for (final label in [
        'Valor financiado',
        'Prazo',
        'Taxa de juros',
        'Prestação',
      ]) {
        expect(find.text(label), findsOneWidget);
      }
      expect(find.text('meses'), findsOneWidget);
      expect(find.text('% a.m.'), findsOneWidget);
      expect(inBand('e descubra o quarto'), findsOneWidget);
      expect(find.byType(ResultDetails), findsNothing);
      expect(find.byType(FormNotice), findsNothing);
    });

    testWidgets('com três campos, a prestação fica "a descobrir"', (
      tester,
    ) async {
      await pump(tester);
      await fillExample(tester);

      expect(inBand('a prestação'), findsOneWidget);
      expect(
        find.descendant(
          of: row(FinancialCalculationTarget.finalValue),
          matching: find.text(FieldRow.calculateText),
        ),
        findsOneWidget,
      );
    });

    testWidgets('2.500 / 12 / 2%: prestação, total, juros, taxa anual e '
        'barra 88/12', (tester) async {
      await pump(tester);
      await fillExample(tester);

      await tester.tap(find.text('Calcular'));
      await tester.pumpAndSettle();

      expect(inBand('Sua prestação vai ser'), findsOneWidget);
      expect(inBand('236,40'), findsOneWidget);
      expect(inBand('12 parcelas iguais, pela Tabela Price'), findsOneWidget);
      expect(formCubit.finalValue.text, '236,40');

      expect(find.text('Do total que você vai pagar'), findsOneWidget);
      expect(find.textContaining('2.836,80'), findsOneWidget);
      expect(find.textContaining('336,80'), findsOneWidget);
      expect(find.text('26,82% a.a.'), findsOneWidget);
      expect(find.text('Emprestado 88%'), findsOneWidget);
      expect(find.text('Juros 12%'), findsOneWidget);
    });

    testWidgets('tocar na linha "a descobrir" também calcula', (tester) async {
      await pump(tester);
      await fillExample(tester);

      await tester.tap(find.text(FieldRow.calculateText));
      await tester.pumpAndSettle();

      expect(inBand('236,40'), findsOneWidget);
    });

    testWidgets('calcula a taxa a partir da prestação', (tester) async {
      await pump(tester);
      await type(tester, FinancialCalculationTarget.initialValue, '250000');
      await type(tester, FinancialCalculationTarget.periods, '12');
      await type(tester, FinancialCalculationTarget.finalValue, '23640');

      await tester.tap(find.text('Calcular'));
      await tester.pumpAndSettle();

      expect(inBand('A taxa de juros é de'), findsOneWidget);
      expect(inBand('2,00% ao mês'), findsOneWidget);
    });

    testWidgets('com menos de três campos, mostra o aviso com os campos '
        'vazios e desabilita "Calcular"', (tester) async {
      await pump(tester);
      await type(tester, FinancialCalculationTarget.initialValue, '250000');
      await type(tester, FinancialCalculationTarget.periods, '12');

      expect(find.text('Faltam dados para calcular'), findsOneWidget);
      expect(
        find.text(
          'Preencha a taxa de juros ou a prestação. '
          'O campo que ficar em branco é calculado.',
        ),
        findsOneWidget,
      );
      expect(inBand('falta 1 campo'), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
    });

    testWidgets('limpar mostra "Campos limpos" e desfazer recalcula', (
      tester,
    ) async {
      await pump(tester);
      await fillExample(tester);
      await tester.tap(find.text('Calcular'));
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel(CalculatorBand.clearLabel));
      await tester.pumpAndSettle();

      expect(find.text('Campos limpos'), findsOneWidget);
      expect(inBand('e descubra o quarto'), findsOneWidget);
      expect(formCubit.initialValue.text, isEmpty);

      await tester.tap(find.text('Desfazer'));
      await tester.pumpAndSettle();

      expect(formCubit.initialValue.text, '2.500,00');
      expect(inBand('236,40'), findsOneWidget);
      expect(find.byType(ResultDetails), findsOneWidget);
    });

    testWidgets('compartilhar fica desabilitado sem resultado e envia o '
        'texto ancorado no botão depois de calcular', (tester) async {
      await pump(tester);
      await fillExample(tester);

      final share = find.byType(OutlinedButton);
      expect(tester.widget<OutlinedButton>(share).onPressed, isNull);

      await tester.tap(find.text('Calcular'));
      await tester.pumpAndSettle();
      await tester.tap(share);

      expect(sharer.shared, hasLength(1));
      final (text, origin) = sharer.shared.single;
      expect(text, startsWith('RealCalc · Financiamento\n'));
      expect(text, contains('Total pago: R\$ 2.836,80'));
      expect(origin, tester.getRect(share));
    });

    testWidgets('"?" abre a ajuda', (tester) async {
      await pump(tester);

      await tester.tap(find.bySemanticsLabel(CalculatorBand.helpLabel));
      await tester.pumpAndSettle();

      expect(find.text('Como funciona'), findsOneWidget);
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
        expect(inBand('236,40'), findsOneWidget);
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
