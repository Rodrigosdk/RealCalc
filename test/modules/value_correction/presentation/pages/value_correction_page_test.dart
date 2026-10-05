import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_calc/core/errors/failures.dart';
import 'package:real_calc/core/seed_works/error.dart';
import 'package:real_calc/core/seed_works/result.dart';
import 'package:real_calc/core/themes/app_theme.dart';
import 'package:real_calc/modules/value_correction/domain/entites/period.dart';
import 'package:real_calc/modules/value_correction/domain/entites/series_point.dart';
import 'package:real_calc/modules/value_correction/domain/entites/value_correction.dart';
import 'package:real_calc/modules/value_correction/domain/enum/correction_index.dart';
import 'package:real_calc/modules/value_correction/domain/enum/series_kind.dart';
import 'package:real_calc/modules/value_correction/domain/repositories/i_correction_series_repository.dart';
import 'package:real_calc/modules/value_correction/presentation/cubit/value_correction/value_correction_cubit.dart';
import 'package:real_calc/modules/value_correction/presentation/cubit/value_correction/value_correction_state.dart';
import 'package:real_calc/modules/value_correction/presentation/cubit/forms/value_correction_form_cubit.dart';
import 'package:real_calc/modules/value_correction/presentation/pages/value_correction_page.dart';
import 'package:real_calc/modules/value_correction/use_cases/i_calculate_value_correction.dart';

class MockCorrectionSeriesRepository extends Mock
    implements ICorrectionSeriesRepository {}

class MockCalculateValueCorrection extends Mock
    implements ICalculateValueCorrection {}

class ValueCorrectionFake extends Fake implements ValueCorrection {}

void main() {
  setUpAll(() {
    registerFallbackValue(CorrectionIndex.ipca);
    registerFallbackValue(SeriesKind.monthlyVariation);
    registerFallbackValue(ValueCorrectionFake());
  });

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

    testWidgets(
      'o botão Corrigir valor só chama o cubit quando o formulário é válido',
      (tester) async {
        final formCubit = ValueCorrectionFormCubit()..setIndex(CorrectionIndex.ipca);
        final cubit = ValueCorrectionCubit(seriesRepository, calculateValueCorrection);

        when(
          () => seriesRepository.getSeries(
            index: any(named: 'index'),
            start: any(named: 'start'),
            end: any(named: 'end'),
          ),
        ).thenAnswer((_) async {
          return SuccessResult<ErrorMessages, List<SeriesPoint>>([
            SeriesPoint(date: DateTime(2024, 1, 1), value: 1.5),
          ]);
        });

        when(
          () => calculateValueCorrection.call(
            params: any(named: 'params'),
            series: any(named: 'series'),
            type: any(named: 'type'),
          ),
        ).thenReturn(
          SuccessResult<Failure, ValueCorrection>(
            ValueCorrection(
              index: CorrectionIndex.ipca.sgsCode,
              period: Period(
                initial: DateTime(2024, 1, 1),
                end: DateTime(2024, 12, 1),
              ),
              percentage: 0,
              originalValue: 100,
              factor: 1.015,
              adjustedValue: 101.5,
              variation: 1.5,
            ),
          ),
        );

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider.value(value: formCubit),
              BlocProvider.value(value: cubit),
            ],
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const ValueCorrectionPage(),
            ),
          ),
        );

        final calculateButton = find.widgetWithText(
          ElevatedButton,
          'Corrigir valor',
        );
        expect(tester.widget<ElevatedButton>(calculateButton).onPressed, isNull);

        formCubit.initialDate.text = '01/2024';
        formCubit.finalDate.text = '12/2024';
        formCubit.value.text = '100';
        await tester.pump();

        expect(tester.widget<ElevatedButton>(calculateButton).onPressed, isNotNull);

        await tester.tap(calculateButton);
        await tester.pump();

        verify(
          () => seriesRepository.getSeries(
            index: CorrectionIndex.ipca,
            start: DateTime(2024, 1, 1),
            end: DateTime(2024, 12, 1),
          ),
        ).called(1);
      },
    );
  });
}
