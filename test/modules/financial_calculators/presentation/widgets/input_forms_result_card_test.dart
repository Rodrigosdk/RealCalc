import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/themes/extensions/input_forms_result_card_theme.dart';
import 'package:real_calc/modules/financial_calculators/domain/enum/input_field_state.dart';
import 'package:real_calc/modules/financial_calculators/presentation/widgets/input_forms_result_card.dart';

void main() {
  final testTheme = InputFormsResultCardTheme(
    neutralIconColor: Colors.grey,
    neutralBorderColor: Colors.grey.shade300,
    neutralLabelColor: Colors.black54,
    highlightedColor: Colors.orange,
    calculatedColor: Colors.blue,
    errorColor: Colors.red,
    borderRadius: 12,
    badgeStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
  );

  Widget buildTestWidget({
    required TextEditingController controller,
    String label = 'Valor',
    String hint = 'Digite o valor',
    IconData icon = Icons.attach_money,
    InputFieldState state = InputFieldState.neutral,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    VoidCallback? onTap,
  }) {
    return MaterialApp(
      theme: ThemeData(extensions: [testTheme]),
      home: Scaffold(
        body: InputFormsResultCard(
          controller: controller,
          label: label,
          hint: hint,
          icon: icon,
          state: state,
          validator: validator,
          inputFormatters: inputFormatters,
          onTap: onTap,
        ),
      ),
    );
  }

  group('InputFormsResultCard', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renderiza label, hint e ícone corretamente', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        controller: controller,
        label: 'Preço do imóvel',
        hint: 'R\$ 0,00',
        icon: Icons.home,
      ));

      expect(find.text('Preço do imóvel'), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.hintText, 'R\$ 0,00');
    });

    testWidgets('não exibe badge quando o estado é neutro', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        controller: controller,
        state: InputFieldState.neutral,
      ));

      expect(find.text('vazio'), findsNothing);
      expect(find.text('calculado'), findsNothing);
    });

    testWidgets('exibe badge "vazio" quando o estado é highlighted',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        controller: controller,
        state: InputFieldState.highlighted,
      ));

      expect(find.text('vazio'), findsOneWidget);
    });

    testWidgets('exibe badge "calculado" quando o estado é calculated',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        controller: controller,
        state: InputFieldState.calculated,
      ));

      expect(find.text('calculado'), findsOneWidget);
    });

    testWidgets('não exibe badge quando o estado é error', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        controller: controller,
        state: InputFieldState.error,
      ));

      expect(find.text('vazio'), findsNothing);
      expect(find.text('calculado'), findsNothing);
    });

    testWidgets('aplica a cor de destaque correta ao ícone conforme o estado',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        controller: controller,
        icon: Icons.percent,
        state: InputFieldState.calculated,
      ));

      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.percent));
      expect(iconWidget.color, testTheme.calculatedColor);
    });

    testWidgets('usa a borda neutra e fina quando o estado é neutro',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        controller: controller,
        state: InputFieldState.neutral,
      ));

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      final border = decoration.border as Border;

      expect(border.top.width, 0.5);
      expect(decoration.color, isNull);
    });

    testWidgets(
        'usa borda destacada e fundo tintado quando o estado não é neutro',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        controller: controller,
        state: InputFieldState.error,
      ));

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      final border = decoration.border as Border;

      expect(border.top.width, 1);
      expect(decoration.color, isNotNull);
    });

    testWidgets('permite digitar texto e atualiza o controller',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(controller: controller));

      await tester.enterText(find.byType(TextFormField), '1500');
      await tester.pump();

      expect(controller.text, '1500');
    });

    testWidgets('chama onTap ao tocar no campo', (tester) async {
      var tapped = false;

      await tester.pumpWidget(buildTestWidget(
        controller: controller,
        onTap: () => tapped = true,
      ));

      await tester.tap(find.byType(TextFormField));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('valida o campo e exibe mensagem de erro do validator',
        (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [testTheme]),
          home: Scaffold(
            body: Form(
              key: formKey,
              child: InputFormsResultCard(
                controller: controller,
                label: 'Valor',
                hint: 'Digite o valor',
                icon: Icons.attach_money,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Campo obrigatório'), findsOneWidget);
    });

    testWidgets('respeita os inputFormatters ao digitar', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        controller: controller,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ));

      await tester.enterText(find.byType(TextFormField), 'a1b2c3');
      await tester.pump();

      expect(controller.text, '123');
    });

    testWidgets('usa teclado numérico com casas decimais', (tester) async {
      await tester.pumpWidget(buildTestWidget(controller: controller));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(
        textField.keyboardType,
        const TextInputType.numberWithOptions(decimal: true),
      );
    });
  });
}