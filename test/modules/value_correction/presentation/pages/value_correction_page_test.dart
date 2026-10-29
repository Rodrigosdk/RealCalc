import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_calc/core/errors/failures.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/core/seed_works/error.dart';
import 'package:real_calc/core/seed_works/result.dart';
import 'package:real_calc/core/services/result_sharer.dart';
import 'package:real_calc/core/themes/app_theme.dart';
import 'package:real_calc/core/widgets/bottom_action_bar.dart';
import 'package:real_calc/core/widgets/calculator_band/calculator_band.dart';
import 'package:real_calc/core/widgets/result_details/result_details.dart';
import 'package:real_calc/modules/value_correction/domain/entites/period.dart';
import 'package:real_calc/modules/value_correction/domain/entites/series_point.dart';
import 'package:real_calc/modules/value_correction/domain/entites/value_correction.dart';
import 'package:real_calc/modules/value_correction/domain/enum/correction_index.dart';
import 'package:real_calc/modules/value_correction/domain/enum/series_kind.dart';
import 'package:real_calc/modules/value_correction/domain/repositories/i_correction_series_repository.dart';
import 'package:real_calc/modules/value_correction/domain/validation/value_correction_validation.dart';
import 'package:real_calc/modules/value_correction/presentation/cubit/forms/date_formatting/correction_form_input_formatter.dart';
import 'package:real_calc/modules/value_correction/presentation/cubit/forms/date_parsing/correction_form_date_parser.dart';
import 'package:real_calc/modules/value_correction/presentation/cubit/forms/validation/correction_form_validator.dart';
import 'package:real_calc/modules/value_correction/presentation/cubit/forms/value_correction_form_cubit.dart';
import 'package:real_calc/modules/value_correction/presentation/cubit/forms/value_correction_form_state.dart';
import 'package:real_calc/modules/value_correction/presentation/cubit/value_correction/request_parsing/value_correction_request_parser.dart';
import 'package:real_calc/modules/value_correction/presentation/cubit/value_correction/request_validation/value_correction_request_validator.dart';
import 'package:real_calc/modules/value_correction/presentation/cubit/value_correction/value_correction_cubit.dart';
import 'package:real_calc/modules/value_correction/presentation/pages/value_correction_page.dart';
import 'package:real_calc/modules/value_correction/use_cases/i_calculate_value_correction.dart';

class MockCorrectionSeriesRepository extends Mock
    implements ICorrectionSeriesRepository {}

class MockCalculateValueCorrection extends Mock
    implements ICalculateValueCorrection {}

class ValueCorrectionFake extends Fake implements ValueCorrection {}

class FakeSharer implements ResultSharer {
  final shared = <String>[];

  @override
  Future<void> share(String text, {Rect? origin}) async => shared.add(text);
}

ValueCorrection ipcaResult({bool withValue = true}) => ValueCorrection(
  index: CorrectionIndex.ipca.sgsCode,
  period: Period(initial: DateTime(2001, 12), end: DateTime(2003, 12)),
  percentage: 100,
  originalValue: withValue ? 5555.55 : null,
  factor: 1.2379507,
  adjustedValue: withValue ? 6877.498 : null,
  variation: 23.79507,
);

void main() {
  late MockCorrectionSeriesRepository repository;
  late MockCalculateValueCorrection calculate;
  late ValueCorrectionFormCubit formCubit;
  late ValueCorrectionCubit correctionCubit;
  late FakeSharer sharer;

  setUpAll(() async {
    await initializeDateFormatting('pt_BR', null);
    registerFallbackValue(CorrectionIndex.ipca);
    registerFallbackValue(SeriesKind.monthlyVariation);
    registerFallbackValue(ValueCorrectionFake());
  });

  void seriesAnswers(
    Future<Result<ErrorMessages, List<SeriesPoint>>> Function() answer,
  ) {
    when(
      () => repository.getSeries(
        index: any(named: 'index'),
        start: any(named: 'start'),
        end: any(named: 'end'),
      ),
    ).thenAnswer((_) => answer());
  }

  void calculationReturns(ValueCorrection result) {
    when(
      () => calculate.call(
        params: any(named: 'params'),
        series: any(named: 'series'),
        type: any(named: 'type'),
      ),
    ).thenReturn(SuccessResult<Failure, ValueCorrection>(result));
  }

  setUp(() {
    repository = MockCorrectionSeriesRepository();
    calculate = MockCalculateValueCorrection();
    sharer = FakeSharer();
    formCubit = ValueCorrectionFormCubit(
      CorrectionFormInputFormatter(),
      CorrectionFormValidator(CorrectionFormDateParser()),
    )..setIndex(CorrectionIndex.ipca);
    correctionCubit = ValueCorrectionCubit(
      repository,
      calculate,
      ValueCorrectionRequestParser(CorrectionFormDateParser()),
      ValueCorrectionRequestValidator(ValueCorrectionValidation()),
    );
    seriesAnswers(
      () async => SuccessResult<ErrorMessages, List<SeriesPoint>>([
        SeriesPoint(date: DateTime(2002, 1, 1), value: 0.5),
      ]),
    );
    calculationReturns(ipcaResult());
  });

  tearDown(() async {
    await formCubit.close();
    await correctionCubit.close();
  });

  Future<void> pump(
    WidgetTester tester, {
    ThemeMode themeMode = ThemeMode.light,
    Size size = const Size(400, 900),
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: formCubit),
            BlocProvider.value(value: correctionCubit),
          ],
          child: ValueCorrectionPage(sharer: sharer),
        ),
      ),
    );
  }

  Finder inBand(String text) => find.descendant(
    of: find.byType(CalculatorBand),
    matching: find.text(text),
  );

  Finder row(ValueCorrectionField field) => find.byKey(ValueKey(field));

  Future<void> fillExample(WidgetTester tester, {bool withValue = true}) async {
    formCubit.initialDate.text = '12/2001';
    formCubit.finalDate.text = '12/2003';
    if (withValue) formCubit.value.text = '5.555,55';
    await tester.pump();
  }

  Future<void> correct(WidgetTester tester) async {
    await tester.tap(find.text('Corrigir valor'));
    await tester.pumpAndSettle();
  }

  group('ValueCorrectionPage', () {
    testWidgets('monta faixa, campos e barra de ações', (tester) async {
      await pump(tester);

      expect(find.text('Correção de Valores'), findsOneWidget);
      expect(inBand('o seu dinheiro?'), findsOneWidget);
      for (final label in ['Índice', 'De', 'Até', 'Valor']) {
        expect(find.text(label), findsOneWidget);
      }
      expect(find.text('IPCA'), findsOneWidget);
      expect(find.text('opcional'), findsOneWidget);
      expect(find.text('Percentual'), findsNothing);
      expect(find.text('O IPCA tem dados desde 01/1980.'), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
    });

    testWidgets('o texto de apoio mostra a duração', (tester) async {
      await pump(tester);
      await fillExample(tester);

      expect(
        find.text('25 meses. O IPCA tem dados desde 01/1980.'),
        findsOneWidget,
      );
    });

    testWidgets('IPCA, 12/2001 a 12/2003, R\$ 5.555,55: valor corrigido, '
        'correção, fator e barra 81/19', (tester) async {
      await pump(tester);
      await fillExample(tester);
      await correct(tester);

      expect(inBand('Hoje, seus R\$\u00A05.555,55 valem'), findsOneWidget);
      expect(inBand('6.877,50'), findsOneWidget);
      expect(inBand('+23,80% pelo IPCA, de 12/2001 a 12/2003'), findsOneWidget);
      expect(find.text('Do valor corrigido'), findsOneWidget);
      expect(find.textContaining('1.321,95'), findsOneWidget);
      expect(find.text('1,2379507'), findsOneWidget);
      expect(find.text('Valor original 81%'), findsOneWidget);
      expect(find.text('Correção 19%'), findsOneWidget);
    });

    testWidgets('sem valor, mostra só a variação e o fator', (tester) async {
      calculationReturns(ipcaResult(withValue: false));
      await pump(tester);
      await fillExample(tester, withValue: false);
      await correct(tester);

      expect(inBand('+23,80%'), findsOneWidget);
      expect(inBand('Fator de correção 1,2379507'), findsOneWidget);
      expect(find.text('Variação'), findsOneWidget);
      expect(find.text('Valor original 81%'), findsNothing);
    });

    testWidgets('mudar um campo depois do cálculo volta ao estado inicial', (
      tester,
    ) async {
      await pump(tester);
      await fillExample(tester);
      await correct(tester);
      expect(find.byType(ResultDetails), findsOneWidget);

      formCubit.finalDate.text = '11/2003';
      await tester.pump();

      expect(inBand('o seu dinheiro?'), findsOneWidget);
      expect(find.byType(ResultDetails), findsNothing);
    });

    testWidgets('carregando: indicador no botão e campos bloqueados', (
      tester,
    ) async {
      final pending = Completer<Result<ErrorMessages, List<SeriesPoint>>>();
      seriesAnswers(() => pending.future);
      await pump(tester);
      await fillExample(tester);

      await tester.tap(find.text('Corrigir valor'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final absorb = tester.widget<AbsorbPointer>(
        find
            .ancestor(
              of: row(ValueCorrectionField.initialDate),
              matching: find.byType(AbsorbPointer),
            )
            .first,
      );
      expect(absorb.absorbing, isTrue);

      pending.complete(
        SuccessResult<ErrorMessages, List<SeriesPoint>>(const []),
      );
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('data fora da série: linha em erro, aviso e atalho', (
      tester,
    ) async {
      await pump(tester);
      formCubit.initialDate.text = '12/1979';
      formCubit.finalDate.text = '12/1981';
      await tester.pump();

      expect(
        find.descendant(
          of: row(ValueCorrectionField.initialDate),
          matching: find.text(ValueCorrectionPage.outOfRangeText),
        ),
        findsOneWidget,
      );
      expect(find.text('Data fora do período'), findsOneWidget);
      expect(inBand('ajuste a data'), findsOneWidget);
      expect(find.text('O IPCA tem dados desde 01/1980.'), findsOneWidget);
      expect(
        find.text('O IPCA tem dados a partir de 01/1980.'),
        findsNWidgets(2),
      );

      await tester.tap(find.text('Usar 01/1980'));
      await tester.pump();

      expect(formCubit.initialDate.text, '01/1980');
      expect(find.text('Data fora do período'), findsNothing);
    });

    testWidgets('erro de rede: faixa "Sem conexão" e "Tentar de novo"', (
      tester,
    ) async {
      seriesAnswers(
        () async => FailureResult<ErrorMessages, List<SeriesPoint>>(
          ServerErrorMessages.connectionError,
        ),
      );
      await pump(tester);
      await fillExample(tester);
      await correct(tester);

      expect(inBand('Banco Central'), findsOneWidget);
      expect(find.text('Sem conexão'), findsOneWidget);

      await tester.tap(find.text('Tentar de novo'));
      await tester.pumpAndSettle();

      verify(
        () => repository.getSeries(
          index: any(named: 'index'),
          start: any(named: 'start'),
          end: any(named: 'end'),
        ),
      ).called(2);
    });

    testWidgets('compartilhar usa o texto da Correção', (tester) async {
      await pump(tester);
      await fillExample(tester);

      final share = find.byType(OutlinedButton);
      expect(tester.widget<OutlinedButton>(share).onPressed, isNull);

      await correct(tester);
      await tester.tap(share);

      expect(
        sharer.shared.single,
        startsWith('RealCalc · Correção de Valores'),
      );
    });

    testWidgets('no CDI mostra o percentual e datas com dia', (tester) async {
      await pump(tester);
      formCubit.setIndex(CorrectionIndex.cdi);
      await tester.pump();

      expect(find.text('Percentual'), findsOneWidget);
      expect(find.text('% do CDI'), findsOneWidget);
      expect(find.text('CDI'), findsOneWidget);
      expect(
        find.descendant(
          of: row(ValueCorrectionField.initialDate),
          matching: find.text('01/01/2023'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('limpar e desfazer', (tester) async {
      await pump(tester);
      await fillExample(tester);
      await correct(tester);

      await tester.tap(find.bySemanticsLabel(CalculatorBand.clearLabel));
      await tester.pumpAndSettle();
      expect(formCubit.value.text, isEmpty);
      expect(find.byType(ResultDetails), findsNothing);

      await tester.tap(find.text('Desfazer'));
      await tester.pumpAndSettle();
      expect(formCubit.value.text, '5.555,55');
      expect(inBand('6.877,50'), findsOneWidget);
    });

    for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('em 360dp e fonte em 130% no tema ${themeMode.name}, a '
          'barra não cobre o último item', (tester) async {
        await pump(
          tester,
          themeMode: themeMode,
          size: const Size(360, 700),
          textScale: 1.3,
        );
        await fillExample(tester);
        await correct(tester);

        expect(tester.takeException(), isNull);

        final last = find.text('1,2379507');
        await tester.scrollUntilVisible(
          last,
          100,
          scrollable: find.byType(Scrollable).first,
        );
        final bar = tester.getRect(find.byType(BottomActionBar));
        expect(tester.getRect(last).bottom, lessThanOrEqualTo(bar.top));
      });
    }

    testWidgets('o teclado não cobre o campo de valor', (tester) async {
      await pump(tester, size: const Size(360, 700));

      await tester.showKeyboard(
        find.descendant(
          of: row(ValueCorrectionField.value),
          matching: find.byType(TextField),
        ),
      );
      tester.view.viewInsets = const FakeViewPadding(bottom: 320);
      await tester.pumpAndSettle();

      final field = tester.getRect(row(ValueCorrectionField.value));
      final bar = tester.getRect(find.byType(BottomActionBar));
      expect(field.bottom, lessThanOrEqualTo(bar.top));
    });

    testWidgets('a linha Índice abre o seletor', (tester) async {
      await pump(tester);

      await tester.tap(find.text('Índice'));
      await tester.pumpAndSettle();

      expect(find.text('INFLAÇÃO'), findsOneWidget);

      await tester.tap(find.text('IGP-M (FGV)'));
      await tester.pumpAndSettle();
      expect(formCubit.state.index, CorrectionIndex.igpM);
    });
  });
}
