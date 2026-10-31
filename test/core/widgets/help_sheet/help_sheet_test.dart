import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/widgets/app_icon.dart';

import '../../../app_icon_finder.dart';
import 'package:real_calc/core/themes/app_theme.dart';
import 'package:real_calc/core/themes/calculator_palette.dart';
import 'package:real_calc/core/themes/calculator_scope.dart';
import 'package:real_calc/core/utils/br_number_format.dart';
import 'package:real_calc/core/widgets/app_sheet.dart';
import 'package:real_calc/core/widgets/calculator_band/band_statement.dart';
import 'package:real_calc/core/widgets/calculator_band/calculator_band.dart';
import 'package:real_calc/core/widgets/help_sheet/help_content.dart';
import 'package:real_calc/core/widgets/help_sheet/help_sheet.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    CalculatorKind kind = CalculatorKind.financing,
    Size size = const Size(400, 800),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: CalculatorScope(
            kind: kind,
            child: Builder(
              builder: (context) => Align(
                alignment: Alignment.topCenter,
                child: CalculatorBand(
                  title: 'Calculadora',
                  statement: const BandStatement(value: 'x'),
                  onHelp: () => showHelpSheet(context, kind),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> open(WidgetTester tester) async {
    await tester.tap(findAppIcon(AppIcons.help));
    await tester.pumpAndSettle();
  }

  final sheet = find.byType(AppSheet);

  group('HelpSheet', () {
    testWidgets('abre pelo "?" com o conteúdo da calculadora', (tester) async {
      await pump(tester);
      await open(tester);

      const content = HelpContent.financing;
      expect(find.text(helpSheetTitle), findsOneWidget);
      expect(find.text(content.intro), findsOneWidget);
      for (final field in content.fields) {
        expect(find.text(field.name), findsOneWidget);
        expect(find.text(field.description), findsOneWidget);
      }
      expect(find.text(content.exampleResult), findsOneWidget);
      expect(find.text(content.formula), findsOneWidget);
      expect(find.text('Entendi'), findsOneWidget);
      expect(find.byType(Icon).evaluate().length, lessThanOrEqualTo(3));
    });

    testWidgets('topo a 96px', (tester) async {
      await pump(tester, size: const Size(400, 640));
      await open(tester);

      expect(tester.getTopLeft(sheet).dy, greaterThanOrEqualTo(96));
    });

    testWidgets('exemplo e "Entendi" na cor da calculadora', (tester) async {
      for (final kind in CalculatorKind.values) {
        await pump(tester, kind: kind);
        await open(tester);
        final palette = CalculatorPalette.of(kind);

        final example = tester.widget<Text>(
          find.text(HelpContent.of(kind).exampleResult),
        );
        expect(example.style!.color, palette.text);
        final button = tester.widget<FilledButton>(find.byType(FilledButton));
        expect(button.style!.backgroundColor!.resolve({}), palette.solid);

        await tester.tap(find.text('Entendi'));
        await tester.pumpAndSettle();
      }
    });

    group('fecha', () {
      Future<void> expectCloses(
        WidgetTester tester,
        Future<void> Function() action,
      ) async {
        await pump(tester);
        await open(tester);
        expect(sheet, findsOneWidget);
        await action();
        await tester.pumpAndSettle();
        expect(sheet, findsNothing);
      }

      testWidgets('no X', (tester) async {
        await expectCloses(
          tester,
          () => tester.tap(find.bySemanticsLabel(AppSheet.closeLabel)),
        );
      });

      testWidgets('em "Entendi"', (tester) async {
        await expectCloses(tester, () => tester.tap(find.text('Entendi')));
      });

      testWidgets('tocando fora', (tester) async {
        await expectCloses(tester, () => tester.tapAt(const Offset(20, 20)));
      });

      testWidgets('arrastando para baixo', (tester) async {
        await expectCloses(
          tester,
          () => tester.fling(
            find.text(helpSheetTitle),
            const Offset(0, 500),
            2000,
          ),
        );
      });

      testWidgets('com o voltar do Android', (tester) async {
        await expectCloses(tester, () => tester.binding.handlePopRoute());
      });
    });

    testWidgets('em 640dp, o conteúdo rola e "Entendi" continua visível', (
      tester,
    ) async {
      await pump(tester, size: const Size(360, 640));
      await open(tester);

      Rect understood() => tester.getRect(find.text('Entendi'));
      expect(understood().bottom, lessThanOrEqualTo(640));

      final scrollable = find.descendant(
        of: sheet,
        matching: find.byType(Scrollable),
      );
      expect(
        tester.state<ScrollableState>(scrollable).position.maxScrollExtent,
        greaterThan(0),
      );

      await tester.scrollUntilVisible(
        find.text(HelpContent.financing.formula),
        100,
        scrollable: scrollable,
      );
      expect(find.text(HelpContent.financing.formula).hitTestable(), findsOne);
      expect(understood().bottom, lessThanOrEqualTo(640));
    });

    testWidgets('é anunciada como diálogo', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester);
      await open(tester);

      expect(
        tester.getSemantics(find.bySemanticsLabel('Dialog')),
        isSemantics(namesRoute: true, scopesRoute: true),
      );
      handle.dispose();
    });

    testWidgets('devolve o foco ao "?" ao fechar', (tester) async {
      await pump(tester);
      final helpFocus = Focus.of(tester.element(findAppIcon(AppIcons.help)));
      helpFocus.requestFocus();
      await tester.pump();

      await open(tester);
      expect(helpFocus.hasFocus, isFalse);

      await tester.tap(find.text('Entendi'));
      await tester.pumpAndSettle();
      expect(helpFocus.hasFocus, isTrue);
    });
  });

  group('HelpContent', () {
    double price(double v, double i, int n) => v * i / (1 - pow(1 + i, -n));

    String money(num value) => formatCents(
      toCents(value.toDouble()),
    ).replaceAll(String.fromCharCode(0xA0), ' ');

    test('os exemplos batem com as fórmulas', () {
      expect(HelpContent.financing.exampleResult, money(price(2500, 0.02, 12)));
      expect(
        HelpContent.deposits.exampleResult,
        money(100 * 1.01 * (pow(1.01, 12) - 1) / 0.01),
      );
      expect(
        HelpContent.futureValue.exampleResult,
        money(1000 * pow(1.01, 12)),
      );
      expect(HelpContent.correction.exampleResult, money(1000 * 1.005 * 1.004));
    });
  });
}
