import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/widgets/app_icon.dart';

import '../../../../app_icon_finder.dart';
import 'package:real_calc/core/themes/app_theme.dart';
import 'package:real_calc/core/themes/calculator_palette.dart';
import 'package:real_calc/core/widgets/app_sheet.dart';
import 'package:real_calc/modules/value_correction/domain/enum/correction_index.dart';
import 'package:real_calc/modules/value_correction/presentation/widgets/correction_index_picker.dart';

void main() {
  CorrectionIndex? selected;

  Future<void> open(
    WidgetTester tester, {
    Size size = const Size(400, 800),
    ThemeData? theme,
  }) async {
    selected = null;
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: theme ?? AppTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: TextButton(
                onPressed: () => showCorrectionIndexPicker(
                  context,
                  selectedIndex: CorrectionIndex.ipca,
                  onSelected: (index) => selected = index,
                ),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
  }

  Finder row(CorrectionIndex index) => find.byKey(ValueKey(index.name));
  Finder tab(String label) => find.byKey(ValueKey('tab-$label'));
  final search = find.byType(TextField);

  Future<void> scrollTo(WidgetTester tester, Finder finder) =>
      tester.scrollUntilVisible(
        finder,
        200,
        scrollable: find.descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        ),
      );

  group('CorrectionIndexPicker', () {
    testWidgets('abre sobre o AppSheet com título, busca e abas', (
      tester,
    ) async {
      await open(tester);

      expect(find.byType(AppSheet), findsOneWidget);
      expect(find.text(correctionIndexPickerTitle), findsOneWidget);
      expect(find.text(correctionIndexSearchHint), findsOneWidget);
      for (final label in ['Todos', 'Inflação', 'Juros', 'Poupança']) {
        expect(tab(label), findsOneWidget);
      }
      expect(find.text('INFLAÇÃO'), findsOneWidget);
    });

    testWidgets('mostra fonte e "desde" vindos do enum', (tester) async {
      await open(tester);

      expect(find.text('IPCA'), findsOneWidget);
      expect(find.text('IBGE, desde 01/1980'), findsOneWidget);

      await scrollTo(tester, row(CorrectionIndex.selic));
      final selic = CorrectionIndex.selic;
      expect(
        find.text('${selic.source}, desde ${selic.sinceMonthLabel}'),
        findsOneWidget,
      );
      expect(find.text('Banco Central, desde 06/1986'), findsOneWidget);
    });

    testWidgets('o índice atual fica em negrito e com ✓', (tester) async {
      await open(tester);

      expect(findAppIcon(AppIcons.check), findsOneWidget);
      expect(
        find.descendant(
          of: row(CorrectionIndex.ipca),
          matching: findAppIcon(AppIcons.check),
        ),
        findsOneWidget,
      );
      final ipca = tester.widget<Text>(find.text('IPCA'));
      final inpc = tester.widget<Text>(find.text('INPC'));
      expect(ipca.style!.fontWeight, FontWeight.w800);
      expect(inpc.style!.fontWeight, FontWeight.w500);
    });

    testWidgets('escolher um índice chama onSelected e fecha', (tester) async {
      await open(tester);

      await scrollTo(tester, row(CorrectionIndex.selic));
      await tester.tap(row(CorrectionIndex.selic));
      await tester.pumpAndSettle();

      expect(selected, CorrectionIndex.selic);
      expect(find.byType(CorrectionIndexPicker), findsNothing);
    });

    testWidgets('a busca ignora acentos e maiúsculas', (tester) async {
      await open(tester);

      await tester.enterText(search, 'POUPANCA');
      await tester.pumpAndSettle();
      expect(row(CorrectionIndex.poupancaNova), findsOneWidget);
      expect(row(CorrectionIndex.poupancaVelha), findsOneWidget);
      expect(row(CorrectionIndex.ipca), findsNothing);

      await tester.enterText(search, 'ipç');
      await tester.pumpAndSettle();
      expect(row(CorrectionIndex.ipca), findsOneWidget);
      expect(row(CorrectionIndex.ipcSp), findsOneWidget);
      expect(row(CorrectionIndex.cdi), findsNothing);
    });

    testWidgets('a busca também encontra pela fonte', (tester) async {
      await open(tester);

      await tester.enterText(search, 'fgv');
      await tester.pumpAndSettle();

      expect(row(CorrectionIndex.igpDi), findsOneWidget);
      expect(row(CorrectionIndex.igpM), findsOneWidget);
      expect(row(CorrectionIndex.ipcBrasil), findsOneWidget);
      expect(row(CorrectionIndex.ipca), findsNothing);
    });

    testWidgets('sem resultado, avisa e limpar volta a lista', (tester) async {
      await open(tester);

      await tester.enterText(search, 'xyz');
      await tester.pumpAndSettle();
      expect(find.text(correctionIndexNoResults), findsOneWidget);

      await tester.tap(find.byTooltip('Limpar busca'));
      await tester.pumpAndSettle();
      expect(find.text(correctionIndexNoResults), findsNothing);
      expect(row(CorrectionIndex.ipca), findsOneWidget);
    });

    testWidgets('as abas filtram pelo grupo', (tester) async {
      await open(tester);

      await tester.tap(tab('Juros'));
      await tester.pumpAndSettle();
      for (final index in [
        CorrectionIndex.cdi,
        CorrectionIndex.selic,
        CorrectionIndex.tr,
        CorrectionIndex.taxaLegal,
      ]) {
        expect(row(index), findsOneWidget);
      }
      expect(row(CorrectionIndex.ipca), findsNothing);
      expect(row(CorrectionIndex.poupancaNova), findsNothing);
      expect(find.text('JUROS'), findsNothing);

      // A fonte de teste é larga; as abas rolam na horizontal.
      await tester.ensureVisible(tab('Poupança'));
      await tester.tap(tab('Poupança'));
      await tester.pumpAndSettle();
      expect(row(CorrectionIndex.poupancaNova), findsOneWidget);
      expect(row(CorrectionIndex.cdi), findsNothing);

      await tester.ensureVisible(tab('Todos'));
      await tester.tap(tab('Todos'));
      await tester.pumpAndSettle();
      expect(row(CorrectionIndex.ipca), findsOneWidget);
    });

    testWidgets('a aba ativa fica sublinhada na cor da Correção', (
      tester,
    ) async {
      await open(tester);
      await tester.tap(tab('Juros'));
      await tester.pumpAndSettle();

      Color underline(String label) {
        final box = tester.widget<Container>(
          find.descendant(of: tab(label), matching: find.byType(Container)),
        );
        final border = (box.decoration! as BoxDecoration).border! as Border;
        return border.bottom.color;
      }

      final palette = CalculatorPalette.of(CalculatorKind.correction);
      expect(underline('Juros'), palette.text);
      expect(underline('Todos'), Colors.transparent);
    });

    testWidgets('busca e aba se combinam', (tester) async {
      await open(tester);

      await tester.tap(tab('Inflação'));
      await tester.enterText(search, 'selic');
      await tester.pumpAndSettle();

      expect(find.text(correctionIndexNoResults), findsOneWidget);
    });

    testWidgets('com a busca em foco a folha sobe e a lista fica acima do '
        'teclado', (tester) async {
      await open(tester, size: const Size(360, 640));

      await tester.showKeyboard(search);
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();

      final sheet = tester.getRect(find.byType(AppSheet));
      expect(sheet.top, AppSheet.topGap);

      final list = tester.getRect(find.byType(ListView));
      expect(list.bottom, lessThanOrEqualTo(640 - 300));
      expect(list.height, greaterThan(0));
      expect(tester.takeException(), isNull);
    });

    for (final (name, theme) in [
      ('claro', AppTheme.lightTheme),
      ('escuro', AppTheme.darkTheme),
    ]) {
      testWidgets('sem overflow em 360x640 no tema $name', (tester) async {
        await open(tester, size: const Size(360, 640), theme: theme);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
