import 'package:real_calc/core/seed_works/result.dart';

import '../../../../core/seed_works/error.dart';
import '../../domain/entites/metric.dart';

abstract class ISelicUseCase {
  Future<Result<ErrorMessages, Metric>> getSelicRate();
  Future<Result<ErrorMessages, Metric>> getSelicRateByPeriod({
    required DateTime dataInicial,
    required DateTime dataFinal,
  });
}
