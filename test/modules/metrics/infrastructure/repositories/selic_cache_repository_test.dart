import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/modules/metrics/domain/entites/metric.dart';
import 'package:real_calc/modules/metrics/domain/enum/selic_period.dart';
import 'package:real_calc/modules/metrics/infrastructure/repositories/selic_cache_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SelicCacheRepository cache;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    cache = SelicCacheRepository();
  });

  final metric = Metric(
    anualRate: 14.75,
    variationPercent: -0.25,
    sparklineData: const [15, 14.75],
    sparklineDates: [DateTime(2026, 10, 1), DateTime(2026, 11, 3)],
    lastDate: DateTime(2026, 11, 3),
    updatedAt: DateTime(2026, 11, 3, 10, 30),
  );

  test('sem nada salvo, devolve null', () async {
    expect(await cache.read(SelicPeriod.months12), isNull);
  });

  test('guarda e lê o Metric de cada período em JSON', () async {
    await cache.save(SelicPeriod.years5, metric);

    final read = (await cache.read(SelicPeriod.years5))!;
    expect(read.anualRate, 14.75);
    expect(read.variationPercent, -0.25);
    expect(read.sparklineData, [15, 14.75]);
    expect(read.sparklineDates, metric.sparklineDates);
    expect(read.lastDate, DateTime(2026, 11, 3));
    expect(read.updatedAt, DateTime(2026, 11, 3, 10, 30));
    expect(read.offline, isFalse);
    expect(await cache.read(SelicPeriod.months12), isNull);

    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getString(SelicCacheRepository.keyFor(SelicPeriod.years5)),
      contains('"anualRate":14.75'),
    );
  });

  test('JSON corrompido é ignorado', () async {
    SharedPreferences.setMockInitialValues({
      SelicCacheRepository.keyFor(SelicPeriod.months12): '{"anualRate":',
    });

    expect(await SelicCacheRepository().read(SelicPeriod.months12), isNull);
  });
}
