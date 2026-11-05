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
import 'package:real_calc/core/widgets/help_sheet/methodology.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    CalculatorKind kind = CalculatorKind.financing,
    Size size = const Size(400, 800),
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
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

  group('Metodologia da Correção', () {
    const methodology = Methodology.correction;
    Finder scrollable() => find.descendant(
      of: find.byType(AppSheet),
      matching: find.byType(Scrollable),
    );

    testWidgets('vem depois da fórmula, com título e todos os blocos', (
      tester,
    ) async {
      await pump(tester, kind: CalculatorKind.correction);
      await open(tester);

      await tester.scrollUntilVisible(
        find.text(methodology.items.last.text),
        200,
        scrollable: scrollable(),
      );

      expect(find.text(Methodology.title), findsOneWidget);
      for (final item in methodology.items) {
        expect(find.text(item.title), findsOneWidget);
        expect(find.text(item.text), findsOneWidget);
      }
      final formula = tester.getRect(find.text(HelpContent.correction.formula));
      final title = tester.getRect(find.text(Methodology.title));
      expect(title.top, greaterThan(formula.bottom));
      expect(
        tester.getRect(find.text(methodology.items.last.text)).bottom,
        lessThanOrEqualTo(tester.getRect(find.text('Entendi')).top),
      );
    });

    testWidgets('as outras calculadoras não têm a seção', (tester) async {
      for (final kind in [
        CalculatorKind.financing,
        CalculatorKind.deposits,
        CalculatorKind.futureValue,
      ]) {
        await pump(tester, kind: kind);
        await open(tester);
        expect(find.text(Methodology.title, skipOffstage: false), findsNothing);
        await tester.tap(find.text('Entendi'));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('rola até o fim sem estourar em 360dp com fonte em 130%', (
      tester,
    ) async {
      await pump(
        tester,
        kind: CalculatorKind.correction,
        size: const Size(360, 640),
        textScale: 1.3,
      );
      await open(tester);

      await tester.scrollUntilVisible(
        find.text(methodology.items.last.text),
        200,
        scrollable: scrollable(),
      );

      expect(tester.takeException(), isNull);
      expect(find.text(methodology.items.last.text).hitTestable(), findsOne);
      expect(
        tester.getRect(find.text('Entendi')).bottom,
        lessThanOrEqualTo(640),
      );
    });

    testWidgets('os títulos são cabeçalhos, na ordem da tela', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        kind: CalculatorKind.correction,
        size: const Size(400, 4000),
      );
      await open(tester);

      final titles = [
        Methodology.title,
        for (final item in methodology.items) item.title,
      ];
      double? previous;
      for (final title in titles) {
        expect(
          tester.getSemantics(find.text(title)),
          isSemantics(label: title, isHeader: true),
        );
        final top = tester.getRect(find.text(title)).top;
        if (previous != null) expect(top, greaterThan(previous));
        previous = top;
      }
      handle.dispose();
    });

    test('o exemplo do fator acumulado confere', () {
      expect(1.01 * 1.02, closeTo(1.0302, 1e-12));
      expect(methodology.items.first.text, contains('1,0302'));
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
