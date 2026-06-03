import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_calc/modules/financing/domain/entities/financing.dart';
import 'package:real_calc/modules/financing/presentation/cubit/financing_cubit.dart';
import 'package:real_calc/modules/financing/presentation/widgets/financing_forms.dart';

class MockFinancingCubit extends MockCubit<FinancingState>
    implements FinancingCubit {}

class FakeFinancing extends Fake implements Financing {}

void main() {
  late FinancingCubit mockCubit;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(FakeFinancing());
  });

  setUp(() {
    mockCubit = MockFinancingCubit();
    // Define o estado inicial padrão do formulário
    when(() => mockCubit.state).thenReturn(FinancingInitial());
  });

  // Helper para criar a árvore com o Cubit injetado
  Widget createSut() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<FinancingCubit>.value(
          value: mockCubit,
          child: const SingleChildScrollView(child: FinancingForms()),
        ),
      ),
    );
  }

  group('FinancingForms - Testes de Interface', () {
    testWidgets(
      'Deve exibir a barra de progresso quando o estado for FinancingLoading',
      (tester) async {
        when(() => mockCubit.state).thenReturn(FinancingLoading());

        await tester.pumpWidget(createSut());

        // Verifica se o indicador visual de carregamento aparece na tela
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'Deve exibir o banner com a mensagem de erro quando o estado for FinancingError',
      (tester) async {
        // 1. Cria um mock específico para este fluxo de escuta
        final whenListenCubit = MockFinancingCubit();
        when(() => whenListenCubit.state).thenReturn(FinancingInitial());

        // 2. Simula o Cubit emitindo o estado de erro logo após iniciar
        const errorMessage =
            'Os seguintes campos não podem ficar vazios: Prazo.';
        whenListen<FinancingState>(
          whenListenCubit,
          Stream.fromIterable([FinancingError(errorMessage)]),
        );

        // 3. Renderiza a tela injetando o Cubit reativo
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<FinancingCubit>.value(
                value: whenListenCubit,
                child: const FinancingForms(),
              ),
            ),
          ),
        );

        // 4. Aguarda o listener do BlocConsumer interceptar o erro e redesenhar a tela
        await tester.pump();

        // 5. Valida a presença do texto do erro
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

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<FinancingCubit>.value(
                value: whenListenCubit,
                child: const FinancingForms(),
              ),
            ),
          ),
        );

        await tester.pump();

        final inputs = find.byType(TextField);

        final TextField inputValor = tester.widget(inputs.at(0));
        final TextField inputPrazo = tester.widget(inputs.at(1));
        final TextField inputTaxa = tester.widget(inputs.at(2));
        final TextField inputPresta = tester.widget(inputs.at(3));

        expect(inputValor.controller?.text, '5000.00');
        expect(inputPrazo.controller?.text, '24');
        expect(inputTaxa.controller?.text, '1.99');
        expect(inputPresta.controller?.text, '350.00');
      },
    );

    testWidgets(
      'Deve disparar o calculate do Cubit ao clicar no botão Calcular',
      (tester) async {
        when(() => mockCubit.calculate(any())).thenAnswer((_) async {});

        await tester.pumpWidget(createSut());

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
                  .having((f) => f.initialValue, 'initialValue', 15000.0)
                  .having((f) => f.months, 'months', 12),
            ),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'Deve limpar todos os campos de texto ao clicar no botão Limpar',
      (tester) async {
        await tester.pumpWidget(createSut());

        final inputs = find.byType(TextField);

        await tester.enterText(inputs.at(0), '2500');
        await tester.pump();

        expect(tester.widget<TextField>(inputs.at(0)).controller?.text, '2500');

        final clearButtonFinder = find.text('Limpar');

        await tester.ensureVisible(clearButtonFinder);
        await tester.pumpAndSettle();

        await tester.tap(clearButtonFinder);
        await tester.pump();

        expect(tester.widget<TextField>(inputs.at(0)).controller?.text, '');
        expect(tester.widget<TextField>(inputs.at(1)).controller?.text, '');
      },

    );
  });
}
