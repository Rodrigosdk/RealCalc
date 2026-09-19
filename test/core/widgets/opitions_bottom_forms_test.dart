import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/themes/extensions/options_bottom_forms_theme.dart';
import 'package:real_calc/core/widgets/options_bottom_forms.dart';

void main() {
  Widget createSut({
    VoidCallback? onCalculate,
    VoidCallback? onClear,
    VoidCallback? onShare,
    Color calculateBackground = const Color(0xFF1E94F6),
    Color calculateForeground = Colors.white,
    Color actionBackground = const Color(0xFF1A222D),
    Color actionForeground = Colors.white70,
    Color borderButtonColor = Colors.white70,
  }) {
    return MaterialApp(
      theme: ThemeData(
        extensions: [
          OptionsBottomFormsTheme(
            calculateButtonBackground: calculateBackground,
            calculateButtonForeground: calculateForeground,
            actionButtonBackground: actionBackground,
            actionButtonForeground: actionForeground, 
            borderButtonColor: borderButtonColor,
          ),
        ],
      ),
      home: Scaffold(
        body: OptionsBottomForms(
          onCalculate: onCalculate,
          onClear: onClear,
        ),
      ),
    );
  }

  group('OptionsBottomForms', () {
    testWidgets('Deve renderizar os três botões com os textos e ícones corretos', (tester) async {
      await tester.pumpWidget(createSut());

      expect(find.text('Calcular'), findsOneWidget);
      expect(find.text('Limpar'), findsOneWidget);
    });

    testWidgets('Deve aplicar as cores corretas nos botões baseadas no design', (tester) async {
      await tester.pumpWidget(createSut());

      final buttons = tester.widgetList<ElevatedButton>(find.byType(ElevatedButton)).toList();
      expect(buttons, hasLength(2));

      final calculateColor = buttons[0].style?.backgroundColor?.resolve({});
      expect(calculateColor, const Color(0xFF1E94F6));

      final clearColor = buttons[1].style?.backgroundColor?.resolve({});
      const darkColor = Color(0xFF1A222D);
      expect(clearColor, darkColor);
    });

    testWidgets('Deve disparar os respectivos callbacks ao clicar em cada botão', (tester) async {
      int calculateClicks = 0;
      int clearClicks = 0;
      int shareClicks = 0;

      await tester.pumpWidget(createSut(
        onCalculate: () => calculateClicks++,
        onClear: () => clearClicks++,
        onShare: () => shareClicks++,
      ));

      await tester.tap(find.text('Calcular'));
      await tester.pump();

      await tester.tap(find.text('Limpar'));
      await tester.pump();

      expect(calculateClicks, 1);
      expect(clearClicks, 1);
    });
  });
}