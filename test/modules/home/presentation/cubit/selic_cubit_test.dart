import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/core/seed_works/error.dart';
import 'package:real_calc/core/seed_works/result.dart';
import 'package:real_calc/modules/home/presentation/cubit/selic_cubit.dart';
import 'package:real_calc/modules/metrics/domain/entites/metric.dart';
import 'package:real_calc/modules/metrics/domain/enum/selic_period.dart';
import 'package:real_calc/modules/metrics/use_cases/selic/i_selic_use_case.dart';

class MockSelicUseCase extends Mock implements ISelicUseCase {}

void main() {
  late MockSelicUseCase useCase;
  late Metric metric;
  late Metric fiveYears;

  setUpAll(() => registerFallbackValue(SelicPeriod.months12));

  setUp(() {
    useCase = MockSelicUseCase();
    metric = Metric(
      anualRate: 10.75,
      variationPercent: 0.25,
      sparklineData: const [10.5, 10.6, 10.75],
    );
    fiveYears = Metric(
      anualRate: 10.75,
      variationPercent: 0.25,
      sparklineData: const [6, 8, 10.75],
    );
  });

  void answer(SelicPeriod period, Result<ErrorMessages, Metric> result) {
    when(() => useCase.getSelic(period)).thenAnswer((_) async => result);
  }

  final offlineError = FailureResult<ErrorMessages, Metric>(
    ServerErrorMessages.connectionError,
  );

  group('SelicCubit', () {
    blocTest<SelicCubit, SelicState>(
      'emite loading e loaded de 12 meses ao carregar',
      setUp: () => answer(SelicPeriod.months12, SuccessResult(metric)),
      build: () => SelicCubit(useCase),
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<SelicLoading>(),
        isA<SelicLoaded>()
            .having((s) => s.metric, 'metric', metric)
            .having((s) => s.period, 'period', SelicPeriod.months12),
      ],
      verify: (_) =>
          verify(() => useCase.getSelic(SelicPeriod.months12)).called(1),
    );

    blocTest<SelicCubit, SelicState>(
      'emite loading e error quando não há rede nem cache',
      setUp: () => answer(SelicPeriod.months12, offlineError),
      build: () => SelicCubit(useCase),
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<SelicLoading>(),
        isA<SelicError>()
            .having(
              (s) => s.error,
              'error',
              ServerErrorMessages.connectionError,
            )
            .having((s) => s.metric, 'metric', isNull)
            .having((s) => s.chartUnavailable, 'chartUnavailable', isFalse),
      ],
    );

    blocTest<SelicCubit, SelicState>(
      'valor do cache chega como loaded e offline',
      setUp: () => answer(
        SelicPeriod.months12,
        SuccessResult(metric.copyWith(offline: true)),
      ),
      build: () => SelicCubit(useCase),
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<SelicLoading>(),
        isA<SelicLoaded>().having((s) => s.offline, 'offline', isTrue),
      ],
    );

    blocTest<SelicCubit, SelicState>(
      'changePeriod busca 5 anos mantendo a taxa durante o carregamento',
      setUp: () {
        answer(SelicPeriod.months12, SuccessResult(metric));
        answer(SelicPeriod.years5, SuccessResult(fiveYears));
      },
      build: () => SelicCubit(useCase),
      act: (cubit) async {
        await cubit.load();
        await cubit.changePeriod(SelicPeriod.years5);
      },
      skip: 2,
      expect: () => [
        isA<SelicLoading>()
            .having((s) => s.metric, 'metric', metric)
            .having((s) => s.period, 'period', SelicPeriod.years5)
            .having((s) => s.chartUnavailable, 'chartUnavailable', isTrue),
        isA<SelicLoaded>()
            .having((s) => s.metric, 'metric', fiveYears)
            .having((s) => s.period, 'period', SelicPeriod.years5),
      ],
    );

    blocTest<SelicCubit, SelicState>(
      '5 anos sem rede e sem cache: mantém a taxa e só o gráfico falta',
      setUp: () {
        answer(SelicPeriod.months12, SuccessResult(metric));
        answer(SelicPeriod.years5, offlineError);
      },
      build: () => SelicCubit(useCase),
      act: (cubit) async {
        await cubit.load();
        await cubit.changePeriod(SelicPeriod.years5);
      },
      skip: 3,
      expect: () => [
        isA<SelicError>()
            .having((s) => s.metric, 'metric', metric)
            .having((s) => s.period, 'period', SelicPeriod.years5)
            .having((s) => s.chartUnavailable, 'chartUnavailable', isTrue),
      ],
    );

    blocTest<SelicCubit, SelicState>(
      'voltar para um período já carregado usa o valor dele',
      setUp: () {
        answer(SelicPeriod.months12, SuccessResult(metric));
        answer(SelicPeriod.years5, SuccessResult(fiveYears));
      },
      build: () => SelicCubit(useCase),
      act: (cubit) async {
        await cubit.load();
        await cubit.changePeriod(SelicPeriod.years5);
        await cubit.changePeriod(SelicPeriod.months12);
      },
      skip: 4,
      expect: () => [
        isA<SelicLoading>()
            .having((s) => s.metric, 'metric', metric)
            .having((s) => s.chartUnavailable, 'chartUnavailable', isFalse),
        isA<SelicLoaded>().having((s) => s.metric, 'metric', metric),
      ],
    );

    blocTest<SelicCubit, SelicState>(
      'o mesmo período não consulta de novo',
      setUp: () => answer(SelicPeriod.months12, SuccessResult(metric)),
      build: () => SelicCubit(useCase),
      act: (cubit) => cubit.changePeriod(SelicPeriod.months12),
      expect: () => <SelicState>[],
      verify: (_) => verifyNever(() => useCase.getSelic(any())),
    );

    test('resposta antiga não sobrescreve a troca mais recente', () async {
      final slow = Completer<Result<ErrorMessages, Metric>>();
      when(
        () => useCase.getSelic(SelicPeriod.years5),
      ).thenAnswer((_) => slow.future);
      answer(SelicPeriod.months12, SuccessResult(metric));
      final cubit = SelicCubit(useCase);
      addTearDown(cubit.close);

      final first = cubit.changePeriod(SelicPeriod.years5);
      await cubit.changePeriod(SelicPeriod.months12);
      slow.complete(SuccessResult(fiveYears));
      await first;

      expect(cubit.state.period, SelicPeriod.months12);
      expect(cubit.state.metric, metric);
    });

    blocTest<SelicCubit, SelicState>(
      'retry consulta de novo o período atual',
      setUp: () => answer(SelicPeriod.months12, SuccessResult(metric)),
      build: () => SelicCubit(useCase),
      act: (cubit) => cubit.retry(),
      expect: () => [isA<SelicLoading>(), isA<SelicLoaded>()],
      verify: (_) =>
          verify(() => useCase.getSelic(SelicPeriod.months12)).called(1),
    );
  });
}
