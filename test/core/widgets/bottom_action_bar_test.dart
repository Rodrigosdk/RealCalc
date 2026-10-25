import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/themes/app_colors.dart';
import 'package:real_calc/core/themes/app_theme.dart';
import 'package:real_calc/core/themes/calculator_palette.dart';
import 'package:real_calc/core/themes/calculator_scope.dart';
import 'package:real_calc/core/widgets/bottom_action_bar.dart';

void main() {
  const screen = Size(400, 800);

  Future<void> pump(
    WidgetTester tester,
    Widget bar, {
    EdgeInsets viewPadding = EdgeInsets.zero,
    EdgeInsets viewInsets = EdgeInsets.zero,
    Widget? content,
  }) async {
    tester.view.physicalSize = screen;
    tester.view.devicePixelRatio = 1;
    tester.view.padding = FakeViewPadding(bottom: viewPadding.bottom);
    tester.view.viewInsets = FakeViewPadding(bottom: viewInsets.bottom);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: CalculatorScope(
          kind: CalculatorKind.deposits,
          child: Scaffold(
            body: Column(
              children: [
                Expanded(child: content ?? const SizedBox.expand()),
                bar,
              ],
            ),
          ),
        ),
      ),
    );
  }

  group('BottomActionBar', () {
    testWidgets('sem resultado, compartilhar fica apagado e desabilitado', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        BottomActionBar(primaryLabel: 'Calcular', onPrimary: () {}),
      );

      final opacity = tester.widget<Opacity>(
        find.ancestor(
          of: find.byType(OutlinedButton),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacity.opacity, 0.4);
      expect(
        tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
        isNull,
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel(BottomActionBar.shareLabel)),
        isSemantics(isButton: true, hasEnabledState: true, isEnabled: false),
      );
      handle.dispose();
    });

    testWidgets('com resultado, compartilhar fica ativo', (tester) async {
      var shared = 0;
      await pump(
        tester,
        BottomActionBar(
          primaryLabel: 'Calcular',
          onPrimary: () {},
          onShare: () => shared++,
        ),
      );

      final opacity = tester.widget<Opacity>(
        find.ancestor(
          of: find.byType(OutlinedButton),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacity.opacity, 1);
      await tester.tap(find.bySemanticsLabel(BottomActionBar.shareLabel));
      expect(shared, 1);
    });

    testWidgets('botões de 56px, principal em pílula na cor da calculadora '
        'e compartilhar com contorno hairline', (tester) async {
      var calculated = 0;
      await pump(
        tester,
        BottomActionBar(
          primaryLabel: 'Calcular',
          onPrimary: () => calculated++,
        ),
      );

      expect(tester.getSize(find.byType(FilledButton)).height, 56);
      expect(tester.getSize(find.byType(OutlinedButton)), const Size(56, 56));

      final primary = tester.widget<FilledButton>(find.byType(FilledButton));
      final palette = CalculatorPalette.of(CalculatorKind.deposits);
      expect(primary.style!.backgroundColor!.resolve({}), palette.solid);
      expect(primary.style!.shape!.resolve({}), isA<StadiumBorder>());

      final share = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      expect(share.style!.side!.resolve({})!.color, AppColors.light.hairline);

      await tester.tap(find.text('Calcular'));
      expect(calculated, 1);
    });

    testWidgets('fundo background e padding 12/24/30', (tester) async {
      await pump(
        tester,
        BottomActionBar(primaryLabel: 'Calcular', onPrimary: () {}),
      );

      final bar = tester.getRect(find.byType(BottomActionBar));
      final share = tester.getRect(find.byType(OutlinedButton));
      final primary = tester.getRect(find.byType(FilledButton));

      expect(share.left - bar.left, 24);
      expect(bar.right - primary.right, 24);
      expect(share.top - bar.top, 12);
      expect(bar.bottom - share.bottom, 30);
      expect(
        tester
            .widget<ColoredBox>(
              find
                  .descendant(
                    of: find.byType(BottomActionBar),
                    matching: find.byType(ColoredBox),
                  )
                  .first,
            )
            .color,
        AppColors.light.background,
      );
    });

    testWidgets('respeita a área segura de baixo', (tester) async {
      await pump(
        tester,
        BottomActionBar(primaryLabel: 'Calcular', onPrimary: () {}),
        viewPadding: const EdgeInsets.only(bottom: 48),
      );

      final bar = tester.getRect(find.byType(BottomActionBar));
      final share = tester.getRect(find.byType(OutlinedButton));
      expect(bar.bottom, screen.height);
      expect(bar.bottom - share.bottom, 48);
    });

    testWidgets('sobe com o teclado sem cobrir o campo em foco', (
      tester,
    ) async {
      await pump(
        tester,
        BottomActionBar(primaryLabel: 'Calcular', onPrimary: () {}),
        viewInsets: const EdgeInsets.only(bottom: 300),
        content: ListView(
          children: [
            const SizedBox(height: 600),
            TextField(
              key: const Key('campo'),
              autofocus: true,
              scrollPadding: const EdgeInsets.only(bottom: 120),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final bar = tester.getRect(find.byType(BottomActionBar));
      final field = tester.getRect(find.byKey(const Key('campo')));
      expect(bar.bottom, screen.height - 300);
      expect(field.bottom, lessThanOrEqualTo(bar.top));
    });
  });

  group('showFieldsClearedSnackBar', () {
    testWidgets('mostra "Campos limpos" com "Desfazer" por 4s', (tester) async {
      var undone = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () =>
                    showFieldsClearedSnackBar(context, onUndo: () => undone++),
                child: const Text('limpar'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('limpar'));
      await tester.pumpAndSettle();
      expect(find.text('Campos limpos'), findsOneWidget);

      await tester.tap(find.text('Desfazer'));
      await tester.pumpAndSettle();
      expect(undone, 1);

      await tester.tap(find.text('limpar'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('Campos limpos'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text('Campos limpos'), findsNothing);
    });
  });
}
