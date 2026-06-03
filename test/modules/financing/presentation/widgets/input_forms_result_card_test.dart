import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_calc/core/widgets/input_forms.dart';
import 'package:real_calc/modules/financing/presentation/widgets/input_forms_result_card.dart'; // Ajuste o seu import

void main() {
  late TextEditingController controller;
  late String label;
  late String hint;
  late Widget prefixIcon;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    controller = TextEditingController();
    label = 'Valor Base';
    hint = 'R\$ 0,00';
    prefixIcon = const Icon(Icons.monetization_on);
  });

  tearDown(() {
    controller.dispose();
  });

  Widget createSut({VoidCallback? onTap}) {
    return MaterialApp(
      home: Scaffold(
        body: InputFormsResultCard(
          controller: controller,
          label: label,
          hint: hint,
          prefixIcon: prefixIcon,
          onTap: onTap,
        ),
      ),
    );
  }

  group('InputFormsResultCard', () {
    testWidgets('Deve exibir o InputForms interno e a legenda de ajuda abaixo', (tester) async {
      await tester.pumpWidget(createSut());

      // 1. Valida se o InputForms foi renderizado
      expect(find.byType(InputForms), findsOneWidget);

      // 2. Valida se a mensagem informativa está na tela com o estilo correto
      final helperTextFinder = find.text('Toque para calcular automaticamente');
      expect(helperTextFinder, findsOneWidget);

      final Text helperText = tester.widget(helperTextFinder);
      expect(helperText.style?.color, const Color(0xFF5B6874));
      expect(helperText.style?.fontSize, 12);
    });

    testWidgets('Deve repassar o prefixIcon e fixar o chevron_right como suffixIcon', (tester) async {
      await tester.pumpWidget(createSut());

      // Verifica o ícone customizado de entrada
      expect(find.byIcon(Icons.monetization_on), findsOneWidget);

      // Verifica se o ícone de seta embutido no componente aparece
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('Deve configurar o TextField para teclado decimal e ação concluída', (tester) async {
      await tester.pumpWidget(createSut());

      final textField = tester.widget<TextField>(find.byType(TextField));

      // Garante que o input use a configuração de decimais solicitada no design
      expect(textField.keyboardType, const TextInputType.numberWithOptions(decimal: true));
      expect(textField.textInputAction, TextInputAction.done);
    });

    testWidgets('Deve repassar a ação do callback onTap ao clicar no campo', (tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(createSut(
        onTap: () => wasTapped = true,
      ));

      // Clica diretamente no TextField interno para verificar se o callback borbulha corretamente
      await tester.tap(find.byType(TextField));
      await tester.pump();

      expect(wasTapped, true);
    });
  });
}
