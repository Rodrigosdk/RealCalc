import 'package:real_calc/core/seed_works/network.dart';
import 'package:real_calc/shared/network/response/selic_bc_response_network.dart';
import '../../../../core/seed_works/error.dart';
import '../../../../core/seed_works/result.dart';
import '../../domain/repositories/selic/i_selic_network_only_repository.dart';

class SelicRepository implements ISelicNetworkOnlyRepository {
  final String _endpoint = 'https://api.bcb.gov.br/dados/serie/bcdata.sgs.432';
  final Network _selicDatasource;

  SelicRepository(this._selicDatasource);

  @override
  Future<Result<ErrorMessages, List<SelicBcResponseNetwork>>> getSelicRate() async {
    final dataFinal = DateTime.now();
    final dataInicial = DateTime(
      dataFinal.year - 4,
      dataFinal.month,
      dataFinal.day,
    );

    final response = await _selicDatasource.get<List<dynamic>>(
      '$_endpoint/dados?formato=json&dataInicial=${_formatDate(dataInicial)}&dataFinal=${_formatDate(dataFinal)}',
    );

    return response.fold(
      (error) => FailureResult<ErrorMessages, List<SelicBcResponseNetwork>>(error),
      (data) => SuccessResult<ErrorMessages, List<SelicBcResponseNetwork>>(
        data
            .whereType<Map<String, dynamic>>()
            .map(SelicBcResponseNetwork.fromJson)
            .toList(growable: false),
      ),
    );
  }

  // Método adicional para buscar por período específico
  @override
  Future<Result<ErrorMessages, List<SelicBcResponseNetwork>>> getSelicRateByPeriod({
    required DateTime dataInicial,
    required DateTime dataFinal,
  }) async {
    final response = await _selicDatasource.get<List<dynamic>>(
      '$_endpoint/dados?formato=json&dataInicial=${_formatDate(dataInicial)}&dataFinal=${_formatDate(dataFinal)}',
    );

    return response.fold(
      (error) => FailureResult<ErrorMessages, List<SelicBcResponseNetwork>>(error),
      (data) => SuccessResult<ErrorMessages, List<SelicBcResponseNetwork>>(
        data
            .whereType<Map<String, dynamic>>()
            .map(SelicBcResponseNetwork.fromJson)
            .toList(growable: false),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}