import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/widgets/app_icon.dart';

import '../../../app_icon_finder.dart';
import 'package:real_calc/core/themes/app_theme.dart';
import 'package:real_calc/core/themes/calculator_palette.dart';
import 'package:real_calc/core/themes/calculator_scope.dart';
import 'package:real_calc/core/widgets/calculator_band/band_statement.dart';
import 'package:real_calc/core/widgets/calculator_band/calculator_band.dart';

const initial = BandStatement(
  kicker: 'Descubra quanto fica',
  value: 'a prestação',
  sub: 'de um financiamento',
);
const question = BandStatement(
  kicker: 'Vamos descobrir',
  value: 'o prazo?',
  sub: 'Preencha os outros três campos',
);
const answer = BandStatement(
  kicker: 'Sua prestação fica em',
  value: '236,40',
  isMoney: true,
  sub: 'por 12 meses',
);
const warning = BandStatement(
  kicker: 'Para calcular, falta',
  value: 'a taxa',
  sub: 'Preencha a taxa de juros ao mês',
);

void main() {
  Future<void> pump(
    WidgetTester tester, {
    BandStatement statement = initial,
    CalculatorKind kind = CalculatorKind.financing,
    VoidCallback? onBack,
    VoidCallback? onHelp,
    VoidCallback? onClear,
    double width = 400,
    double textScale = 1,
  }) async {
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(width, 800),
            padding: const EdgeInsets.only(top: 24),
            textScaler: TextScaler.linear(textScale),
          ),
          child: Scaffold(
            body: CalculatorScope(
              kind: kind,
              child: Align(
                alignment: Alignment.topCenter,
                child: CalculatorBand(
                  title: 'Financiamento',
                  statement: statement,
                  onBack: onBack,
                  onHelp: onHelp,
                  onClear: onClear,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double valueFontSize(WidgetTester tester, String value) =>
      tester.widget<Text>(find.text(value)).style!.fontSize!;

  group('CalculatorBand', () {
    testWidgets('a frase muda entre inicial, pergunta, resposta e aviso', (
      tester,
    ) async {
      for (final statement in [initial, question, answer, warning]) {
        await pump(tester, statement: statement);

        expect(find.text(statement.kicker!), findsOneWidget);
        expect(find.text(statement.value), findsOneWidget);
        expect(find.text(statement.sub!), findsOneWidget);
        expect(
          find.text('R\$'),
          statement.isMoney ? findsOneWidget : findsNothing,
        );
      }
    });

    testWidgets('a frase é uma liveRegion com o texto completo', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(tester, statement: answer);

      expect(
        find.bySemanticsLabel('Sua prestação fica em R\$ 236,40 por 12 meses'),
        findsOneWidget,
      );
      final node = tester.getSemantics(
        find.bySemanticsLabel(RegExp('Sua prestação')),
      );
      expect(node, isSemantics(isLiveRegion: true));
      handle.dispose();
    });

    testWidgets('fundo na cor da calculadora, ícones em onSolid e barra de '
        'status com ícones claros nas quatro cores', (tester) async {
      for (final kind in CalculatorKind.values) {
        await pump(tester, kind: kind, onHelp: () {}, onClear: () {});
        final palette = CalculatorPalette.of(kind);

        final background = tester.widget<ColoredBox>(
          find
              .descendant(
                of: find.byType(CalculatorBand),
                matching: find.byType(ColoredBox),
              )
              .first,
        );
        expect(background.color, palette.solid);

        final region = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
          find.descendant(
            of: find.byType(CalculatorBand),
            matching: find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
          ),
        );
        expect(region.value.statusBarIconBrightness, Brightness.light);
        expect(region.value.statusBarBrightness, Brightness.dark);

        for (final button in tester.widgetList<IconButton>(
          find.byType(IconButton),
        )) {
          expect(button.color, palette.onSolid);
        }
      }
    });

    testWidgets('fica atrás da barra de status', (tester) async {
      await pump(tester);

      expect(tester.getTopLeft(find.byType(CalculatorBand)).dy, 0);
      expect(
        tester.getTopLeft(find.text('Financiamento')).dy,
        greaterThanOrEqualTo(24),
      );
    });

    testWidgets('botões com rótulos, área de 44px e ações', (tester) async {
      final handle = tester.ensureSemantics();
      final taps = <String>[];
      await pump(
        tester,
        onBack: () => taps.add('voltar'),
        onHelp: () => taps.add('ajuda'),
        onClear: () => taps.add('limpar'),
      );

      for (final label in [
        CalculatorBand.backLabel,
        CalculatorBand.helpLabel,
        CalculatorBand.clearLabel,
      ]) {
        final button = find.bySemanticsLabel(label);
        expect(button, findsOneWidget);
        expect(
          tester.getSemantics(button),
          isSemantics(isButton: true, hasTapAction: true),
        );
        expect(tester.getSize(button), const Size.square(44));
        await tester.tap(button);
      }
      expect(taps, ['voltar', 'ajuda', 'limpar']);
      handle.dispose();
    });

    testWidgets('sem onHelp e onClear, só mostra voltar', (tester) async {
      await pump(tester);

      expect(find.byType(IconButton), findsOneWidget);
      expect(findAppIcon(AppIcons.back), findsOneWidget);
    });

    testWidgets('valor curto fica em 48px', (tester) async {
      await pump(tester, statement: answer);

      expect(valueFontSize(tester, '236,40'), 48);
    });

    testWidgets('em 360dp e fonte em 130%, as frases quebram e o número '
        'encolhe sem cortar', (tester) async {
      const long = BandStatement(
        kicker: 'O total que você vai pagar ao fim do financiamento é de',
        value: '1.234.567,89',
        isMoney: true,
        sub: 'somando todas as 360 prestações mensais com os juros',
      );
      await pump(tester, statement: long, width: 360, textScale: 1.3);

      expect(tester.takeException(), isNull);

      final kickerHeight = tester.getSize(find.text(long.kicker!)).height;
      final subHeight = tester.getSize(find.text(long.sub!)).height;
      final oneLine = 15 * 1.3;
      expect(kickerHeight, greaterThan(oneLine * 1.5));
      expect(subHeight, greaterThan(oneLine * 1.5));

      final fontSize = valueFontSize(tester, long.value);
      expect(fontSize, lessThan(48));
      expect(fontSize, greaterThanOrEqualTo(CalculatorBand.minValueSize));

      final band = tester.getRect(find.byType(CalculatorBand));
      final value = tester.getRect(find.text(long.value));
      expect(value.left, greaterThanOrEqualTo(band.left));
      expect(value.right, lessThanOrEqualTo(band.right));
    });
  });
}
