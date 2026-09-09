import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_calc/core/themes/app_theme.dart';
import 'package:real_calc/core/widgets/page_header.dart';
import 'package:real_calc/core/widgets/title_widget.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/financing/financing_cubit.dart';
import 'package:real_calc/modules/financial_calculators/presentation/pages/financing_page.dart';
import 'package:real_calc/modules/financial_calculators/presentation/widgets/financing_forms.dart';
import 'package:real_calc/modules/financial_calculators/presentation/widgets/help_card.dart';

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
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.lightTheme,
      themeMode: ThemeMode.dark,
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
      expect(find.byType(PageHeader), findsOneWidget);
      expect(find.byType(TitleWidget), findsOneWidget);
      expect(find.byType(HelpCard), findsOneWidget);
      expect(find.byType(FinancingForms), findsOneWidget);

    });

    testWidgets('Deve garantir que a página inteira possui um scroll ativado', (tester) async {
      await tester.pumpWidget(createSut());

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
  group("FinancingPage - Testes da PageHeader", () {
    testWidgets('Deve conseguir criar uma PageHeader', (tester) async {
      await tester.pumpWidget(createSut());
      expect(find.byType(PageHeader), findsOneWidget);
    });


    testWidgets("Deve conter uma fontSize de 18 e fontWeight bold", (tester) async {
      await tester.pumpWidget(createSut());

      final textFinder = find.text('Financiamento');
      final RenderParagraph renderObject = tester.renderObject<RenderParagraph>(textFinder.first);

      final TextStyle? resolvedStyle = renderObject.text.style;

      expect(resolvedStyle?.fontSize, 18);
      expect(resolvedStyle?.fontWeight, FontWeight.w700);
    });
  });
}
