import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_calc/core/adapter/network/dio/dio_network_adapter.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/core/seed_works/error.dart';
import 'package:real_calc/core/seed_works/result.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late DioNetworkAdapter adapter;

  setUp(() {
    dio = MockDio();
    adapter = DioNetworkAdapter(dio);
  });

  test('get retorna sucesso com o payload da resposta', () async {
    when(() => dio.get<dynamic>('/selic')).thenAnswer(
      (_) async => Response<dynamic>(
        data: {'valor': '10.50'},
        requestOptions: RequestOptions(path: '/selic'),
      ),
    );

    final result = await adapter.get<Map<String, dynamic>>('/selic');

    expect(result, isA<SuccessResult<ErrorMessages, Map<String, dynamic>>>());
    expect(result.getOrNull(), {'valor': '10.50'});
    verify(() => dio.get<dynamic>('/selic')).called(1);
  });

  test('get converte exceção em erro de servidor', () async {
    when(() => dio.get<dynamic>('/selic')).thenThrow(
      DioException(requestOptions: RequestOptions(path: '/selic')),
    );

    final result = await adapter.get<Map<String, dynamic>>('/selic');

    expect(result.isError, isTrue);
    expect(result.getErrorOrNull(), ServerErrorMessages.connectionError);
  });

  test('post envia o body e retorna sucesso', () async {
    final body = {'value': 10.5};
    when(() => dio.post<dynamic>('/selic', data: body)).thenAnswer(
      (_) async => Response<dynamic>(
        data: body,
        requestOptions: RequestOptions(path: '/selic'),
      ),
    );

    final result = await adapter.post<Map<String, dynamic>>('/selic', body);

    expect(result.getOrNull(), body);
    verify(() => dio.post<dynamic>('/selic', data: body)).called(1);
  });

  test('post converte exceção em erro de servidor', () async {
    when(() => dio.post<dynamic>('/selic', data: any(named: 'data')))
        .thenThrow(DioException(requestOptions: RequestOptions(path: '/selic')));

    final result = await adapter.post<Map<String, dynamic>>(
      '/selic',
      {'value': 10.5},
    );

    expect(result.isError, isTrue);
    expect(result.getErrorOrNull(), ServerErrorMessages.connectionError);
  });

  test('put envia o body e retorna sucesso', () async {
    final body = {'value': 10.75};
    when(() => dio.put<dynamic>('/selic', data: body)).thenAnswer(
      (_) async => Response<dynamic>(
        data: body,
        requestOptions: RequestOptions(path: '/selic'),
      ),
    );

    final result = await adapter.put<Map<String, dynamic>>('/selic', body);

    expect(result, isA<SuccessResult<ErrorMessages, Map<String, dynamic>>>());
    expect(result.getOrNull(), body);
    verify(() => dio.put<dynamic>('/selic', data: body)).called(1);
  });

  test('put converte exceção em erro de servidor', () async {
    when(() => dio.put<dynamic>('/selic', data: any(named: 'data')))
        .thenThrow(DioException(requestOptions: RequestOptions(path: '/selic')));

    final result = await adapter.put<Map<String, dynamic>>(
      '/selic',
      {'value': 10.75},
    );

    expect(result.isError, isTrue);
    expect(result.getErrorOrNull(), ServerErrorMessages.connectionError);
  });

  test('delete retorna sucesso com o payload da resposta', () async {
    when(() => dio.delete<dynamic>('/selic')).thenAnswer(
      (_) async => Response<dynamic>(
        data: {'deleted': true},
        requestOptions: RequestOptions(path: '/selic'),
      ),
    );

    final result = await adapter.delete<Map<String, dynamic>>('/selic');

    expect(result, isA<SuccessResult<ErrorMessages, Map<String, dynamic>>>());
    expect(result.getOrNull(), {'deleted': true});
    verify(() => dio.delete<dynamic>('/selic')).called(1);
  });

  test('delete converte exceção em erro de servidor', () async {
    when(() => dio.delete<dynamic>('/selic')).thenThrow(
      DioException(requestOptions: RequestOptions(path: '/selic')),
    );

    final result = await adapter.delete<Map<String, dynamic>>('/selic');

    expect(result.isError, isTrue);
    expect(result.getErrorOrNull(), ServerErrorMessages.connectionError);
  });
}
