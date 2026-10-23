import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_calc/core/errors/failures.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/core/seed_works/error.dart';
import 'package:real_calc/core/seed_works/result.dart';
import 'package:real_calc/modules/value_correction/domain/entites/period.dart';
import 'package:real_calc/modules/value_correction/domain/entites/series_point.dart';
import 'package:real_calc/modules/value_correction/domain/entites/value_correction.dart';
import 'package:real_calc/modules/value_correction/domain/enum/correction_index.dart';
import 'package:real_calc/modules/value_correction/domain/enum/series_kind.dart';
import 'package:real_calc/modules/value_correction/domain/repositories/i_correction_series_repository.dart';
import 'package:real_calc/modules/value_correction/domain/validation/value_correction_validation.dart';
import 'package:real_calc/modules/value_correction/presentation/cubit/value_correction/value_correction_cubit.dart';
import 'package:real_calc/modules/value_correction/presentation/cubit/value_correction/value_correction_state.dart';
import 'package:real_calc/modules/value_correction/presentation/cubit/value_correction/request_parsing/value_correction_request_parser.dart';
import 'package:real_calc/modules/value_correction/presentation/cubit/value_correction/request_validation/value_correction_request_validator.dart';
import 'package:real_calc/modules/value_correction/presentation/cubit/forms/date_parsing/correction_form_date_parser.dart';
import 'package:real_calc/modules/value_correction/use_cases/i_calculate_value_correction.dart';

class MockCorrectionSeriesRepository extends Mock
    implements ICorrectionSeriesRepository {}

class MockCalculateValueCorrection extends Mock
    implements ICalculateValueCorrection {}

class ValueCorrectionFake extends Fake implements ValueCorrection {}

void main() {
  setUpAll(() {
    registerFallbackValue(ValueCorrectionFake());
    registerFallbackValue(SeriesKind.monthlyVariation);
    registerFallbackValue(CorrectionIndex.ipca);
  });

  late ICorrectionSeriesRepository repository;
  late ICalculateValueCorrection calculateValueCorrection;
  late ValueCorrectionCubit cubit;

  setUp(() {
    repository = MockCorrectionSeriesRepository();
    calculateValueCorrection = MockCalculateValueCorrection();
    cubit = ValueCorrectionCubit(
      repository,
      calculateValueCorrection,
      ValueCorrectionRequestParser(CorrectionFormDateParser()),
      ValueCorrectionRequestValidator(ValueCorrectionValidation()),
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('ValueCorrectionCubit - Testes Unitários de Cálculo', () {
    final ipcaValueCorrection = ValueCorrection(
      index: CorrectionIndex.ipca.sgsCode,
      period: Period(initial: DateTime(2024, 1, 1), end: DateTime(2024, 1, 1)),
      percentage: 0,
      originalValue: 100,
      factor: 1.015,
      adjustedValue: 101.5,
      variation: 1.5,
    );

    final cdiValueCorrection = ValueCorrection(
      index: CorrectionIndex.cdi.sgsCode,
      period: Period(initial: DateTime(2024, 1, 1), end: DateTime(2024, 1, 1)),
      percentage: 80,
      originalValue: 100,
      factor: 1.0008,
      adjustedValue: 100.08,
      variation: 0.08,
    );

    blocTest<ValueCorrectionCubit, ValueCorrectionState>(
      'Deve emitir [ValueCorrectionLoading, ValueCorrectionCalculated] ignorando o percentual para IPCA',
      setUp: () {
        when(
          () => repository.getSeries(
            index: CorrectionIndex.ipca,
            start: any<DateTime>(named: 'start'),
            end: any<DateTime>(named: 'end'),
          ),
        ).thenAnswer((_) async {
          return SuccessResult<ErrorMessages, List<SeriesPoint>>([
            SeriesPoint(date: DateTime(2024, 1, 1), value: 1.5),
          ]);
        });

        when(
          () => calculateValueCorrection.call(
            params: any<ValueCorrection>(named: 'params'),
            series: any<List<SeriesPoint>>(named: 'series'),
            type: any<SeriesKind>(named: 'type'),
          ),
        ).thenReturn(
          SuccessResult<Failure, ValueCorrection>(ipcaValueCorrection),
        );
      },
      build: () => cubit,
      act: (cubit) => cubit.calculate(
        index: CorrectionIndex.ipca,
        initialDate: '01/2024',
        finalDate: '01/2024',
        percentage: '80',
        value: '100',
      ),
      expect: () => [
        isA<ValueCorrectionLoading>(),
        isA<ValueCorrectionCalculated>().having(
          (s) => s.result.percentage,
          'percentage',
          0,
        ),
      ],
    );

    blocTest<ValueCorrectionCubit, ValueCorrectionState>(
      'Deve emitir [ValueCorrectionLoading, ValueCorrectionCalculated] usando o percentual informado para CDI',
      setUp: () {
        when(
          () => repository.getSeries(
            index: CorrectionIndex.cdi,
            start: any<DateTime>(named: 'start'),
            end: any<DateTime>(named: 'end'),
          ),
        ).thenAnswer((_) async {
          return SuccessResult<ErrorMessages, List<SeriesPoint>>([
            SeriesPoint(date: DateTime(2024, 1, 1), value: 0.1),
          ]);
        });

        when(
          () => calculateValueCorrection.call(
            params: any<ValueCorrection>(named: 'params'),
            series: any<List<SeriesPoint>>(named: 'series'),
            type: any<SeriesKind>(named: 'type'),
          ),
        ).thenReturn(
          SuccessResult<Failure, ValueCorrection>(cdiValueCorrection),
        );
      },
      build: () => cubit,
      act: (cubit) => cubit.calculate(
        index: CorrectionIndex.cdi,
        initialDate: '01/01/2024',
        finalDate: '01/01/2024',
        percentage: '80',
        value: '100',
      ),
      expect: () => [
        isA<ValueCorrectionLoading>(),
        isA<ValueCorrectionCalculated>().having(
          (s) => s.result.percentage,
          'percentage',
          80,
        ),
      ],
    );

    blocTest<ValueCorrectionCubit, ValueCorrectionState>(
      'aplica 100% da taxa diária da Selic',
      setUp: () {
        when(
          () => repository.getSeries(
            index: CorrectionIndex.selic,
            start: DateTime(2024, 1, 2),
            end: DateTime(2024, 1, 3),
          ),
        ).thenAnswer((_) async {
          return SuccessResult<ErrorMessages, List<SeriesPoint>>([
            SeriesPoint(date: DateTime(2024, 1, 2), value: 0.055131),
            SeriesPoint(date: DateTime(2024, 1, 3), value: 0.055131),
          ]);
        });
        when(
          () => calculateValueCorrection.call(
            params: any<ValueCorrection>(named: 'params'),
            series: any<List<SeriesPoint>>(named: 'series'),
            type: any<SeriesKind>(named: 'type'),
          ),
        ).thenReturn(
          SuccessResult<Failure, ValueCorrection>(
            ValueCorrection(
              index: CorrectionIndex.selic.sgsCode,
              period: Period(
                initial: DateTime(2024, 1, 2),
                end: DateTime(2024, 1, 3),
              ),
              percentage: 100,
              originalValue: 100,
              factor: 1.001103,
              adjustedValue: 100.1103,
              variation: 0.1103,
            ),
          ),
        );
      },
      build: () => cubit,
      act: (cubit) => cubit.calculate(
        index: CorrectionIndex.selic,
        initialDate: '02/01/2024',
        finalDate: '03/01/2024',
        percentage: '',
        value: '100',
      ),
      expect: () => [
        isA<ValueCorrectionLoading>(),
        isA<ValueCorrectionCalculated>(),
      ],
      verify: (_) {
        final params =
            verify(
                  () => calculateValueCorrection.call(
                    params: captureAny<ValueCorrection>(named: 'params'),
                    series: any<List<SeriesPoint>>(named: 'series'),
                    type: SeriesKind.dailyRate,
                  ),
                ).captured.single
                as ValueCorrection;
        expect(params.percentage, 100);
      },
    );

    blocTest<ValueCorrectionCubit, ValueCorrectionState>(
      'Deve emitir [Loading, Error] ao validar dados inválidos sem chamar o repositório',
      build: () => cubit,
      act: (cubit) => cubit.calculate(
        index: CorrectionIndex.ipca,
        initialDate: '02/2025',
        finalDate: '01/2025',
        percentage: '10',
        value: '100',
      ),
      expect: () => [
        isA<ValueCorrectionLoading>(),
        isA<ValueCorrectionError>().having(
          (state) => state.message,
          'message',
          contains('A data inicial não pode ser maior do que a data final'),
        ),
      ],
      verify: (_) {
        verifyNever(
          () => repository.getSeries(
            index: any(named: 'index'),
            start: any(named: 'start'),
            end: any(named: 'end'),
          ),
        );
      },
    );

    blocTest<ValueCorrectionCubit, ValueCorrectionState>(
      'rejeita período superior a dez anos sem consultar a série',
      build: () => cubit,
      act: (cubit) => cubit.calculate(
        index: CorrectionIndex.ipca,
        initialDate: '01/2010',
        finalDate: '02/2020',
        percentage: '0',
        value: '100',
      ),
      expect: () => [
        isA<ValueCorrectionLoading>(),
        isA<ValueCorrectionError>().having(
          (state) => state.message,
          'message',
          'O período entre as datas não pode ser superior a 10 anos exatos.',
        ),
      ],
      verify: (_) {
        verifyNever(
          () => repository.getSeries(
            index: any(named: 'index'),
            start: any(named: 'start'),
            end: any(named: 'end'),
          ),
        );
      },
    );

    blocTest<ValueCorrectionCubit, ValueCorrectionState>(
      'rejeita datas anteriores ao início disponível do índice',
      build: () => cubit,
      act: (cubit) => cubit.calculate(
        index: CorrectionIndex.ipcaE,
        initialDate: '12/1991',
        finalDate: '01/1992',
        percentage: '0',
        value: '100',
      ),
      expect: () => [
        isA<ValueCorrectionLoading>(),
        isA<ValueCorrectionError>().having(
          (state) => state.message,
          'message',
          'O índice IPCA-E (IBGE) possui dados a partir de 01/1992.',
        ),
      ],
      verify: (_) {
        verifyNever(
          () => repository.getSeries(
            index: any(named: 'index'),
            start: any(named: 'start'),
            end: any(named: 'end'),
          ),
        );
      },
    );

    blocTest<ValueCorrectionCubit, ValueCorrectionState>(
      'Deve emitir [Loading, Error] quando a busca da série falhar por rede',
      setUp: () {
        when(
          () => repository.getSeries(
            index: CorrectionIndex.ipca,
            start: any<DateTime>(named: 'start'),
            end: any<DateTime>(named: 'end'),
          ),
        ).thenAnswer(
          (_) async => FailureResult<ErrorMessages, List<SeriesPoint>>(
            ServerErrorMessages.connectionError,
          ),
        );
      },
      build: () => cubit,
      act: (cubit) => cubit.calculate(
        index: CorrectionIndex.ipca,
        initialDate: '01/2024',
        finalDate: '12/2024',
        percentage: '0',
        value: '100',
      ),
      expect: () => [
        isA<ValueCorrectionLoading>(),
        isA<ValueCorrectionError>().having(
          (state) => state.message,
          'message',
          'Erro de conexão com o servidor',
        ),
      ],
    );
  });
}
