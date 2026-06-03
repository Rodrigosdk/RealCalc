import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_calc/core/widgets/input_forms.dart'; // Ajuste o seu import

void main() {
  late TextEditingController controller;
  late String label;
  late String hint;
  late Widget prefixIcon;
  late Widget suffixIcon;

  setUpAll(() {
    // Evita chamadas HTTP do GoogleFonts durante os testes
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    controller = TextEditingController();
    label = 'Meu Label';
    hint = 'Digite algo';
    prefixIcon = const Icon(Icons.attach_money);
    suffixIcon = const Icon(Icons.check);
  });

  tearDown(() {
    controller.dispose();
  });

  // Helper para facilitar o pump do widget nos testes
  Widget createSut({
    TextInputType keyboardType = TextInputType.number,
    TextInputAction? textInputAction,
    GestureTapCallback? onTap,
    bool includeSuffix = true,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: InputForms(
          label: label,
          hint: hint,
          controller: controller,
          prefixIcon: prefixIcon,
          suffixIcon: includeSuffix ? suffixIcon : null,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onTap: onTap,
        ),
      ),
    );
  }

  group('InputForms', () {
    testWidgets('Deve exibir o label e o hint text corretamente', (
      tester,
    ) async {
      await tester.pumpWidget(createSut());

      final labelFinder = find.text(label);
      expect(labelFinder, findsOneWidget);

      final Text labelText = tester.widget(labelFinder);
      expect(labelText.style?.fontSize, 14);
      expect(labelText.style?.fontWeight, FontWeight.w600);

      final textFieldFinder = find.byType(TextField);
      final TextField textField = tester.widget(textFieldFinder);
      expect(textField.decoration?.hintText, hint);
    });

    testWidgets('Deve conter o prefixIcon e o suffixIcon configurados', (
      tester,
    ) async {
      await tester.pumpWidget(createSut());

      expect(find.byIcon(Icons.attach_money), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('Não deve quebrar se o suffixIcon for nulo', (tester) async {
      await tester.pumpWidget(createSut(includeSuffix: false));

      expect(find.byIcon(Icons.attach_money), findsOneWidget);
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('Deve aplicar as configurações de teclado e ação corretas', (
      tester,
    ) async {
      await tester.pumpWidget(
        createSut(
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));

      expect(textField.keyboardType, TextInputType.emailAddress);
      expect(textField.textInputAction, TextInputAction.done);
    });

    testWidgets('Deve disparar a função onTap ao clicar no campo', (
      tester,
    ) async {
      int tapCount = 0;

      await tester.pumpWidget(createSut(onTap: () => tapCount++));

      // Simula o clique do usuário no TextField
      await tester.tap(find.byType(TextField));
      await tester.pump(); // Atualiza o frame

      expect(tapCount, 1);
    });

    testWidgets('Deve aceitar entrada de texto e atualizar o controller', (
      tester,
    ) async {
      await tester.pumpWidget(createSut());

      await tester.enterText(find.byType(TextField), '123.45');
      await tester.pump();

      expect(controller.text, '123.45');
    });

    testWidgets(
      'Deve aplicar os estilos corretos para enabledBorder e focusedBorder',
      (tester) async {
        await tester.pumpWidget(createSut());

        // 1. Captura o TextField no estado inicial (Enabled)
        final textFieldFinder = find.byType(TextField);
        TextField textField = tester.widget(textFieldFinder);

        // Valida o enabledBorder
        final enabledBorder = textField.decoration?.enabledBorder as OutlineInputBorder?;
        expect(enabledBorder, isNotNull);
        expect(enabledBorder!.borderSide.color, const Color(0xFF1E293B));
        expect(enabledBorder.borderSide.width, 1.0);
        expect(enabledBorder.borderRadius, BorderRadius.circular(16));

        // 2. Simula o clique no input para ganhar foco (Focused)
        await tester.tap(textFieldFinder);
        await tester.pump(); // Atualiza a árvore de widgets para refletir o foco

        // Recaptura o TextField agora que ele está focado
        textField = tester.widget(textFieldFinder);

        // Valida o focusedBorder
        final focusedBorder = textField.decoration?.focusedBorder as OutlineInputBorder?;
        expect(focusedBorder, isNotNull);
        expect(focusedBorder!.borderSide.color, Color(0xFF1E94F6));
        expect(focusedBorder.borderSide.width, 1.5);
        expect(focusedBorder.borderRadius, BorderRadius.circular(16));
      },
    );
  });
}
