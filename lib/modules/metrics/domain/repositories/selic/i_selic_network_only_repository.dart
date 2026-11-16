import 'package:real_calc/core/seed_works/error.dart';
import 'package:real_calc/core/seed_works/result.dart';
import 'package:real_calc/shared/network/response/sgs_point_response.dart';

abstract class ISelicNetworkOnlyRepository {
  Future<Result<ErrorMessages, List<SgsPointResponse>>> getSelicRate();
  Future<Result<ErrorMessages, List<SgsPointResponse>>> getSelicRateByPeriod({
    required DateTime dataInicial,
    required DateTime dataFinal,
  });
}
