import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/themes/app_theme.dart';
import 'package:real_calc/core/widgets/page_header.dart';
import 'package:real_calc/core/widgets/title_widget.dart';
import 'package:real_calc/modules/financial_calculators/domain/enum/financial_calculation_target.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/forms/financing_form_cubit.dart';
import 'package:real_calc/modules/financial_calculators/presentation/widgets/forms_view.dart';
import 'package:real_calc/core/widgets/help_card.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/regular_deposits/regular_deposits_cubit.dart';
import 'package:real_calc/modules/financial_calculators/presentation/pages/regular_deposits_page.dart';

import '../../../../test_harness.dart';

void main() {
  late TestHarness harness;
 
  setUp(() {
    harness = TestHarness()..setUpDefaults();
  });
 
  tearDown(() => harness.dispose());
 
  Widget createSut() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<RegularDepositsCubit>.value(
            value: harness.regularDepositsCubit,
          ),
          BlocProvider<FinancingFormCubit>.value(
            value: harness.financingFormCubit,
          ),
        ],
        child: const RegularDepositsPage(),
      ),
    );
  }

  group('RegularDepositsPage - Testes de Integração da Tela', () {
    testWidgets('Deve renderizar a árvore de componentes completa com sucesso', (tester) async {
      await tester.pumpWidget(createSut());

      expect(find.byType(PageHeader), findsOneWidget);
      expect(find.byType(TitleWidget), findsOneWidget);
      expect(find.byType(HelpCard), findsOneWidget);
      expect(find.byType(FormsView<FinancialCalculationTarget>), findsOneWidget);

      expect(find.text('Depósitos Regulares'), findsNWidgets(2));
      expect(
        find.text('Calcule o valor futuro, a taxa, o prazo ou o depósito mensal.'),
        findsOneWidget,
      );
    });

    testWidgets('Deve garantir que a página inteira possui um scroll ativado', (tester) async {
      await tester.pumpWidget(createSut());

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
