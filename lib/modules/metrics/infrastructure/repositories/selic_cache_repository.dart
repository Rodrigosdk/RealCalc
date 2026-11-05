import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entites/metric.dart';
import '../../domain/enum/selic_period.dart';
import '../../domain/repositories/selic/i_selic_cache_repository.dart';

class SelicCacheRepository implements ISelicCacheRepository {
  static String keyFor(SelicPeriod period) => 'selic_cache_${period.name}';

  final Future<SharedPreferences> Function() _preferences;

  SelicCacheRepository([this._preferences = SharedPreferences.getInstance]);

  @override
  Future<Metric?> read(SelicPeriod period) async {
    final raw = (await _preferences()).getString(keyFor(period));
    if (raw == null) return null;
    try {
      return _fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      return null;
    }
  }

  @override
  Future<void> save(SelicPeriod period, Metric metric) async {
    await (await _preferences()).setString(
      keyFor(period),
      jsonEncode(_toJson(metric)),
    );
  }

  Map<String, dynamic> _toJson(Metric metric) => {
    'anualRate': metric.anualRate,
    'variationPercent': metric.variationPercent,
    'sparklineData': metric.sparklineData,
    'sparklineDates': [
      for (final date in metric.sparklineDates) date.toIso8601String(),
    ],
    'lastDate': metric.lastDate?.toIso8601String(),
    'updatedAt': metric.updatedAt?.toIso8601String(),
  };

  Metric _fromJson(Map<String, dynamic> json) {
    DateTime? date(Object? value) =>
        value is String ? DateTime.parse(value) : null;

    return Metric(
      anualRate: (json['anualRate'] as num).toDouble(),
      variationPercent: (json['variationPercent'] as num).toDouble(),
      sparklineData: [
        for (final value in json['sparklineData'] as List)
          (value as num).toDouble(),
      ],
      sparklineDates: [
        for (final value in json['sparklineDates'] as List)
          DateTime.parse(value as String),
      ],
      lastDate: date(json['lastDate']),
      updatedAt: date(json['updatedAt']),
    );
  }
}
