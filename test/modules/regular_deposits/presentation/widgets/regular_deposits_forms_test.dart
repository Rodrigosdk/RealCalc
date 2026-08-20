import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_calc/core/themes/app_theme.dart';
import 'package:real_calc/modules/regular_deposits/domain/entities/regular_deposit.dart';
import 'package:real_calc/modules/regular_deposits/presentation/cubit/regular_deposits_cubit.dart';
import 'package:real_calc/modules/regular_deposits/presentation/widgets/regular_deposits_forms.dart';

class MockRegularDepositsCubit extends MockCubit<RegularDepositsState>
    implements RegularDepositsCubit {}

class FakeRegularDeposit extends Fake implements RegularDeposit {}

void main() {
  late RegularDepositsCubit mockCubit;

  setUpAll(() {
    registerFallbackValue(FakeRegularDeposit());
  });

  setUp(() {
    mockCubit = MockRegularDepositsCubit();
    when(() => mockCubit.state).thenReturn(RegularDepositsInitial());
  });

  Widget createSut({RegularDepositsCubit? cubit}) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: Scaffold(
        body: BlocProvider<RegularDepositsCubit>.value(
          value: cubit ?? mockCubit,
          child: const SingleChildScrollView(
            child: RegularDepositsForms(),
          ),
        ),
      ),
    );
  }

  group('RegularDepositsForms - Testes de Interface', () {
    testWidgets('Deve exibir a barra de progresso quando o estado for RegularDepositsLoading',
        (tester) async {
      when(() => mockCubit.state).thenReturn(RegularDepositsLoading());

      await tester.pumpWidget(createSut());

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('Deve exibir o banner com a mensagem de erro quando o estado for RegularDepositsError',
        (tester) async {
      final listenCubit = MockRegularDepositsCubit();
      when(() => listenCubit.state).thenReturn(RegularDepositsInitial());

      whenListen<RegularDepositsState>(
        listenCubit,
        Stream.fromIterable([RegularDepositsError('Os campos obrigatórios devem ser preenchidos.')]),
      );

      await tester.pumpWidget(createSut(cubit: listenCubit));
      await tester.pump();

      expect(find.textContaining('Os campos obrigatórios devem ser preenchidos'), findsOneWidget);
    });

    testWidgets('Deve disparar o calculate do Cubit ao clicar no botão Calcular',
        (tester) async {
      when(() => mockCubit.calculate(any())).thenAnswer((_) {});

      await tester.pumpWidget(createSut());

      final inputs = find.byType(TextField);
      await tester.enterText(inputs.at(0), '1500');
      await tester.enterText(inputs.at(1), '12');
      await tester.pump();

      await tester.ensureVisible(find.text('Calcular'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Calcular'));
      await tester.pump();

      verify(() => mockCubit.calculate(any())).called(1);
    });

    testWidgets('Deve limpar todos os campos de texto ao clicar no botão Limpar',
        (tester) async {
      await tester.pumpWidget(createSut());

      final inputs = find.byType(TextField);

      await tester.enterText(inputs.at(0), '2500');
      await tester.pump();

      expect(tester.widget<TextField>(inputs.at(0)).controller?.text, '25,00');

      await tester.ensureVisible(find.text('Limpar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Limpar'));
      await tester.pump();

      expect(tester.widget<TextField>(inputs.at(0)).controller?.text, '');
      expect(tester.widget<TextField>(inputs.at(1)).controller?.text, '');
    });
  });
}
