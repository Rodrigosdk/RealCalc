import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_calc/core/errors/failures.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/core/routes/app_routes.dart';
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
import 'package:real_calc/modules/value_correction/presentation/cubit/forms/value_correction_form_cubit.dart';
import 'package:real_calc/modules/value_correction/presentation/pages/value_correction_page.dart';
import 'package:real_calc/modules/value_correction/presentation/pages/value_correction_result_page.dart';
import 'package:real_calc/modules/value_correction/use_cases/i_calculate_value_correction.dart';

class MockCorrectionSeriesRepository extends Mock
    implements ICorrectionSeriesRepository {}

class MockCalculateValueCorrection extends Mock
    implements ICalculateValueCorrection {}

class MockNavigator extends Mock implements IModularNavigator {}

class ValueCorrectionFake extends Fake implements ValueCorrection {}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR', null);
    registerFallbackValue(CorrectionIndex.ipca);
    registerFallbackValue(SeriesKind.monthlyVariation);
    registerFallbackValue(ValueCorrectionFake());
  });

  group('ValueCorrectionPage', () {
    late MockCorrectionSeriesRepository seriesRepository;
    late MockCalculateValueCorrection calculateValueCorrection;
    late MockNavigator navigator;

    Widget buildSut() {
      return BlocProvider(
        create: (_) =>
            ValueCorrectionFormCubit()..setIndex(CorrectionIndex.ipca),
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
      navigator = MockNavigator();
      Modular.navigatorDelegate = navigator;
      when(
        () => navigator.pushNamed(any(), arguments: any(named: 'arguments')),
      ).thenAnswer((_) async => null);
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
      'o aviso de moeda informa a disponibilidade do índice selecionado',
      (tester) async {
        await tester.pumpWidget(buildSut());
        final formCubit = BlocProvider.of<ValueCorrectionFormCubit>(
          tester.element(find.byType(ValueCorrectionPage)),
        );

        formCubit.setIndex(CorrectionIndex.ipcaE);
        formCubit.initialDate.text = '12/1991';
        formCubit.finalDate.text = '01/1992';
        await tester.pump();

        expect(
          find.text('O índice IPCA-E (IBGE) possui dados a partir de 01/1992.'),
          findsOneWidget,
        );

        formCubit.setIndex(CorrectionIndex.selic);
        formCubit.initialDate.text = '03/06/1986';
        formCubit.finalDate.text = '04/06/1986';
        await tester.pump();

        expect(
          find.text('O índice Selic possui dados a partir de 04/06/1986.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'o botão Corrigir valor só chama o cubit quando o formulário é válido',
      (tester) async {
        final formCubit = ValueCorrectionFormCubit()
          ..setIndex(CorrectionIndex.ipca);
        final cubit = ValueCorrectionCubit(
          seriesRepository,
          calculateValueCorrection,
        );

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
        expect(
          tester.widget<ElevatedButton>(calculateButton).onPressed,
          isNull,
        );

        formCubit.initialDate.text = '01/2024';
        formCubit.finalDate.text = '12/2024';
        formCubit.value.text = '100';
        await tester.pump();

        expect(
          tester.widget<ElevatedButton>(calculateButton).onPressed,
          isNotNull,
        );

        await tester.tap(calculateButton);
        await tester.pumpAndSettle();

        verify(
          () => seriesRepository.getSeries(
            index: CorrectionIndex.ipca,
            start: DateTime(2024, 1, 1),
            end: DateTime(2024, 12, 1),
          ),
        ).called(1);

        final result =
            verify(
                  () => navigator.pushNamed(
                    AppRoutes.correctionResult,
                    arguments: captureAny(named: 'arguments'),
                  ),
                ).captured.single
                as ValueCorrection;
        expect(result.index, CorrectionIndex.ipca.sgsCode);
        expect(result.adjustedValue, 101.5);
      },
    );

    testWidgets('tenta novamente após falha de rede com texto branco', (
      tester,
    ) async {
      final formCubit = ValueCorrectionFormCubit()
        ..setIndex(CorrectionIndex.ipca);
      final cubit = ValueCorrectionCubit(
        seriesRepository,
        calculateValueCorrection,
      );
      var requestCount = 0;

      when(
        () => seriesRepository.getSeries(
          index: any(named: 'index'),
          start: any(named: 'start'),
          end: any(named: 'end'),
        ),
      ).thenAnswer((_) async {
        requestCount++;
        if (requestCount == 1) {
          return FailureResult<ErrorMessages, List<SeriesPoint>>(
            ServerErrorMessages.connectionError,
          );
        }
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
              end: DateTime(2024, 1, 1),
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

      formCubit.initialDate.text = '01/2024';
      formCubit.finalDate.text = '01/2024';
      await tester.pump();
      await tester.tap(find.text('Corrigir valor'));
      await tester.pumpAndSettle();

      final retryButton = find.widgetWithText(TextButton, 'Tentar novamente');
      expect(retryButton, findsOneWidget);
      final button = tester.widget<TextButton>(retryButton);
      expect(button.onPressed, isNotNull);
      expect(button.style?.foregroundColor?.resolve({}), Colors.white);

      await tester.tap(retryButton);
      await tester.pumpAndSettle();

      expect(requestCount, 2);
      verify(
        () => navigator.pushNamed(
          AppRoutes.correctionResult,
          arguments: any(named: 'arguments'),
        ),
      ).called(1);
    });

    ValueCorrection buildResult({
      bool withAdjustedValue = true,
      int index = 433,
      double factor = 1.1434,
      double? originalValue = 5000,
      double? adjustedValue = 5717,
      double variation = 14.34,
    }) {
      return ValueCorrection(
        index: index,
        period: Period(
          initial: DateTime(2023, 1, 1),
          end: DateTime(2024, 12, 1),
        ),
        percentage: 0,
        originalValue: withAdjustedValue ? originalValue : null,
        factor: factor,
        adjustedValue: withAdjustedValue ? adjustedValue : null,
        variation: variation,
      );
    }

    testWidgets('exibe o resultado com valor corrigido e fator em pt-BR', (
      tester,
    ) async {
      final result = buildResult();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: ValueCorrectionResultPage(result: result),
        ),
      );

      expect(find.textContaining('5.717,00'), findsOneWidget);
      expect(find.textContaining('+14,34%'), findsOneWidget);
      expect(find.textContaining('1,1434000'), findsOneWidget);
    });

    testWidgets('mostra só o fator e o índice quando não há valor', (
      tester,
    ) async {
      final result = buildResult(
        withAdjustedValue: false,
        originalValue: null,
        adjustedValue: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: ValueCorrectionResultPage(result: result),
        ),
      );

      expect(find.text('Valor corrigido'), findsNothing);
      expect(find.text('Valor original'), findsNothing);
      expect(find.textContaining('1,1434000'), findsNWidgets(2));
      expect(find.textContaining('IPCA'), findsNWidgets(2));
    });

    testWidgets('exibe ação para editar os dados do cálculo', (tester) async {
      final result = buildResult();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: ValueCorrectionResultPage(result: result),
        ),
      );

      expect(find.text('Editar Dados'), findsOneWidget);
    });

    testWidgets('não extrapola o layout em largura de 360px', (tester) async {
      final result = ValueCorrection(
        index: 433,
        period: Period(
          initial: DateTime(2023, 1, 1),
          end: DateTime(2024, 12, 1),
        ),
        percentage: 0,
        originalValue: 5000,
        factor: 1.1434,
        adjustedValue: 5717,
        variation: 14.34,
      );

      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: ValueCorrectionResultPage(result: result),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
