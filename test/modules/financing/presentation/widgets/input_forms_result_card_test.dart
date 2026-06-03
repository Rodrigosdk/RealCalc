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
  final formKey = GlobalKey<FormState>();

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

  Widget createSut({VoidCallback? onTap, String? Function(String?)? validator}) {
    return MaterialApp(
      home: Scaffold(
        body: Form(
          key: formKey,
          child: InputFormsResultCard(
            controller: controller,
            label: label,
            hint: hint,
            prefixIcon: prefixIcon,
            onTap: onTap,
            validator: validator, // Agora repassa o validator se necessário
          ),
        ),
      ),
    );
  }

  group('InputFormsResultCard', () {
    testWidgets('Deve exibir o InputForms interno e a legenda de ajuda abaixo', (tester) async {
      await tester.pumpWidget(createSut());

      expect(find.byType(InputForms), findsOneWidget);

      final helperTextFinder = find.text('Toque para calcular automaticamente');
      expect(helperTextFinder, findsOneWidget);

      final Text helperText = tester.widget(helperTextFinder);
      expect(helperText.style?.color, const Color(0xFF5B6874));
      expect(helperText.style?.fontSize, 12);
    });

    testWidgets('Deve repassar o prefixIcon e fixar o chevron_right como suffixIcon', (tester) async {
      await tester.pumpWidget(createSut());

      expect(find.byIcon(Icons.monetization_on), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('Deve configurar o TextField para teclado decimal e ação concluída', (tester) async {
      await tester.pumpWidget(createSut());

      final textField = tester.widget<TextField>(find.byType(TextField));

      expect(textField.keyboardType, const TextInputType.numberWithOptions(decimal: true));
      expect(textField.textInputAction, TextInputAction.done);
    });

    testWidgets('Deve repassar a ação do callback onTap ao clicar no campo', (tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(createSut(
        onTap: () => wasTapped = true,
      ));

      await tester.tap(find.byType(TextFormField));
      await tester.pump();

      expect(wasTapped, true);
    });

    testWidgets('Deve repassar e exibir o erro do validator se configurado', (tester) async {
      await tester.pumpWidget(createSut(
        validator: (value) => 'Erro do card',
      ));

      formKey.currentState?.validate();
      await tester.pump();

      expect(find.text('Erro do card'), findsOneWidget);
    });
  });
}
