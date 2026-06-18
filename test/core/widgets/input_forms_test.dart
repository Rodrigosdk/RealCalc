import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_calc/core/themes/app_theme.dart';
import 'package:real_calc/core/themes/color_tokens.dart';
import 'package:real_calc/core/widgets/input_forms.dart';

void main() {
  late TextEditingController controller;
  late String label;
  late String hint;
  late Widget prefixIcon;
  late Widget suffixIcon;
  final formKey = GlobalKey<FormState>();

  setUpAll(() {
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

  Widget createSut({
    TextInputType keyboardType = TextInputType.number,
    TextInputAction? textInputAction,
    GestureTapCallback? onTap,
    bool includeSuffix = true,
    String? Function(String?)? validator,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Form(
          key: formKey,
          child: InputForms(
            label: label,
            hint: hint,
            controller: controller,
            prefixIcon: prefixIcon,
            suffixIcon: includeSuffix ? suffixIcon : null,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            onTap: onTap,
            validator: validator, // Injeção do validator
          ),
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

      await tester.tap(find.byType(TextFormField));
      await tester.pump();

      expect(tapCount, 1);
    });

    testWidgets('Deve aceitar entrada de texto e atualizar o controller', (
      tester,
    ) async {
      await tester.pumpWidget(createSut());

      await tester.enterText(find.byType(TextFormField), '123.45');
      await tester.pump();

      expect(controller.text, '123.45');
    });

    test('AppTheme define corretamente as bordas do InputDecoration', () {
      final theme = AppTheme.darkTheme;
      final decoration = theme.inputDecorationTheme;

      expect(decoration.enabledBorder, isA<OutlineInputBorder>());
      final enabled = decoration.enabledBorder as OutlineInputBorder;
      expect(enabled.borderSide.color, ColorTokens.border);
      expect(enabled.borderSide.width, 1.0);
      expect(enabled.borderRadius, BorderRadius.circular(16));

      expect(decoration.focusedBorder, isA<OutlineInputBorder>());
      final focused = decoration.focusedBorder as OutlineInputBorder;
      expect(focused.borderSide.color, ColorTokens.accent);
      expect(focused.borderSide.width, 1.5);
      expect(focused.borderRadius, BorderRadius.circular(16));
    });

    testWidgets(
      'Deve exibir a mensagem de erro na tela quando o validator falhar',
      (tester) async {
        const errorText = 'Este campo possui um valor inválido';

        await tester.pumpWidget(
          createSut(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return errorText;
              }
              return null;
            },
          ),
        );

        expect(find.text(errorText), findsNothing);

        formKey.currentState?.validate();
        await tester.pump();

        expect(find.text(errorText), findsOneWidget);
      },
    );
  });
}
