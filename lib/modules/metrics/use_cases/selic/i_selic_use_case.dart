import 'package:real_calc/core/seed_works/result.dart';

import '../../../../core/seed_works/error.dart';
import '../../domain/entites/metric.dart';
import '../../domain/enum/selic_period.dart';

abstract class ISelicUseCase {
  /// Tenta a rede e, se falhar, devolve o último valor salvo do período
  /// marcado como `offline`.
  Future<Result<ErrorMessages, Metric>> getSelic(SelicPeriod period);
  Future<Result<ErrorMessages, Metric>> getSelicRate();
  Future<Result<ErrorMessages, Metric>> getSelicRateByPeriod({
    required DateTime dataInicial,
    required DateTime dataFinal,
  });
}
