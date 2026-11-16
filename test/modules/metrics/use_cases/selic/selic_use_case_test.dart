import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/core/seed_works/error.dart';
import 'package:real_calc/core/seed_works/result.dart';
import 'package:real_calc/modules/metrics/domain/entities/metric.dart';
import 'package:real_calc/modules/metrics/domain/enum/selic_period.dart';
import 'package:real_calc/modules/metrics/domain/repositories/selic/i_selic_cache_repository.dart';
import 'package:real_calc/modules/metrics/domain/repositories/selic/i_selic_network_only_repository.dart';
import 'package:real_calc/modules/metrics/use_cases/selic/selic_use_case.dart';
import 'package:real_calc/modules/metrics/use_cases/selic/selic_validation.dart';
import 'package:real_calc/shared/network/response/sgs_point_response.dart';

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
      (_) async => FailureResult<ErrorMessages, List<SgsPointResponse>>(
        ServerErrorMessages.connectionError,
      ),
    );
    when(
      () => repository.getSelicRateByPeriod(
        dataInicial: any(named: 'dataInicial'),
        dataFinal: any(named: 'dataFinal'),
      ),
    ).thenAnswer(
      (_) async => FailureResult<ErrorMessages, List<SgsPointResponse>>(
        ServerErrorMessages.connectionError,
      ),
    );
  }

  void networkReturns(List<SgsPointResponse> points) {
    when(() => repository.getSelicRate()).thenAnswer(
      (_) async => SuccessResult<ErrorMessages, List<SgsPointResponse>>(points),
    );
  }

  group('getSelic', () {
    test(
      'rede ok grava o cache do período com a data de atualização',
      () async {
        when(() => repository.getSelicRate()).thenAnswer(
          (_) async => SuccessResult<ErrorMessages, List<SgsPointResponse>>([
            const SgsPointResponse(data: '02/11/2026', valor: '15.00'),
            const SgsPointResponse(data: '03/11/2026', valor: '14.75'),
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

    test(
      'resposta sem pontos válidos devolve o valor salvo sem conexão',
      () async {
        networkReturns(const [SgsPointResponse(data: '03/11/2026')]);
        when(
          () => cache.read(SelicPeriod.months12),
        ).thenAnswer((_) async => cached());

        final metric = (await useCase.getSelic(
          SelicPeriod.months12,
        )).getOrNull()!;

        expect(metric.offline, isTrue);
        expect(metric.anualRate, 15);
        verifyNever(() => cache.save(any(), any()));
      },
    );

    test('resposta vazia e sem cache devolve erro', () async {
      networkReturns(const []);

      final result = await useCase.getSelic(SelicPeriod.months12);

      expect(result.getErrorOrNull(), ServerErrorMessages.invalidResponse);
      verify(() => cache.read(SelicPeriod.months12)).called(1);
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
          SgsPointResponse(
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
            SuccessResult<ErrorMessages, List<SgsPointResponse>>(points),
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
        (_) async => SuccessResult<ErrorMessages, List<SgsPointResponse>>([
          const SgsPointResponse(data: '03/11/2026', valor: '14.75'),
        ]),
      );
      when(() => cache.save(any(), any())).thenThrow(Exception('disco cheio'));

      final result = await useCase.getSelic(SelicPeriod.months12);

      expect(result.getOrNull()!.anualRate, 14.75);
    });
  });

  test('mapeia os dados do repository para Metric', () async {
    when(() => repository.getSelicRate()).thenAnswer(
      (_) async => SuccessResult<ErrorMessages, List<SgsPointResponse>>([
        const SgsPointResponse(data: '30/10/2026', valor: '10.00'),
        const SgsPointResponse(data: '03/11/2026', valor: '10.50'),
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
      (_) async => SuccessResult<ErrorMessages, List<SgsPointResponse>>([
        const SgsPointResponse(data: '30/10/2026', valor: '15.00'),
        const SgsPointResponse(data: '03/11/2026', valor: '14.75'),
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
      (_) async => SuccessResult<ErrorMessages, List<SgsPointResponse>>([
        const SgsPointResponse(data: '31/12/2025', valor: '12.00'),
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

  group('pontos inválidos da API', () {
    test('ignora ponto com valor nulo', () async {
      networkReturns(const [
        SgsPointResponse(data: '30/10/2026', valor: '15.00'),
        SgsPointResponse(data: '03/11/2026'),
      ]);

      final metric = (await useCase.getSelicRate()).getOrNull()!;

      expect(metric.anualRate, 15);
      expect(metric.sparklineData, [15.0]);
      expect(metric.lastDate, DateTime(2026, 10, 30));
    });

    test('ignora ponto com valor não numérico ou vazio', () async {
      networkReturns(const [
        SgsPointResponse(data: '29/10/2026', valor: '15.00'),
        SgsPointResponse(data: '30/10/2026', valor: 'abc'),
        SgsPointResponse(data: '31/10/2026', valor: ''),
        SgsPointResponse(data: '03/11/2026', valor: '14.75'),
      ]);

      final metric = (await useCase.getSelicRate()).getOrNull()!;

      expect(metric.sparklineData, [15.0, 14.75]);
      expect(metric.sparklineDates, [
        DateTime(2026, 10, 29),
        DateTime(2026, 11, 3),
      ]);
      expect(metric.variationPercent, closeTo(-0.25, 0.0001));
    });

    test('ignora ponto sem data válida', () async {
      networkReturns(const [
        SgsPointResponse(valor: '16.00'),
        SgsPointResponse(data: '2026-10-31', valor: '15.50'),
        SgsPointResponse(data: '03/11/2026', valor: '14.75'),
      ]);

      final metric = (await useCase.getSelicRate()).getOrNull()!;

      expect(metric.sparklineData, [14.75]);
      expect(metric.lastDate, DateTime(2026, 11, 3));
    });

    test('aceita valor com vírgula decimal', () async {
      networkReturns(const [
        SgsPointResponse(data: '03/11/2026', valor: '14,75'),
      ]);

      final metric = (await useCase.getSelicRate()).getOrNull()!;

      expect(metric.anualRate, 14.75);
    });

    test('lista vazia devolve falha em vez de exceção', () async {
      networkReturns(const []);

      final result = await useCase.getSelicRate();

      expect(result.getErrorOrNull(), ServerErrorMessages.invalidResponse);
    });

    test('só pontos inválidos devolvem falha em vez de exceção', () async {
      networkReturns(const [
        SgsPointResponse(data: '03/11/2026'),
        SgsPointResponse(data: '04/11/2026', valor: 'n/d'),
      ]);

      final result = await useCase.getSelicRate();

      expect(result.getErrorOrNull(), ServerErrorMessages.invalidResponse);
    });
  });
}
