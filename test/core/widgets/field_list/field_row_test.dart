import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/widgets/app_icon.dart';

import '../../../app_icon_finder.dart';
import 'package:real_calc/core/themes/app_colors.dart';
import 'package:real_calc/core/themes/app_theme.dart';
import 'package:real_calc/core/themes/calculator_palette.dart';
import 'package:real_calc/core/themes/calculator_scope.dart';
import 'package:real_calc/core/widgets/field_list/field_list.dart';
import 'package:real_calc/core/widgets/field_list/field_row.dart';
import 'package:real_calc/core/widgets/types/input_field_state.dart';

void main() {
  const colors = AppColors.light;
  final palette = CalculatorPalette.of(CalculatorKind.correction);

  late TextEditingController controller;

  setUp(() => controller = TextEditingController());
  tearDown(() => controller.dispose());

  Future<void> pump(
    WidgetTester tester,
    Widget row, {
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
            textScaler: TextScaler.linear(textScale),
          ),
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: CalculatorScope(
                kind: CalculatorKind.correction,
                child: FieldList(children: [row]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BorderSide bottomLine(WidgetTester tester) {
    final container = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(FieldRow),
            matching: find.byType(Container),
          )
          .first,
    );
    return ((container.decoration! as BoxDecoration).border! as Border).bottom;
  }

  TextStyle valueStyle(WidgetTester tester) =>
      tester.widget<EditableText>(find.byType(EditableText)).style;

  group('FieldRow', () {
    testWidgets('neutro: rótulo, segunda linha e linha hairline', (
      tester,
    ) async {
      controller.text = '1.200,00';
      await pump(
        tester,
        FieldRow(
          label: 'Depósito',
          secondLine: 'todo mês',
          prefix: 'R\$',
          controller: controller,
        ),
      );

      expect(find.text('Depósito'), findsOneWidget);
      expect(find.text('todo mês'), findsOneWidget);
      expect(find.text('R\$'), findsOneWidget);
      expect(bottomLine(tester).color, colors.hairline);
      expect(bottomLine(tester).width, 1);
      expect(valueStyle(tester).color, colors.textPrimary);
      expect(findAppIcon(AppIcons.check), findsNothing);
      expect(
        tester.getSize(find.byType(FieldRow)).height,
        greaterThanOrEqualTo(64),
      );
    });

    testWidgets('sem segunda linha, tem altura mínima de 58', (tester) async {
      await pump(tester, FieldRow(label: 'Taxa', controller: controller));

      expect(
        tester.getSize(find.byType(FieldRow)).height,
        greaterThanOrEqualTo(58),
      );
      // Vazio, o campo ocupa a largura do hint "0".
      expect(find.text('0'), findsOneWidget);
      expect(
        tester.getSize(find.byType(TextField)).width,
        greaterThanOrEqualTo(tester.getSize(find.text('0')).width),
      );
    });

    testWidgets('em edição: tocar na linha foca o campo, linha de 2px e '
        'cursor na cor da calculadora', (tester) async {
      await pump(
        tester,
        FieldRow(label: 'Valor', prefix: 'R\$', controller: controller),
      );

      // Toca no rótulo, longe do campo: a linha inteira é área de toque.
      await tester.tap(find.text('Valor'));
      await tester.pump();

      final editable = tester.widget<EditableText>(find.byType(EditableText));
      expect(editable.focusNode.hasFocus, isTrue);
      expect(editable.cursorColor, palette.solid);
      expect(bottomLine(tester).color, palette.solid);
      expect(bottomLine(tester).width, 2);
    });

    testWidgets('a descobrir: texto, pílula, linha e toque para calcular', (
      tester,
    ) async {
      var calculated = 0;
      await pump(
        tester,
        FieldRow(
          label: 'Prestação',
          controller: controller,
          state: InputFieldState.unknown,
          onCalculate: () => calculated++,
        ),
      );

      expect(find.text(FieldRow.unknownText), findsOneWidget);
      expect(find.text(FieldRow.calculateText), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(bottomLine(tester).color, palette.solid);
      expect(bottomLine(tester).width, 2);

      final pill = tester.widget<Text>(find.text(FieldRow.calculateText));
      expect(pill.style!.color, palette.onSolid);
      final pillBox = tester.widget<Container>(
        find
            .ancestor(
              of: find.text(FieldRow.calculateText),
              matching: find.byType(Container),
            )
            .first,
      );
      expect((pillBox.decoration! as BoxDecoration).color, palette.solid);

      await tester.tap(find.text('Prestação'));
      expect(calculated, 1);
    });

    testWidgets('calculado: texto, ✓ e valor em destaque com peso 800', (
      tester,
    ) async {
      controller.text = '1.523,42';
      await pump(
        tester,
        FieldRow(
          label: 'Prestação',
          prefix: 'R\$',
          controller: controller,
          state: InputFieldState.calculated,
        ),
      );

      expect(find.text(FieldRow.calculatedText), findsOneWidget);
      expect(
        tester.widget<Text>(find.text(FieldRow.calculatedText)).style!.color,
        palette.text,
      );
      expect(
        tester.widget<AppIcon>(findAppIcon(AppIcons.check)).color,
        palette.text,
      );
      expect(valueStyle(tester).color, palette.text);
      expect(valueStyle(tester).fontWeight, FontWeight.w800);
      expect(bottomLine(tester).color, colors.hairline);
    });

    testWidgets('erro: linha de 1,5px, valor e segunda linha em error', (
      tester,
    ) async {
      controller.text = '01/1900';
      await pump(
        tester,
        FieldRow(
          label: 'Data inicial',
          controller: controller,
          state: InputFieldState.error,
          errorText: 'fora do período',
        ),
      );

      expect(find.text('fora do período'), findsOneWidget);
      expect(
        tester.widget<Text>(find.text('fora do período')).style!.color,
        colors.error,
      );
      expect(valueStyle(tester).color, colors.error);
      expect(bottomLine(tester).color, colors.error);
      expect(bottomLine(tester).width, 1.5);
    });

    testWidgets('seleção: valor, chevron e toque abre o seletor', (
      tester,
    ) async {
      var opened = 0;
      await pump(
        tester,
        FieldRow.selection(
          label: 'Índice',
          value: 'IPCA',
          onTap: () => opened++,
        ),
      );

      expect(find.text('IPCA'), findsOneWidget);
      expect(findAppIcon(AppIcons.chevronRight), findsOneWidget);
      expect(find.byType(TextField), findsNothing);

      await tester.tap(find.text('Índice'));
      expect(opened, 1);
    });

    testWidgets('prefixo, valor e unidade ficam colados e na borda', (
      tester,
    ) async {
      controller.text = '12';
      await pump(
        tester,
        FieldRow(label: 'Prazo', unit: 'meses', controller: controller),
      );

      final field = tester.getRect(find.byType(TextField));
      final unit = tester.getRect(find.text('meses'));
      final row = tester.getRect(find.byType(FieldRow));

      expect(unit.left - field.right, 4);
      expect(unit.right, row.right);
    });

    testWidgets('usa o teclado informado e mantém espaço acima do teclado', (
      tester,
    ) async {
      await pump(
        tester,
        FieldRow(
          label: 'Prazo',
          controller: controller,
          keyboardType: TextInputType.number,
        ),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.keyboardType, TextInputType.number);
      expect(field.scrollPadding.bottom, greaterThanOrEqualTo(100));

      await pump(tester, FieldRow(label: 'Taxa', controller: controller));
      expect(
        tester.widget<TextField>(find.byType(TextField)).keyboardType,
        const TextInputType.numberWithOptions(decimal: true),
      );
    });

    testWidgets('em 360dp e fonte em 130%, a segunda linha quebra e o valor '
        'não é cortado', (tester) async {
      controller.text = '1.234.567,89';
      await pump(
        tester,
        FieldRow(
          label: 'Valor corrigido',
          prefix: 'R\$',
          controller: controller,
          state: InputFieldState.error,
          errorText: 'fora do período disponível para o índice escolhido',
        ),
        width: 360,
        textScale: 1.3,
      );

      expect(tester.takeException(), isNull);

      final secondLine = tester.getSize(
        find.text('fora do período disponível para o índice escolhido'),
      );
      final singleLine = tester.getSize(find.text('Valor corrigido'));
      expect(secondLine.height, greaterThan(singleLine.height));

      final painter = TextPainter(
        text: TextSpan(text: controller.text, style: valueStyle(tester)),
        textDirection: TextDirection.ltr,
        textScaler: const TextScaler.linear(1.3),
      )..layout();
      // O campo tem a largura do texto inteiro e fica dentro da linha.
      expect(
        tester.getSize(find.byType(TextField)).width,
        greaterThanOrEqualTo(painter.width),
      );
      painter.dispose();
      final row = tester.getRect(find.byType(FieldRow));
      final field = tester.getRect(find.byType(TextField));
      expect(field.left, greaterThanOrEqualTo(row.left));
      expect(field.right, lessThanOrEqualTo(row.right));
    });

    group('Semantics', () {
      testWidgets('a descobrir é anunciado como botão', (tester) async {
        final handle = tester.ensureSemantics();
        await pump(
          tester,
          FieldRow(
            label: 'Prestação',
            controller: controller,
            state: InputFieldState.unknown,
            onCalculate: () {},
          ),
        );

        expect(
          tester.getSemantics(find.byType(FieldRow)),
          isSemantics(
            label: 'Prestação, a descobrir',
            isButton: true,
            hasTapAction: true,
          ),
        );
        handle.dispose();
      });

      testWidgets('campo anuncia rótulo, unidade, estado e valor', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        controller.text = '12';
        await pump(
          tester,
          FieldRow(
            label: 'Prazo',
            unit: 'meses',
            controller: controller,
            state: InputFieldState.calculated,
          ),
        );

        expect(
          tester.getSemantics(find.byType(FieldRow)),
          isSemantics(
            label: 'Prazo, meses, calculado para você',
            value: '12',
            isTextField: true,
          ),
        );
        handle.dispose();
      });

      testWidgets('seleção anuncia rótulo e valor como botão', (tester) async {
        final handle = tester.ensureSemantics();
        await pump(
          tester,
          FieldRow.selection(label: 'Índice', value: 'IPCA', onTap: () {}),
        );

        expect(
          tester.getSemantics(find.byType(FieldRow)),
          isSemantics(
            label: 'Índice, IPCA',
            isButton: true,
            hasTapAction: true,
          ),
        );
        handle.dispose();
      });
    });
  });

  group('FieldList', () {
    testWidgets('desenha a linha hairline no topo', (tester) async {
      await pump(tester, FieldRow(label: 'Taxa', controller: controller));

      final box = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(FieldList),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final border = (box.decoration as BoxDecoration).border! as Border;
      expect(border.top.color, colors.hairline);
      expect(find.byType(Card), findsNothing);
    });
  });
}
