import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_calc/core/errors/failures.dart';
import 'package:real_calc/core/seed_works/error.dart';
import 'package:real_calc/core/seed_works/result.dart';
import 'package:real_calc/modules/value_correction/domain/entites/period.dart';
import 'package:real_calc/modules/value_correction/domain/entites/series_point.dart';
import 'package:real_calc/modules/value_correction/domain/entites/value_correction.dart';
import 'package:real_calc/modules/value_correction/domain/enum/correction_index.dart';
import 'package:real_calc/modules/value_correction/domain/enum/series_kind.dart';
import 'package:real_calc/modules/value_correction/domain/repositories/i_correction_series_repository.dart';
import 'package:real_calc/modules/value_correction/presentation/cubit/value_correction/value_correction_cubit.dart';
import 'package:real_calc/modules/value_correction/presentation/cubit/value_correction/value_correction_state.dart';
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
  });

  late ICorrectionSeriesRepository repository;
  late ICalculateValueCorrection calculateValueCorrection;
  late ValueCorrectionCubit cubit;

  setUp(() {
    repository = MockCorrectionSeriesRepository();
    calculateValueCorrection = MockCalculateValueCorrection();
    cubit = ValueCorrectionCubit(repository, calculateValueCorrection);
  });

  tearDown(() {
    cubit.close();
  });

  group('ValueCorrectionCubit - Testes Unitários de Cálculo', () {
    final ipcaValueCorrection = ValueCorrection(
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
    );

    final cdiValueCorrection = ValueCorrection(
      index: CorrectionIndex.cdi.sgsCode,
      period: Period(
        initial: DateTime(2024, 1, 1),
        end: DateTime(2024, 1, 1),
      ),
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
        ).thenReturn(SuccessResult<Failure, ValueCorrection>(ipcaValueCorrection));
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
        ).thenReturn(SuccessResult<Failure, ValueCorrection>(cdiValueCorrection));
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
  });
}
