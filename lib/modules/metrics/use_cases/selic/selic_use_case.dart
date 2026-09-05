import 'package:real_calc/core/seed_works/result.dart';

import '../../../../core/seed_works/error.dart';
import '../../../../shared/network/response/selic_bc_response_network.dart';
import '../../domain/entites/metric.dart';
import '../../domain/repositories/selic/i_selic_network_only_repository.dart';
import 'i_selic_use_case.dart';
import 'selic_validation.dart';

class SelicUseCase implements ISelicUseCase {
  final ISelicNetworkOnlyRepository _selicRepository;
  final SelicValidation _validation;

  SelicUseCase(this._selicRepository, this._validation);

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

    return Metric(
      anualRate: anualRate,
      variationPercent: variationPercent,
      sparklineData: sparklineData,
    );
  }

  double _calculateVariation(List<SelicBcResponseNetwork> values) {
    if (values.length < 2) return 0.0;
 
    final currentValue =  double.tryParse(values.last.valor!) ?? 0.0;
 
    for (int i = values.length - 2; i >= 0; i--) {
      final previousValue = double.tryParse(values[i].valor!) ?? 0.0;
      if (previousValue != currentValue) {
        return double.parse((currentValue - previousValue).toStringAsFixed(2));
      }
    }
 
    return 0.0;
  }
}
