import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/themes/color_tokens.dart';
import 'package:real_calc/core/themes/extensions/input_forms_result_card_theme.dart';
import 'package:real_calc/core/themes/text_styles.dart';
import 'package:real_calc/core/utils/decimal_input_formatter.dart';
import 'package:real_calc/core/widgets/input_forms.dart';
import 'package:real_calc/modules/financing/presentation/widgets/input_forms_result_card.dart';

void main() {
  late TextEditingController controller;
  late String label;
  late String hint;
  late Widget prefixIcon;
  final formKey = GlobalKey<FormState>();

  setUp(() {
    controller = TextEditingController();
    label = 'Valor Base';
    hint = 'R\$ 0,00';
    prefixIcon = const Icon(Icons.monetization_on);
  });

  tearDown(() {
    controller.dispose();
  });

  Widget createSut({
    VoidCallback? onTap,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return MaterialApp(
      theme: ThemeData(
        extensions: [
          InputFormsResultCardTheme(
            suffixIconColor: ColorTokens.textHint,
            helperTextStyle: AppTextStyles.inputHelperText,
          ),
        ],
      ),
      home: Scaffold(
        body: Form(
          key: formKey,
          child: InputFormsResultCard(
            controller: controller,
            label: label,
            hint: hint,
            prefixIcon: prefixIcon,
            onTap: onTap,
            validator: validator,
            inputFormatters: inputFormatters,
          ),
        ),
      ),
    );
  }

  group('InputFormsResultCard', () {
    testWidgets(
      'Deve exibir o InputForms interno e a legenda de ajuda abaixo',
      (tester) async {
        await tester.pumpWidget(createSut());

        expect(find.byType(InputForms), findsOneWidget);

        final helperTextFinder = find.text(
          'Toque para calcular automaticamente',
        );
        expect(helperTextFinder, findsOneWidget);

        final Text helperText = tester.widget(helperTextFinder);
        expect(helperText.style, AppTextStyles.inputHelperText);
      },
    );

    testWidgets(
      'Deve repassar o prefixIcon e fixar o chevron_right como suffixIcon',
      (tester) async {
        await tester.pumpWidget(createSut());

        expect(find.byIcon(Icons.monetization_on), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      },
    );

    testWidgets(
      'Deve repassar a ação do callback onTap ao clicar na seta lateral',
      (tester) async {
        bool wasTapped = false;

        await tester.pumpWidget(createSut(onTap: () => wasTapped = true));

        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pump();

        expect(wasTapped, true);
      },
    );

    testWidgets('Deve repassar e exibir o erro do validator se configurado', (
      tester,
    ) async {
      await tester.pumpWidget(createSut(validator: (value) => 'Erro do card'));

      formKey.currentState?.validate();
      await tester.pump();

      expect(find.text('Erro do card'), findsOneWidget);
    });

    testWidgets(
      'Deve configurar o TextFormField para teclado decimal e ação concluída',
      (tester) async {
        await tester.pumpWidget(createSut());

        // Use TextField, não TextFormField
        final textField = tester.widget<TextField>(find.byType(TextField));

        expect(
          textField.keyboardType,
          const TextInputType.numberWithOptions(decimal: true),
        );
        expect(textField.textInputAction, TextInputAction.done);
      },
    );

    testWidgets(
      'Deve repassar os inputFormatters configurados para o TextField interno',
      (tester) async {
        await tester.pumpWidget(
          createSut(inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
        );

        // O inputFormatters está no TextField, não no TextFormField
        final textField = tester.widget<TextField>(find.byType(TextField));

        expect(textField.inputFormatters, isNotNull);
        expect(textField.inputFormatters!.length, 1);
        expect(
          textField.inputFormatters!.first,
          isA<FilteringTextInputFormatter>(),
        );
      },
    );
    testWidgets(
      'Deve aplicar a formatação decimal em tempo real ao digitar no card',
      (tester) async {
        await tester.pumpWidget(
          createSut(inputFormatters: [DecimalInputFormatter()]),
        );

        await tester.enterText(find.byType(TextFormField), '5');
        await tester.pump();

        expect(controller.text, '0,05');
        expect(find.text('0,05'), findsOneWidget);
      },
    );
  });
}
