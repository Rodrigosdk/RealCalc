import 'dart:math';

import 'package:real_calc/core/seed_works/result.dart';

import '../../../../core/seed_works/error.dart';
import '../../../../shared/network/response/selic_bc_response_network.dart';
import '../../domain/entites/metric.dart';
import '../../domain/enum/selic_period.dart';
import '../../domain/repositories/selic/i_selic_cache_repository.dart';
import '../../domain/repositories/selic/i_selic_network_only_repository.dart';
import 'i_selic_use_case.dart';
import 'selic_validation.dart';

class SelicUseCase implements ISelicUseCase {
  final ISelicNetworkOnlyRepository _selicRepository;
  final SelicValidation _validation;
  final ISelicCacheRepository _cache;
  final DateTime Function() _now;

  static const maxChartPoints = 60;

  SelicUseCase(
    this._selicRepository,
    this._validation,
    this._cache, {
    DateTime Function() now = DateTime.now,
  }) : _now = now;

  @override
  Future<Result<ErrorMessages, Metric>> getSelic(SelicPeriod period) async {
    final now = _now();
    final result = switch (period) {
      SelicPeriod.months12 => await getSelicRate(),
      SelicPeriod.years5 => await getSelicRateByPeriod(
        dataInicial: DateTime(now.year - 5, now.month, now.day),
        dataFinal: now,
      ),
    };

    return result.fold(
      (error) async {
        final cached = await _cache.read(period);
        return cached == null
            ? FailureResult<ErrorMessages, Metric>(error)
            : SuccessResult<ErrorMessages, Metric>(
                cached.copyWith(offline: true),
              );
      },
      (metric) async {
        final reduced = period == SelicPeriod.years5
            ? _onePointPerMonth(metric)
            : metric;
        final fresh = reduced.copyWith(updatedAt: now);
        try {
          await _cache.save(period, fresh);
        } on Object {
          // Sem cache o app só perde o modo offline; o valor da rede segue.
        }
        return SuccessResult<ErrorMessages, Metric>(fresh);
      },
    );
  }

  Metric _onePointPerMonth(Metric metric) {
    final values = metric.sparklineData;
    final dates = metric.sparklineDates;
    if (dates.length != values.length) {
      return metric.copyWith(
        sparklineData: values
            .skip(max(0, values.length - maxChartPoints))
            .toList(),
        sparklineDates: const [],
      );
    }

    final byMonth = <int, int>{};
    for (var i = 0; i < dates.length; i++) {
      byMonth[dates[i].year * 12 + dates[i].month] = i;
    }
    final kept = byMonth.values.toList()..sort();
    final last = kept.skip(max(0, kept.length - maxChartPoints)).toList();
    return metric.copyWith(
      sparklineData: [for (final i in last) values[i]],
      sparklineDates: [for (final i in last) dates[i]],
    );
  }

  @override
  Future<Result<ErrorMessages, Metric>> getSelicRate() async {
    final result = await _selicRepository.getSelicRate();

    return result.fold(
      (error) => FailureResult<ErrorMessages, Metric>(error),
      (data) => SuccessResult<ErrorMessages, Metric>(_mapToMetric(data)),
    );
  }

  @override
  Future<Result<ErrorMessages, Metric>> getSelicRateByPeriod({
    required DateTime dataInicial,
    required DateTime dataFinal,
  }) async {
    final validationError = _validation.validatePeriod(
      dataInicial: dataInicial,
      dataFinal: dataFinal,
    );
    if (validationError != null) {
      return FailureResult<ErrorMessages, Metric>(validationError);
    }

    final result = await _selicRepository.getSelicRateByPeriod(
      dataInicial: dataInicial,
      dataFinal: dataFinal,
    );

    return result.fold(
      (error) => FailureResult<ErrorMessages, Metric>(error),
      (data) => SuccessResult<ErrorMessages, Metric>(_mapToMetric(data)),
    );
  }

  Metric _mapToMetric(List<SelicBcResponseNetwork> data) {
    final anualRate = double.tryParse(data.last.valor ?? '') ?? 0.0;
    final variationPercent = _calculateVariation(data);
    final sparklineData = data.map((e) => double.parse(e.valor!)).toList();
    final dates = data.map((e) => _parseDate(e.data)).toList();

    return Metric(
      anualRate: anualRate,
      variationPercent: variationPercent,
      sparklineData: sparklineData,
      sparklineDates: dates.contains(null) ? const [] : dates.cast<DateTime>(),
      lastDate: dates.isEmpty ? null : dates.last,
    );
  }

  DateTime? _parseDate(String? value) {
    final parts = value?.split('/');
    if (parts == null || parts.length != 3) return null;
    final [day, month, year] = parts.map(int.tryParse).toList();
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  double _calculateVariation(List<SelicBcResponseNetwork> values) {
    if (values.length < 2) return 0.0;

    final currentValue = double.tryParse(values.last.valor!) ?? 0.0;

    for (int i = values.length - 2; i >= 0; i--) {
      final previousValue = double.tryParse(values[i].valor!) ?? 0.0;
      if (previousValue != currentValue) {
        return double.parse((currentValue - previousValue).toStringAsFixed(2));
      }
    }

    return 0.0;
  }
}
