import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_calc/core/themes/color_tokens.dart';
import 'package:real_calc/core/themes/extensions/financing_forms_theme.dart';
import 'package:real_calc/core/themes/extensions/input_forms_result_card_theme.dart';
import 'package:real_calc/core/themes/extensions/options_bottom_forms_theme.dart';
import 'package:real_calc/core/themes/text_styles.dart';
import 'package:real_calc/modules/future_value/domain/entities/future_value.dart';
import 'package:real_calc/modules/future_value/presentation/cubit/future_value_cubit.dart';
import 'package:real_calc/modules/future_value/presentation/widgets/future_value_forms.dart';

class MockFutureValueCubit extends MockCubit<FutureValueState> implements FutureValueCubit {}
class FakeFutureValue extends Fake implements FutureValue {}

void main() {
  late FutureValueCubit mockCubit;

  setUpAll(() {
    registerFallbackValue(FakeFutureValue());
  });

  setUp(() {
    mockCubit = MockFutureValueCubit();
    when(() => mockCubit.state).thenReturn(FutureValueInitial());
  });

  Widget createSut({FutureValueCubit? cubit}) {
    return MaterialApp(
      theme: ThemeData(
        extensions: [
          InputFormsResultCardTheme(
            suffixIconColor: ColorTokens.textHint,
            helperTextStyle: AppTextStyles.inputHelperText,
          ),
          const OptionsBottomFormsTheme(
            calculateButtonBackground: ColorTokens.accentAmber,
            calculateButtonForeground: Colors.white,
            actionButtonBackground: ColorTokens.surface,
            actionButtonForeground: ColorTokens.textSecondary,
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
        body: BlocProvider<FutureValueCubit>.value(
          value: cubit ?? mockCubit,
          child: const SingleChildScrollView(
            child: FutureValueForms(),
          ),
        ),
      ),
    );
  }

  group('FutureValueForms - Testes de Interface', () {
    testWidgets('Deve exibir a barra de progresso quando o estado for FutureValueLoading', (tester) async {
      when(() => mockCubit.state).thenReturn(FutureValueLoading());
      await tester.pumpWidget(createSut());
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('Deve exibir o banner com a mensagem de erro quando o estado for FutureValueError', (tester) async {
      final whenListenCubit = MockFutureValueCubit();
      when(() => whenListenCubit.state).thenReturn(FutureValueInitial());

      const errorMessage = 'Os seguintes campos não podem ficar vazios: Prazo.';

      whenListen<FutureValueState>(
        whenListenCubit,
        Stream.fromIterable([FutureValueError(errorMessage)]),
      );

      await tester.pumpWidget(createSut(cubit: whenListenCubit));
      await tester.pump();

      expect(find.textContaining('Os seguintes campos não podem ficar vazios'), findsOneWidget);
    });

    testWidgets('Deve preencher os inputs de texto automaticamente quando emitir FutureValueCalculated', (tester) async {
      final whenListenCubit = MockFutureValueCubit();
      when(() => whenListenCubit.state).thenReturn(FutureValueInitial());

      whenListen<FutureValueState>(
        whenListenCubit,
        Stream.fromIterable([
          FutureValueCalculated(FutureValue(
            capital: 5000.0,
            months: 24,
            interestRate: 1.99,
            finalValue: 350.0,
          )),
        ]),
      );

      await tester.pumpWidget(createSut(cubit: whenListenCubit));
      await tester.pump();

      final inputs = find.byType(TextField);

      final TextField inputCapital = tester.widget(inputs.at(0));
      final TextField inputPrazo = tester.widget(inputs.at(1));
      final TextField inputTaxa = tester.widget(inputs.at(2));
      final TextField inputFinal = tester.widget(inputs.at(3));

      expect(inputCapital.controller?.text, '5.000,00');
      expect(inputPrazo.controller?.text, '24');
      expect(inputTaxa.controller?.text, '1,99');
      expect(inputFinal.controller?.text, '350,00');
    });

    testWidgets('Deve disparar o calculate do Cubit ao clicar no botão Calcular', (tester) async {
      when(() => mockCubit.calculate(any())).thenAnswer((_) async {});

      await tester.pumpWidget(createSut());

      final inputs = find.byType(TextField);
      await tester.enterText(inputs.at(0), '15000');
      await tester.enterText(inputs.at(1), '12');
      await tester.pump();

      await tester.tap(find.text('Calcular'));
      await tester.pump();

      verify(
        () => mockCubit.calculate(any(
          that: isA<FutureValue>()
              .having((f) => f.capital, 'capital', 150.00)
              .having((f) => f.months, 'months', 12),
        )),
      ).called(1);
    });

    testWidgets('Deve limpar todos os campos de texto ao clicar no botão Limpar', (tester) async {
      await tester.pumpWidget(createSut());

      final inputs = find.byType(TextField);

      await tester.enterText(inputs.at(0), '2500');
      await tester.pump();

      expect(tester.widget<TextField>(inputs.at(0)).controller?.text, '25,00');

      final clearButtonFinder = find.text('Limpar');

      await tester.ensureVisible(clearButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(clearButtonFinder);
      await tester.pump();

      expect(tester.widget<TextField>(inputs.at(0)).controller?.text, '');
      expect(tester.widget<TextField>(inputs.at(1)).controller?.text, '');
    });

    testWidgets('Deve aplicar os inputFormatters e formatar o texto em tempo real durante a digitação', (tester) async {
      await tester.pumpWidget(createSut());

      final inputs = find.byType(TextField);

      await tester.enterText(inputs.at(0), '123456');
      await tester.pump();

      await tester.enterText(inputs.at(1), '12abc3');
      await tester.pump();

      final TextField inputCapital = tester.widget(inputs.at(0));
      final TextField inputPrazo = tester.widget(inputs.at(1));

      expect(inputCapital.controller?.text, '1.234,56');
      expect(inputPrazo.controller?.text, '123');
    });
  });
}
