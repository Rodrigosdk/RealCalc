import 'package:dio/dio.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/core/seed_works/error.dart';
import 'package:real_calc/core/seed_works/result.dart';

import '../../../seed_works/network.dart';

class DioNetworkAdapter implements Network {
  final Dio _dio;

  DioNetworkAdapter(this._dio);

  @override
  Future<Result<ErrorMessages, T>> get<T>(String url) =>
      _request<T>(() => _dio.get(url));

  /// Falha de rede ou resposta num formato diferente do esperado viram erro de conexão.
  Future<Result<ErrorMessages, T>> _request<T>(
    Future<Response<dynamic>> Function() call,
  ) async {
    try {
      final data = (await call()).data;
      if (data is T) return SuccessResult<ErrorMessages, T>(data);
      return FailureResult<ErrorMessages, T>(
        ServerErrorMessages.connectionError,
      );
    } on DioException {
      return FailureResult<ErrorMessages, T>(
        ServerErrorMessages.connectionError,
      );
    }
  }
}
