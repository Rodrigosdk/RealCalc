import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/core/seed_works/result.dart';
import 'package:real_calc/modules/home/presentation/cubit/selic_cubit.dart';
import 'package:real_calc/modules/metrics/domain/entites/metric.dart';
import 'package:real_calc/modules/metrics/use_cases/selic/i_selic_use_case.dart';

class MockSelicUseCase extends Mock implements ISelicUseCase {}

void main() {
  late MockSelicUseCase useCase;
  late SelicCubit cubit;
  late Metric metric;

  setUp(() {
    useCase = MockSelicUseCase();
    cubit = SelicCubit(useCase);
    metric = Metric(
      anualRate: 10.75,
      variationPercent: 0.25,
      sparklineData: const [10.5, 10.6, 10.75],
    );
  });

  tearDown(() => cubit.close());

  group('SelicCubit', () {
    blocTest<SelicCubit, SelicState>(
      'emite loading e loaded quando a consulta tem sucesso',
      setUp: () {
        when(
          () => useCase.getSelicRate(),
        ).thenAnswer((_) async => SuccessResult(metric));
      },
      build: () => cubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<SelicLoading>(),
        isA<SelicLoaded>().having((state) => state.metric, 'metric', metric),
      ],
      verify: (_) {
        verify(() => useCase.getSelicRate()).called(1);
      },
    );

    blocTest<SelicCubit, SelicState>(
      'emite loading e error quando a consulta falha',
      setUp: () {
        when(() => useCase.getSelicRate()).thenAnswer(
          (_) async => FailureResult(ServerErrorMessages.connectionError),
        );
      },
      build: () => cubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<SelicLoading>(),
        isA<SelicError>().having(
          (state) => state.error,
          'error',
          ServerErrorMessages.connectionError,
        ),
      ],
    );

    blocTest<SelicCubit, SelicState>(
      'retry consulta novamente a taxa Selic',
      setUp: () {
        when(
          () => useCase.getSelicRate(),
        ).thenAnswer((_) async => SuccessResult(metric));
      },
      build: () => cubit,
      act: (cubit) => cubit.retry(),
      expect: () => [isA<SelicLoading>(), isA<SelicLoaded>()],
      verify: (_) {
        verify(() => useCase.getSelicRate()).called(1);
      },
    );
  });
}
