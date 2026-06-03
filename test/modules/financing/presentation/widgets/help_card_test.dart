import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/modules/financing/presentation/widgets/help_card.dart';

void main() {
  group('HelpCard', () {
    const testMessage = 'Esta é uma mensagem de dica ou ajuda importante.';

    Widget createSut() {
      return const MaterialApp(
        home: Scaffold(
          body: HelpCard(menssage: testMessage),
        ),
      );
    }

    testWidgets('Deve exibir o texto da mensagem e o ícone de lâmpada', (tester) async {
      await tester.pumpWidget(createSut());

      // 1. Valida o texto exibido
      final textFinder = find.text(testMessage);
      expect(textFinder, findsOneWidget);

      final Text textWidget = tester.widget(textFinder);
      expect(textWidget.style?.color, Colors.white);
      expect(textWidget.style?.fontSize, 14);

      // 2. Valida a presença do ícone de lâmpada
      expect(find.byIcon(Icons.lightbulb), findsOneWidget);
    });

    testWidgets('Deve validar a decoração e estilos do container principal', (tester) async {
      await tester.pumpWidget(createSut());

      // Localiza o Container mais externo buscando pelo tipo
      final containerFinder = find.byType(Container);
      
      // Como temos dois Containers (o principal e o do ícone), pegamos o primeiro (.first)
      final Container mainContainer = tester.widget(containerFinder.first);
      final mainDecoration = mainContainer.decoration as BoxDecoration?;

      expect(mainDecoration, isNotNull);
      // Valida a cor de fundo
      expect(mainDecoration!.color, const Color(0xFF101A24));
      // Valida o raio de curvatura
      expect(mainDecoration.borderRadius, BorderRadius.circular(18));
      
      // Valida as propriedades da borda
      final border = mainDecoration.border as Border?;
      expect(border, isNotNull);
      expect(border!.top.color, const Color(0xFF1E94F6).withValues(alpha: 0.4));
    });

    testWidgets('Deve validar a decoração do container menor que envolve o ícone', (tester) async {
      await tester.pumpWidget(createSut());

      final containerFinder = find.byType(Container);
      
      // O segundo container na árvore (.at(1)) é o que envelopa o ícone
      final Container iconContainer = tester.widget(containerFinder.at(1));
      final iconDecoration = iconContainer.decoration as BoxDecoration?;

      expect(iconDecoration, isNotNull);
      expect(iconDecoration!.color, const Color(0xFF1E94F6));
      expect(iconDecoration.borderRadius, BorderRadius.circular(12));
      
      // Valida as dimensões fixas do container do ícone
      expect(iconContainer.constraints?.maxWidth, 40);
      expect(iconContainer.constraints?.maxHeight, 40);
    });
  });
}