import 'package:flutter_test/flutter_test.dart';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_calc/core/widgets/app_bar_forms.dart';
import 'package:real_calc/core/widgets/title_widget.dart';
import 'package:real_calc/modules/financing/presentation/cubit/financing_cubit.dart';
import 'package:real_calc/modules/financing/presentation/pages/page.dart';
import 'package:real_calc/modules/financing/presentation/widgets/financing_forms.dart';
import 'package:real_calc/modules/financing/presentation/widgets/help_card.dart';

class MockFinancingCubit extends MockCubit<FinancingState> implements FinancingCubit {}

void main() {
  late FinancingCubit mockCubit;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    mockCubit = MockFinancingCubit();
    when(() => mockCubit.state).thenReturn(FinancingInitial());
  });

  Widget createSut() {
    return MaterialApp(
      home: BlocProvider<FinancingCubit>.value(
        value: mockCubit,
        child: const FinancingPage(),
      ),
    );
  }

  group('FinancingPage - Testes de Integração da Tela', () {
    testWidgets('Deve renderizar a árvore de componentes completa com sucesso', (tester) async {
      await tester.pumpWidget(createSut());

      // 1. Verifica se a estrutura de componentes customizados está presente
      expect(find.byType(AppBarForms), findsOneWidget);
      expect(find.byType(TitleWidget), findsOneWidget);
      expect(find.byType(HelpCard), findsOneWidget);
      expect(find.byType(FinancingForms), findsOneWidget);

      // 2. Verifica textos específicos da página para garantir integridade
      expect(find.text('Calculadora de Financiamento'), findsOneWidget);
      expect(find.text('Financiamento'), findsOneWidget);
      expect(find.textContaining('Este cálculo utiliza o sistema Price'), findsOneWidget);
    });

    testWidgets('Deve garantir que a página inteira possui um scroll ativado', (tester) async {
      await tester.pumpWidget(createSut());

      // Garante que o scroll principal da página existe para suportar layouts longos
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
