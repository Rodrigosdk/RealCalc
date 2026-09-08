import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_calc/core/themes/app_theme.dart';
import 'package:real_calc/core/widgets/page_header.dart';
import 'package:real_calc/core/widgets/title_widget.dart';
import 'package:real_calc/modules/financing/presentation/widgets/help_card.dart';
import 'package:real_calc/modules/regular_deposits/presentation/cubit/regular_deposits_cubit.dart';
import 'package:real_calc/modules/regular_deposits/presentation/pages/page.dart';
import 'package:real_calc/modules/regular_deposits/presentation/widgets/regular_deposits_forms.dart';

class MockRegularDepositsCubit extends MockCubit<RegularDepositsState>
    implements RegularDepositsCubit {}

void main() {
  late RegularDepositsCubit mockCubit;

  setUp(() {
    mockCubit = MockRegularDepositsCubit();
    when(() => mockCubit.state).thenReturn(RegularDepositsInitial());
  });

  Widget createSut() {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: BlocProvider<RegularDepositsCubit>.value(
        value: mockCubit,
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
      expect(find.byType(RegularDepositsForms), findsOneWidget);

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
