import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/widgets/opitions_bottom_forms.dart';

void main() {
  group('OptionsBottomForms', () {
    testWidgets('Deve renderizar os três botões com os textos e ícones corretos', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OptionsBottomForms(),
          ),
        ),
      );

      expect(find.text('Calcular'), findsOneWidget);
      expect(find.text('Limpar'), findsOneWidget);
      expect(find.text('Compartilhar'), findsOneWidget);

      expect(find.byIcon(Icons.calculate_outlined), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      expect(find.byIcon(Icons.share_outlined), findsOneWidget);
    });

    testWidgets('Deve aplicar as cores corretas nos botões baseadas no design', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OptionsBottomForms(),
          ),
        ),
      );

      // Busca todos os ElevatedButton.icon renderizados
      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsNWidgets(3));

      // Captura a instância do primeiro botão (Calcular)
      final ElevatedButton calculateButton = tester.widget(buttonFinder.at(0));
      final calculateColor = calculateButton.style?.backgroundColor?.resolve({});
      expect(calculateColor, const Color(0xFF1E94F6)); // Azul correspondente

      // Captura as instâncias dos botões inferiores (Limpar e Compartilhar)
      final ElevatedButton clearButton = tester.widget(buttonFinder.at(1));
      final ElevatedButton shareButton = tester.widget(buttonFinder.at(2));
      
      final darkButtonColor = const Color(0xFF1A222D);
      expect(clearButton.style?.backgroundColor?.resolve({}), darkButtonColor);
      expect(shareButton.style?.backgroundColor?.resolve({}), darkButtonColor);
    });

    testWidgets('Deve disparar os respectivos callbacks ao clicar em cada botão', (tester) async {
      int calculateClicks = 0;
      int clearClicks = 0;
      int shareClicks = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptionsBottomForms(
              onCalculate: () => calculateClicks++,
              onClear: () => clearClicks++,
              onShare: () => shareClicks++,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Calcular'));
      await tester.pump();

      await tester.tap(find.text('Limpar'));
      await tester.pump();

      await tester.tap(find.text('Compartilhar'));
      await tester.pump();

      expect(calculateClicks, 1);
      expect(clearClicks, 1);
      expect(shareClicks, 1);
    });
  });
}
