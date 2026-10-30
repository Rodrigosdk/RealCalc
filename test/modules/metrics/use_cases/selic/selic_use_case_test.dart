import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/core/seed_works/error.dart';
import 'package:real_calc/core/seed_works/result.dart';
import 'package:real_calc/modules/metrics/domain/entites/metric.dart';
import 'package:real_calc/modules/metrics/domain/enum/selic_period.dart';
import 'package:real_calc/modules/metrics/domain/repositories/selic/i_selic_cache_repository.dart';
import 'package:real_calc/modules/metrics/domain/repositories/selic/i_selic_network_only_repository.dart';
import 'package:real_calc/modules/metrics/use_cases/selic/selic_use_case.dart';
import 'package:real_calc/modules/metrics/use_cases/selic/selic_validation.dart';
import 'package:real_calc/shared/network/response/selic_bc_response_network.dart';

class MockSelicRepository extends Mock implements ISelicNetworkOnlyRepository {}

class MockSelicCache extends Mock implements ISelicCacheRepository {}

void main() {
  final now = DateTime(2026, 11, 3, 10);
  late MockSelicRepository repository;
  late MockSelicCache cache;
  late SelicUseCase useCase;

  setUpAll(() {
    registerFallbackValue(SelicPeriod.months12);
    registerFallbackValue(
      Metric(anualRate: 0, variationPercent: 0, sparklineData: const []),
    );
  });

  setUp(() {
    repository = MockSelicRepository();
    cache = MockSelicCache();
    when(() => cache.save(any(), any())).thenAnswer((_) async {});
    when(() => cache.read(any())).thenAnswer((_) async => null);
    useCase = SelicUseCase(
      repository,
      SelicValidation(),
      cache,
      now: () => now,
    );
  });

  Metric cached() => Metric(
    anualRate: 15,
    variationPercent: 0,
    sparklineData: const [15, 15],
    updatedAt: DateTime(2026, 10, 21),
  );

  void networkFails() {
    when(() => repository.getSelicRate()).thenAnswer(
      (_) async => FailureResult<ErrorMessages, List<SelicBcResponseNetwork>>(
        ServerErrorMessages.connectionError,
      ),
    );
    when(
      () => repository.getSelicRateByPeriod(
        dataInicial: any(named: 'dataInicial'),
        dataFinal: any(named: 'dataFinal'),
      ),
    ).thenAnswer(
      (_) async => FailureResult<ErrorMessages, List<SelicBcResponseNetwork>>(
        ServerErrorMessages.connectionError,
      ),
    );
  }

  group('getSelic', () {
    test(
      'rede ok grava o cache do período com a data de atualização',
      () async {
        when(() => repository.getSelicRate()).thenAnswer(
          (_) async =>
              SuccessResult<ErrorMessages, List<SelicBcResponseNetwork>>([
                const SelicBcResponseNetwork(
                  data: '02/11/2026',
                  valor: '15.00',
                ),
                const SelicBcResponseNetwork(
                  data: '03/11/2026',
                  valor: '14.75',
                ),
              ]),
        );

        final metric = (await useCase.getSelic(
          SelicPeriod.months12,
        )).getOrNull()!;

        expect(metric.anualRate, 14.75);
        expect(metric.offline, isFalse);
        expect(metric.updatedAt, now);
        final saved =
            verify(
                  () => cache.save(SelicPeriod.months12, captureAny()),
                ).captured.single
                as Metric;
        expect(saved.anualRate, 14.75);
        expect(saved.updatedAt, now);
      },
    );

    test('rede com falha e cache devolve o valor salvo sem conexão', () async {
      networkFails();
      when(
        () => cache.read(SelicPeriod.months12),
      ).thenAnswer((_) async => cached());

      final metric = (await useCase.getSelic(
        SelicPeriod.months12,
      )).getOrNull()!;

      expect(metric.offline, isTrue);
      expect(metric.anualRate, 15);
      expect(metric.updatedAt, DateTime(2026, 10, 21));
      verifyNever(() => cache.save(any(), any()));
    });

    test('rede com falha e sem cache devolve o erro', () async {
      networkFails();

      final result = await useCase.getSelic(SelicPeriod.years5);

      expect(result.getErrorOrNull(), ServerErrorMessages.connectionError);
      verify(() => cache.read(SelicPeriod.years5)).called(1);
    });

    test('o cache de um período não serve para o outro', () async {
      networkFails();
      when(
        () => cache.read(SelicPeriod.months12),
      ).thenAnswer((_) async => cached());

      final result = await useCase.getSelic(SelicPeriod.years5);

      expect(result.isError, isTrue);
    });

    test('5 anos usa o período e reduz a série a um ponto por mês', () async {
      final start = DateTime(2021, 11, 3);
      final points = [
        for (var d = start; !d.isAfter(now); d = d.add(const Duration(days: 1)))
          SelicBcResponseNetwork(
            data:
                '${d.day.toString().padLeft(2, '0')}/'
                '${d.month.toString().padLeft(2, '0')}/${d.year}',
            valor: '${10 + d.month / 100}',
          ),
      ];
      when(
        () => repository.getSelicRateByPeriod(
          dataInicial: DateTime(2021, 11, 3),
          dataFinal: now,
        ),
      ).thenAnswer(
        (_) async =>
            SuccessResult<ErrorMessages, List<SelicBcResponseNetwork>>(points),
      );

      final metric = (await useCase.getSelic(SelicPeriod.years5)).getOrNull()!;

      expect(points.length, greaterThan(1000));
      expect(metric.sparklineData, hasLength(SelicUseCase.maxChartPoints));
      expect(metric.sparklineDates, hasLength(SelicUseCase.maxChartPoints));
      final months = {
        for (final date in metric.sparklineDates) (date.year, date.month),
      };
      expect(months, hasLength(SelicUseCase.maxChartPoints));
      expect(metric.sparklineDates.last, DateTime(2026, 11, 3));
      expect(metric.lastDate, DateTime(2026, 11, 3));
      verifyNever(() => repository.getSelicRate());
      verify(() => cache.save(SelicPeriod.years5, any())).called(1);
    });

    test('falha ao gravar o cache não derruba o valor da rede', () async {
      when(() => repository.getSelicRate()).thenAnswer(
        (_) async => SuccessResult<ErrorMessages, List<SelicBcResponseNetwork>>(
          [const SelicBcResponseNetwork(data: '03/11/2026', valor: '14.75')],
        ),
      );
      when(() => cache.save(any(), any())).thenThrow(Exception('disco cheio'));

      final result = await useCase.getSelic(SelicPeriod.months12);

      expect(result.getOrNull()!.anualRate, 14.75);
    });
  });

  test('mapeia os dados do repository para Metric', () async {
    when(() => repository.getSelicRate()).thenAnswer(
      (_) async => SuccessResult<ErrorMessages, List<SelicBcResponseNetwork>>([
        const SelicBcResponseNetwork(valor: '10.00'),
        const SelicBcResponseNetwork(valor: '10.50'),
      ]),
    );

    final result = await useCase.getSelicRate();

    final metric = result.getOrNull();
    expect(metric, isA<Metric>());
    expect(metric!.anualRate, 10.5);
    expect(metric.variationPercent, closeTo(0.5, 0.0001));
    expect(metric.sparklineData, [10.0, 10.5]);
  });

  test('guarda as datas dos pontos e a data da última atualização', () async {
    when(() => repository.getSelicRate()).thenAnswer(
      (_) async => SuccessResult<ErrorMessages, List<SelicBcResponseNetwork>>([
        const SelicBcResponseNetwork(data: '30/10/2026', valor: '15.00'),
        const SelicBcResponseNetwork(data: '03/11/2026', valor: '14.75'),
      ]),
    );

    final metric = (await useCase.getSelicRate()).getOrNull()!;

    expect(metric.sparklineDates, [
      DateTime(2026, 10, 30),
      DateTime(2026, 11, 3),
    ]);
    expect(metric.lastDate, DateTime(2026, 11, 3));
  });

  test('não consulta o repository quando o período é inválido', () async {
    final result = await useCase.getSelicRateByPeriod(
      dataInicial: DateTime(2026, 1, 1),
      dataFinal: DateTime(2036, 1, 2),
    );

    expect(result.getErrorOrNull(), SelicValidationMessage.periodExceedsLimit);
    verifyNever(
      () => repository.getSelicRateByPeriod(
        dataInicial: any(named: 'dataInicial'),
        dataFinal: any(named: 'dataFinal'),
      ),
    );
  });

  test('consulta o repository quando o período é válido', () async {
    when(
      () => repository.getSelicRateByPeriod(
        dataInicial: DateTime(2025, 1, 1),
        dataFinal: DateTime(2026, 1, 1),
      ),
    ).thenAnswer(
      (_) async => SuccessResult<ErrorMessages, List<SelicBcResponseNetwork>>([
        const SelicBcResponseNetwork(valor: '12.00'),
      ]),
    );

    final result = await useCase.getSelicRateByPeriod(
      dataInicial: DateTime(2025, 1, 1),
      dataFinal: DateTime(2026, 1, 1),
    );

    expect(result.isSuccess, isTrue);
    verify(
      () => repository.getSelicRateByPeriod(
        dataInicial: DateTime(2025, 1, 1),
        dataFinal: DateTime(2026, 1, 1),
      ),
    ).called(1);
  });
}
