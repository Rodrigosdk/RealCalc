import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/modules/home/components/highlight_card.dart'; // Ajuste o import conforme seu projeto

void main() {
  group('HighlightCard Widget Tests', () {
    Widget buildTestableWidget() {
      return const MaterialApp(
        home: Scaffold(
          body: HighlightCard(),
        ),
      );
    }

    testWidgets('Deve renderizar todos os textos corretamente', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('Selic e Índices'), findsOneWidget);
      expect(
        find.text('Acompanhe as taxas oficiais atualizadas diariamente pelo Banco Central.'),
        findsOneWidget,
      );
      expect(find.text('CONSULTAR TAXAS'), findsOneWidget);
    });

    testWidgets('Deve conter as decorações visuais corretas (Container e Gradiente)', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());

      final containerFinder = find.byType(Container);
      final Container containerWidget = tester.widget(containerFinder);
      final BoxDecoration decoration = containerWidget.decoration as BoxDecoration;

      expect(decoration.borderRadius, BorderRadius.circular(20));

      final LinearGradient gradient = decoration.gradient as LinearGradient;
      expect(gradient.colors, const [Color(0xFF1E70F6), Color(0xFF1E94F6)]);
      expect(gradient.begin, Alignment.topLeft);
      expect(gradient.end, Alignment.bottomRight);
    });

    testWidgets('Deve aplicar a tipografia e cores corretas aos textos', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());

      final titleText = tester.widget<Text>(find.text('Selic e Índices'));
      expect(titleText.style?.color, Colors.white);
      expect(titleText.style?.fontSize, 22);
      expect(titleText.style?.fontWeight, FontWeight.bold);

      final descText = tester.widget<Text>(
        find.text('Acompanhe as taxas oficiais atualizadas diariamente pelo Banco Central.'),
      );
      expect(descText.style?.color, Colors.white.withValues(alpha: 0.8));
      expect(descText.style?.fontSize, 14);
    });

    testWidgets('Deve conter o botão com o estilo correto e permitir clique', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());

      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsOneWidget);

      final ElevatedButton buttonWidget = tester.widget(buttonFinder);
      final ButtonStyle? buttonStyle = buttonWidget.style;

      expect(
        buttonStyle?.backgroundColor?.resolve({}),
        Colors.white.withValues(alpha: 0.2),
      );
      expect(
        buttonStyle?.foregroundColor?.resolve({}),
        Colors.white,
      );
      expect(buttonStyle?.elevation?.resolve({}), 0);

      await tester.tap(buttonFinder);
      await tester.pump();
    });
  });
}
