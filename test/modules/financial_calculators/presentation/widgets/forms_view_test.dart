import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_calc/core/themes/color_tokens.dart';
import 'package:real_calc/core/themes/extensions/financing_forms_theme.dart';
import 'package:real_calc/core/themes/extensions/input_forms_result_card_theme.dart';
import 'package:real_calc/core/themes/extensions/options_bottom_forms_theme.dart';
import 'package:real_calc/core/themes/text_styles.dart';
import 'package:real_calc/core/utils/decimal_input_formatter.dart';
import 'package:real_calc/core/widgets/options_bottom_forms.dart';
import 'package:real_calc/modules/financial_calculators/domain/entities/financial_calculation.dart';
import 'package:real_calc/modules/financial_calculators/domain/enum/financial_calculation_target.dart';
import 'package:real_calc/core/widgets/types/input_field_state.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/financing/financing_cubit.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/forms/financing_form_cubit.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/forms/financing_form_state.dart';
import 'package:real_calc/modules/financial_calculators/presentation/models/field_spec.dart';
import 'package:real_calc/modules/financial_calculators/presentation/widgets/forms_view.dart';
import 'package:real_calc/core/widgets/input_forms_result_card.dart';

import '../../../../mock_cubits.dart';
import '../../../../test_harness.dart';

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

  const optionsBottomFormsTheme = OptionsBottomFormsTheme(
    calculateButtonBackground: Colors.orange,
    calculateButtonForeground: Colors.white,
    actionButtonBackground: Colors.grey,
    actionButtonForeground: Colors.black87,
    borderButtonColor: ColorTokens.successContainerBorder,
  );

  final financingFormsTheme = FinancingFormsTheme(
    progressIndicatorColor: Colors.blue,
    errorContainerPadding: const EdgeInsets.all(12),
    errorBackgroundColor: Colors.red.shade50,
    errorBorderColor: Colors.red,
    iconColor: Colors.white,
    errorTextStyle: const TextStyle(color: Colors.red, fontSize: 13),
  );

  final sharedThemeExtensions = ThemeData(
    extensions: [resultCardTheme, optionsBottomFormsTheme, financingFormsTheme],
  );

  group('FormsView - Comportamento genérico (widget isolado)', () {
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

    Widget buildGenericFormsView({
      bool isLoading = false,
      String? errorMessage,
      VoidCallback? onCalculate,
      VoidCallback? onClear,
      ValueChanged<_TestField>? onFieldTap,
      InputFieldState Function(_TestField field)? stateOf,
    }) {
      return MaterialApp(
        theme: sharedThemeExtensions,
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

    testWidgets('renderiza um InputFormsResultCard para cada FieldSpec',
        (tester) async {
      await tester.pumpWidget(buildGenericFormsView());

      expect(find.byType(InputFormsResultCard), findsNWidgets(3));
      expect(find.text('Valor do imóvel'), findsOneWidget);
      expect(find.text('Taxa de juros'), findsOneWidget);
      expect(find.text('Prazo'), findsOneWidget);
    });

    testWidgets('exibe o banner de erro quando errorMessage não é nulo',
        (tester) async {
      await tester.pumpWidget(
        buildGenericFormsView(errorMessage: 'Preencha todos os campos'),
      );

      expect(find.text('Preencha todos os campos'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('não exibe o banner de erro quando errorMessage é nulo',
        (tester) async {
      await tester.pumpWidget(buildGenericFormsView());

      expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
    });

    testWidgets('exibe indicador de carregamento quando isLoading é true',
        (tester) async {
      await tester.pumpWidget(buildGenericFormsView(isLoading: true));

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets(
        'não exibe indicador de carregamento quando isLoading é false',
        (tester) async {
      await tester.pumpWidget(buildGenericFormsView());

      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('chama onFieldTap com o campo correto ao tocar no card',
        (tester) async {
      _TestField? tappedField;

      await tester.pumpWidget(buildGenericFormsView(
        onFieldTap: (field) => tappedField = field,
      ));

      await tester.tap(find.byType(TextField).at(1));
      await tester.pump();

      expect(tappedField, _TestField.taxa);
    });

    testWidgets('usa o controller correto para cada campo', (tester) async {
      await tester.pumpWidget(buildGenericFormsView());

      await tester.enterText(find.byType(TextField).at(0), '500000');
      await tester.pump();

      expect(controllers[_TestField.valor]!.text, '500000');
      expect(controllers[_TestField.taxa]!.text, isEmpty);
      expect(controllers[_TestField.prazo]!.text, isEmpty);
    });

    testWidgets('usa o estado correto para cada campo', (tester) async {
      await tester.pumpWidget(buildGenericFormsView(
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

      await tester.pumpWidget(buildGenericFormsView(
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
      await tester.pumpWidget(buildGenericFormsView());

      await tester.enterText(find.byType(TextField).at(1), 'a1b2c3');
      await tester.pump();

      expect(controllers[_TestField.taxa]!.text, '123');
    });
  });

  group('FormsView - Integração com FinancingFormCubit real', () {
    late TestHarness harness;

    final createdFormCubits = <FinancingFormCubit>[];

    setUp(() {
      harness = TestHarness()..setUpDefaults();
    });

    tearDown(() async {
      harness.dispose();
      for (final formCubit in createdFormCubits) {
        await formCubit.close();
      }
      createdFormCubits.clear();
    });

    Widget createFinancingFormsSut({FinancingCubit? cubit}) {
      final formCubit = FinancingFormCubit();
      createdFormCubits.add(formCubit);
      final activeCubit = cubit ?? harness.financingCubit;

      final fieldSpecs = [
        FieldSpec(
          field: FinancialCalculationTarget.initialValue,
          label: 'Valor financiado (R\$)',
          hint: '0,00',
          icon: Icons.attach_money,
          formatters: [DecimalInputFormatter()],
        ),
        FieldSpec(
          field: FinancialCalculationTarget.periods,
          label: 'Prazo (meses)',
          hint: '0',
          icon: Icons.calendar_today,
          formatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        FieldSpec(
          field: FinancialCalculationTarget.interestRate,
          label: 'Taxa de juros (% ao mês)',
          hint: '0,00',
          icon: Icons.percent,
          formatters: [DecimalInputFormatter()],
        ),
        FieldSpec(
          field: FinancialCalculationTarget.finalValue,
          label: 'Valor da prestação',
          hint: '0,00',
          icon: Icons.payments,
          formatters: [DecimalInputFormatter()],
        ),
      ];

      return MaterialApp(
        theme: ThemeData(
          extensions: [
            InputFormsResultCardTheme(
              neutralBorderColor: ColorTokens.border,
              neutralLabelColor: ColorTokens.textSecondary,
              neutralIconColor: ColorTokens.textSecondary,
              highlightedColor: ColorTokens.accentAmber,
              calculatedColor: ColorTokens.success,
              errorColor: ColorTokens.error,
              badgeStyle: AppTextStyles.stateBadge,
            ),
            const OptionsBottomFormsTheme(
              calculateButtonBackground: ColorTokens.accentAmber,
              calculateButtonForeground: Colors.white,
              actionButtonBackground: ColorTokens.surface,
              actionButtonForeground: ColorTokens.textSecondary, 
              borderButtonColor: ColorTokens.successContainerBorder,
            ),
            FinancingFormsTheme(
              iconColor: ColorTokens.accentAmber,
              progressIndicatorColor: ColorTokens.accentAmber,
              errorBackgroundColor: ColorTokens.errorContainerBg,
              errorBorderColor: ColorTokens.errorContainerBorder,
              errorTextStyle: AppTextStyles.errorBannerText,
            ),
          ],
        ),
        home: Scaffold(
          body: MultiBlocProvider(
            providers: [
              BlocProvider<FinancingCubit>.value(value: activeCubit),
              BlocProvider<FinancingFormCubit>.value(value: formCubit),
            ],
            child: SingleChildScrollView(
              child: BlocListener<FinancingCubit, FinancingState>(
                listener: (context, state) {
                  if (state is FinancingCalculated) {
                    formCubit.applyResult(state.value, state.calculatedField);
                  } else if (state is FinancingError) {
                    formCubit.invalidateCalculatedField();
                  }
                },
                child: BlocBuilder<FinancingCubit, FinancingState>(
                  builder: (context, financingState) {
                    return BlocBuilder<FinancingFormCubit, FinancingFormState>(
                      bloc: formCubit,
                      builder: (context, formState) {
                        void calculate() {
                          if (formState.canCalculate) {
                            activeCubit.calculate(formCubit.financing);
                          }
                        }

                        return FormsView(
                          fieldSpecs: fieldSpecs,
                          controllerFor: formCubit.controllerFor,
                          stateOf: formState.stateOf,
                          isLoading: financingState is FinancingLoading,
                          errorMessage: financingState is FinancingError
                              ? financingState.message
                              : null,
                          onCalculate: calculate,
                          onClear: formCubit.clear,
                          onFieldTap: (field) {
                            if (formState.stateOf(field) ==
                                InputFieldState.highlighted) {
                              calculate();
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets(
      'Deve exibir a barra de progresso quando o estado for FinancingLoading',
      (tester) async {
        when(() => harness.financingCubit.state)
            .thenReturn(FinancingLoading());

        await tester.pumpWidget(createFinancingFormsSut());

        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'Deve exibir o banner com a mensagem de erro quando o estado for FinancingError',
      (tester) async {
        final whenListenCubit = MockFinancingCubit();

        when(() => whenListenCubit.state).thenReturn(FinancingInitial());

        const errorMessage =
            'Os seguintes campos não podem ficar vazios: Prazo.';

        whenListen<FinancingState>(
          whenListenCubit,
          Stream.fromIterable([FinancingError(errorMessage)]),
        );

        await tester.pumpWidget(
          createFinancingFormsSut(cubit: whenListenCubit),
        );
        await tester.pump();

        expect(
          find.textContaining('Os seguintes campos não podem ficar vazios'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Deve preencher os inputs de texto automaticamente quando emitir FinancingCalculated',
      (tester) async {
        final whenListenCubit = MockFinancingCubit();

        when(() => whenListenCubit.state).thenReturn(FinancingInitial());

        whenListen<FinancingState>(
          whenListenCubit,
          Stream.fromIterable([
            FinancingCalculated(
              FinancialCalculation(
                initialValue: 5000.0,
                periods: 24,
                rate: 1.99,
                finalValue: 350.0,
              ),
              FinancialCalculationTarget.finalValue,
            ),
          ]),
        );

        await tester.pumpWidget(
          createFinancingFormsSut(cubit: whenListenCubit),
        );
        await tester.pump();

        final inputs = find.byType(TextField);

        final TextField inputValor = tester.widget(inputs.at(0));
        final TextField inputPrazo = tester.widget(inputs.at(1));
        final TextField inputTaxa = tester.widget(inputs.at(2));
        final TextField inputPresta = tester.widget(inputs.at(3));

        expect(inputValor.controller?.text, '5.000,00');
        expect(inputPrazo.controller?.text, '24');
        expect(inputTaxa.controller?.text, '1,99');
        expect(inputPresta.controller?.text, '350,00');
      },
    );

    testWidgets(
      'Deve disparar o calculate do Cubit ao clicar no botão Calcular',
      (tester) async {
        when(() => harness.financingCubit.calculate(any()))
            .thenAnswer((_) async {});

        await tester.pumpWidget(createFinancingFormsSut());

        final inputs = find.byType(TextField);

        await tester.enterText(inputs.at(0), '15000');
        await tester.enterText(inputs.at(1), '12');
        await tester.enterText(inputs.at(2), '199');
        await tester.pump();

        await tester.tap(find.text('Calcular'));
        await tester.pump();

        verify(
          () => harness.financingCubit.calculate(
            any(
              that: isA<FinancialCalculation>()
                  .having((f) => f.initialValue, 'initialValue', 150.00)
                  .having((f) => f.periods, 'months', 12)
                  .having((f) => f.rate, 'rate', 1.99),
            ),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'Deve limpar todos os campos de texto ao clicar no botão Limpar',
      (tester) async {
        await tester.pumpWidget(createFinancingFormsSut());

        final inputs = find.byType(TextField);

        await tester.enterText(inputs.at(0), '2500');
        await tester.pump();

        expect(
          tester.widget<TextField>(inputs.at(0)).controller?.text,
          '25,00',
        );

        final clearButtonFinder = find.text('Limpar');

        await tester.ensureVisible(clearButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(clearButtonFinder);
        await tester.pump();

        expect(tester.widget<TextField>(inputs.at(0)).controller?.text, '');
        expect(tester.widget<TextField>(inputs.at(1)).controller?.text, '');
      },
    );

    testWidgets(
      'Deve aplicar os inputFormatters e formatar o texto em tempo real durante a digitação',
      (tester) async {
        await tester.pumpWidget(createFinancingFormsSut());

        final inputs = find.byType(TextField);

        await tester.enterText(inputs.at(0), '123456');
        await tester.pump();

        await tester.enterText(inputs.at(1), '12abc3');
        await tester.pump();

        final TextField inputValor = tester.widget(inputs.at(0));
        final TextField inputPrazo = tester.widget(inputs.at(1));

        expect(inputValor.controller?.text, '1.234,56');
        expect(inputPrazo.controller?.text, '123');
      },
    );
  });
}