import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/themes/extensions/financing_forms_theme.dart';
import 'package:real_calc/core/themes/extensions/input_forms_result_card_theme.dart';
import 'package:real_calc/core/themes/extensions/options_bottom_forms_theme.dart';
import 'package:real_calc/core/widgets/options_bottom_forms.dart';
import 'package:real_calc/modules/financial_calculators/domain/enum/input_field_state.dart';

import 'package:real_calc/modules/financial_calculators/presentation/models/field_spec.dart';
import 'package:real_calc/modules/financial_calculators/presentation/widgets/forms_view.dart';
import 'package:real_calc/modules/financial_calculators/presentation/widgets/input_forms_result_card.dart';

enum _TestField { valor, taxa, prazo }

void main() {
  final resultCardTheme = InputFormsResultCardTheme(
    neutralIconColor: Colors.grey,
    neutralBorderColor: Colors.grey.shade300,
    neutralLabelColor: Colors.black54,
    highlightedColor: Colors.orange,
    calculatedColor: Colors.blue,
    errorColor: Colors.red,
    borderRadius: 12,
    badgeStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
  );

  final financingFormsTheme = FinancingFormsTheme(
    progressIndicatorColor: Colors.blue,
    errorContainerPadding: const EdgeInsets.all(12),
    errorBackgroundColor: Colors.red.shade50,
    errorBorderColor: Colors.red,
    iconColor: Colors.white,
    errorTextStyle: const TextStyle(color: Colors.red, fontSize: 13),
  );

  // Faltava: OptionsBottomForms (renderizado dentro do FormsView, no botão
  // Calcular/Limpar) também lê sua própria extensão de tema via
  // Theme.of(context).extension<OptionsBottomFormsTheme>()!. Sem ela
  // registrada, o build quebra com "Null check operator used on a null
  // value" assim que o FormsView tenta montar o OptionsBottomForms.
  const optionsBottomFormsTheme = OptionsBottomFormsTheme(
    calculateButtonBackground: Colors.orange,
    calculateButtonForeground: Colors.white,
    actionButtonBackground: Colors.grey,
    actionButtonForeground: Colors.black87,
  );

  late Map<_TestField, TextEditingController> controllers;
  late List<FieldSpec<_TestField>> fieldSpecs;

  setUp(() {
    controllers = {
      _TestField.valor: TextEditingController(),
      _TestField.taxa: TextEditingController(),
      _TestField.prazo: TextEditingController(),
    };

    fieldSpecs = [
      FieldSpec<_TestField>(
        field: _TestField.valor,
        label: 'Valor do imóvel',
        hint: 'R\$ 0,00',
        icon: Icons.home,
        formatters: const [],
      ),
      FieldSpec<_TestField>(
        field: _TestField.taxa,
        label: 'Taxa de juros',
        hint: '0,00%',
        icon: Icons.percent,
        formatters: [FilteringTextInputFormatter.digitsOnly],
      ),
      FieldSpec<_TestField>(
        field: _TestField.prazo,
        label: 'Prazo',
        hint: '0 meses',
        icon: Icons.calendar_month,
        formatters: const [],
      ),
    ];
  });

  tearDown(() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
  });

  Widget buildTestWidget({
    bool isLoading = false,
    String? errorMessage,
    VoidCallback? onCalculate,
    VoidCallback? onClear,
    ValueChanged<_TestField>? onFieldTap,
    InputFieldState Function(_TestField field)? stateOf,
  }) {
    return MaterialApp(
      theme: ThemeData(
        extensions: [
          resultCardTheme,
          financingFormsTheme,
          optionsBottomFormsTheme,
        ],
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          child: FormsView<_TestField>(
            fieldSpecs: fieldSpecs,
            controllerFor: (field) => controllers[field]!,
            stateOf: stateOf ?? (_) => InputFieldState.neutral,
            isLoading: isLoading,
            errorMessage: errorMessage,
            onCalculate: onCalculate,
            onClear: onClear,
            onFieldTap: onFieldTap,
          ),
        ),
      ),
    );
  }

  group('FormsView', () {
    testWidgets('renderiza um InputFormsResultCard para cada FieldSpec',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(InputFormsResultCard), findsNWidgets(3));
      expect(find.text('Valor do imóvel'), findsOneWidget);
      expect(find.text('Taxa de juros'), findsOneWidget);
      expect(find.text('Prazo'), findsOneWidget);
    });

    testWidgets('exibe o banner de erro quando errorMessage não é nulo',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(errorMessage: 'Preencha todos os campos'),
      );

      expect(find.text('Preencha todos os campos'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('não exibe o banner de erro quando errorMessage é nulo',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
    });

    testWidgets('exibe indicador de carregamento quando isLoading é true',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(isLoading: true));

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets(
        'não exibe indicador de carregamento quando isLoading é false',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('chama onFieldTap com o campo correto ao tocar no card',
        (tester) async {
      _TestField? tappedField;

      await tester.pumpWidget(buildTestWidget(
        onFieldTap: (field) => tappedField = field,
      ));

      // O segundo card da lista corresponde ao campo "taxa".
      await tester.tap(find.byType(TextField).at(1));
      await tester.pump();

      expect(tappedField, _TestField.taxa);
    });

    testWidgets('usa o controller correto para cada campo', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(find.byType(TextField).at(0), '500000');
      await tester.pump();

      expect(controllers[_TestField.valor]!.text, '500000');
      expect(controllers[_TestField.taxa]!.text, isEmpty);
      expect(controllers[_TestField.prazo]!.text, isEmpty);
    });

    testWidgets('usa o estado correto para cada campo', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        stateOf: (field) => field == _TestField.taxa
            ? InputFieldState.error
            : InputFieldState.neutral,
      ));

      final taxaIcon = tester.widget<Icon>(find.byIcon(Icons.percent));
      expect(taxaIcon.color, resultCardTheme.errorColor);

      final valorIcon = tester.widget<Icon>(find.byIcon(Icons.home));
      expect(valorIcon.color, resultCardTheme.neutralIconColor);
    });

    testWidgets('passa onCalculate e onClear para o OptionsBottomForms',
        (tester) async {
      void calculate() {}
      void clear() {}

      await tester.pumpWidget(buildTestWidget(
        onCalculate: calculate,
        onClear: clear,
      ));

      final optionsWidget = tester.widget<OptionsBottomForms>(
        find.byType(OptionsBottomForms),
      );

      expect(optionsWidget.onCalculate, calculate);
      expect(optionsWidget.onClear, clear);
    });

    testWidgets('respeita os inputFormatters definidos no FieldSpec',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // O campo "taxa" (índice 1) tem digitsOnly como formatter no FieldSpec.
      await tester.enterText(find.byType(TextField).at(1), 'a1b2c3');
      await tester.pump();

      expect(controllers[_TestField.taxa]!.text, '123');
    });
  });
}