import 'package:real_calc/core/seed_works/network.dart';
import 'package:real_calc/shared/network/response/sgs_point_response.dart';
import '../../../../core/seed_works/error.dart';
import '../../../../core/seed_works/result.dart';
import '../../domain/repositories/selic/i_selic_network_only_repository.dart';

class SelicRepository implements ISelicNetworkOnlyRepository {
  final String _endpoint = 'https://api.bcb.gov.br/dados/serie/bcdata.sgs.432';
  final Network _selicDatasource;

  SelicRepository(this._selicDatasource);

  /// Selic dos últimos 12 meses.
  @override
  Future<Result<ErrorMessages, List<SgsPointResponse>>> getSelicRate() {
    final dataFinal = DateTime.now();
    final dataInicial = DateTime(
      dataFinal.year - 1,
      dataFinal.month,
      dataFinal.day,
    );

    return getSelicRateByPeriod(dataInicial: dataInicial, dataFinal: dataFinal);
  }

  @override
  Future<Result<ErrorMessages, List<SgsPointResponse>>> getSelicRateByPeriod({
    required DateTime dataInicial,
    required DateTime dataFinal,
  }) async {
    final response = await _selicDatasource.get<List<dynamic>>(
      '$_endpoint/dados?formato=json&dataInicial=${_formatDate(dataInicial)}&dataFinal=${_formatDate(dataFinal)}',
    );

    return response.fold(
      (error) => FailureResult<ErrorMessages, List<SgsPointResponse>>(error),
      (data) => SuccessResult<ErrorMessages, List<SgsPointResponse>>(
        data
            .whereType<Map<String, dynamic>>()
            .map(SgsPointResponse.fromJson)
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
