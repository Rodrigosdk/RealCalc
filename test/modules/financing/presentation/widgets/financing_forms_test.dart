import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_calc/modules/financing/domain/entities/financing.dart';
import 'package:real_calc/modules/financing/presentation/cubit/financing_cubit.dart';
import 'package:real_calc/modules/financing/presentation/widgets/financing_forms.dart';

class MockFinancingCubit extends MockCubit<FinancingState> implements FinancingCubit {}

class FakeFinancing extends Fake implements Financing {}

void main() {
  late FinancingCubit mockCubit;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(FakeFinancing());
  });

  setUp(() {
    mockCubit = MockFinancingCubit();
    when(() => mockCubit.state).thenReturn(FinancingInitial());
  });

  Widget createSut(WidgetTester tester, {FinancingCubit? cubit}) {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;

    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<FinancingCubit>.value(
          value: cubit ?? mockCubit,
          child: const SingleChildScrollView(
            child: FinancingForms(),
          ),
        ),
      ),
    );
  }

  group('FinancingForms - Testes de Interface', () {
    testWidgets(
      'Deve exibir a barra de progresso quando o estado for FinancingLoading',
      (tester) async {
        when(() => mockCubit.state).thenReturn(FinancingLoading());

        await tester.pumpWidget(createSut(tester));

        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'Deve exibir o banner com a mensagem de erro quando o estado for FinancingError',
      (tester) async {
        final whenListenCubit = MockFinancingCubit();
        when(() => whenListenCubit.state).thenReturn(FinancingInitial());

        const errorMessage = 'Os seguintes campos não podem ficar vazios: Prazo.';
        whenListen<FinancingState>(
          whenListenCubit,
          Stream.fromIterable([FinancingError(errorMessage)]),
        );

        await tester.pumpWidget(createSut(tester, cubit: whenListenCubit));
        await tester.pump();

        final errorBannerFinder = find.textContaining(
          'Os seguintes campos não podem ficar vazios',
        );
        expect(errorBannerFinder, findsOneWidget);
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
              Financing(
                initialValue: 5000.0,
                months: 24,
                rate: 1.99,
                finalValue: 350.0,
              ),
            ),
          ]),
        );

        await tester.pumpWidget(createSut(tester, cubit: whenListenCubit));
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
        when(() => mockCubit.calculate(any())).thenAnswer((_) async {});

        await tester.pumpWidget(createSut(tester));

        final inputs = find.byType(TextField);
        await tester.enterText(inputs.at(0), '15000');
        await tester.enterText(inputs.at(1), '12');
        await tester.pump();

        await tester.tap(find.text('Calcular'));
        await tester.pump();

        verify(
          () => mockCubit.calculate(
            any(
              that: isA<Financing>()
                  .having((f) => f.initialValue, 'initialValue', 150.00)
                  .having((f) => f.months, 'months', 12),
            ),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'Deve limpar todos os campos de texto ao clicar no botão Limpar',
      (tester) async {
        await tester.pumpWidget(createSut(tester));

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
      },
    );

    testWidgets(
      'Deve aplicar os inputFormatters e formatar o texto em tempo real durante a digitação',
      (tester) async {
        await tester.pumpWidget(createSut(tester));

        final inputs = find.byType(TextField);

        // Digita no input de Valor Financiado (Índice 0 - DecimalInputFormatter)
        await tester.enterText(inputs.at(0), '123456');
        await tester.pump();

        // Digita no input de Prazo (Índice 1 - FilteringTextInputFormatter.digitsOnly)
        await tester.enterText(inputs.at(1), '12abc3');
        await tester.pump();

        final TextField inputValor = tester.widget(inputs.at(0));
        final TextField inputPrazo = tester.widget(inputs.at(1));

        // Valida as formatações ativas em tempo de digitação
        expect(inputValor.controller?.text, '1.234,56');
        expect(inputPrazo.controller?.text, '123');
      },
    );
  });
}
