import 'package:dio/dio.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/core/seed_works/error.dart';
import 'package:real_calc/core/seed_works/result.dart';

import '../../../seed_works/network.dart';

class DioNetworkAdapter implements Network {
  final Dio _dio;

  DioNetworkAdapter(this._dio);
  
  @override
  Future<Result<ErrorMessages, T>> delete<T>(String url) async {
    try {
      final response = await _dio.delete(url);
      return SuccessResult<ErrorMessages, T>(response.data as T);
    } catch (e) {
      return FailureResult<ErrorMessages, T>(
        ServerErrorMessages.connectionError,
      );
    }
  }
  
  @override
  Future<Result<ErrorMessages, T>> get<T>(String url) async {
    try {
      final response = await _dio.get(url);
      return SuccessResult<ErrorMessages, T>(response.data as T);
    } catch (e) {
      return FailureResult<ErrorMessages, T>(
        ServerErrorMessages.connectionError,
      );
    }
  }
  
  @override
  Future<Result<ErrorMessages, T>> post<T>(String url, Map<String, dynamic> body) async {
    try {
      final response = await _dio.post(url, data: body);
      return SuccessResult<ErrorMessages, T>(response.data as T);
    } catch (e) {
      return FailureResult<ErrorMessages, T>(
        ServerErrorMessages.connectionError,
      );
    }
  }
  
  @override
  Future<Result<ErrorMessages, T>> put<T>(String url, Map<String, dynamic> body) async {
    try {
      final response = await _dio.put(url, data: body);
      return SuccessResult<ErrorMessages, T>(response.data as T);
    } catch (e) {
      return FailureResult<ErrorMessages, T>(
        ServerErrorMessages.connectionError,
      );
    }
  }

 
}