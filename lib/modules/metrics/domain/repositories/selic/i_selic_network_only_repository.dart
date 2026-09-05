import 'package:real_calc/core/seed_works/error.dart';
import 'package:real_calc/core/seed_works/result.dart';
import 'package:real_calc/shared/network/response/selic_bc_response_network.dart';

abstract class ISelicNetworkOnlyRepository {
  Future<Result<ErrorMessages, List<SelicBcResponseNetwork>>> getSelicRate();
  Future<Result<ErrorMessages, List<SelicBcResponseNetwork>>> getSelicRateByPeriod({
    required DateTime dataInicial,
    required DateTime dataFinal,
  });
}