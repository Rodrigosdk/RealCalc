import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_calc/core/themes/app_theme.dart';
import 'package:real_calc/modules/value_correction/domain/enum/correction_index.dart';
import 'package:real_calc/modules/value_correction/domain/repositories/i_correction_series_repository.dart';
import 'package:real_calc/modules/value_correction/presentation/cubit/value_correction/value_correction_cubit.dart';
import 'package:real_calc/modules/value_correction/presentation/cubit/forms/value_correction_form_cubit.dart';
import 'package:real_calc/modules/value_correction/presentation/pages/value_correction_page.dart';
import 'package:real_calc/modules/value_correction/use_cases/i_calculate_value_correction.dart';

class MockCorrectionSeriesRepository extends Mock
    implements ICorrectionSeriesRepository {}

class MockCalculateValueCorrection extends Mock
    implements ICalculateValueCorrection {}

void main() {
  group('ValueCorrectionPage', () {
    late MockCorrectionSeriesRepository seriesRepository;
    late MockCalculateValueCorrection calculateValueCorrection;

    Widget buildSut() {
      return BlocProvider(
        create: (_) => ValueCorrectionFormCubit()..setIndex(CorrectionIndex.ipca),
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: BlocProvider(
            create: (_) => ValueCorrectionCubit(
              seriesRepository,
              calculateValueCorrection,
            ),
            child: const ValueCorrectionPage(),
          ),
        ),
      );
    }

    setUp(() {
      seriesRepository = MockCorrectionSeriesRepository();
      calculateValueCorrection = MockCalculateValueCorrection();
    });

    testWidgets('renderiza a árvore do formulário e os botões da correção', (
      tester,
    ) async {
      await tester.pumpWidget(buildSut());

      expect(find.text('Correção de Valores'), findsNWidgets(2));
      expect(find.textContaining('Escolha o índice'), findsOneWidget);
      expect(find.text('Índice de correção'), findsOneWidget);
      expect(find.text('Data inicial'), findsOneWidget);
      expect(find.text('Data final'), findsOneWidget);
      expect(find.text('Valor a ser corrigido (R\$)'), findsOneWidget);
      expect(find.text('Corrigir valor'), findsOneWidget);
      expect(find.text('Limpar'), findsOneWidget);
    });

    testWidgets('permite scroll na página com o teclado aberto', (
      tester,
    ) async {
      await tester.pumpWidget(buildSut());

      expect(find.byType(Scrollable), findsWidgets);
      await tester.pump();
      expect(find.byType(Scrollable), findsWidgets);
    });
  });
}
