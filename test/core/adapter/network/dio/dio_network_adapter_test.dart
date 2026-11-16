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
    when(
      () => dio.get<dynamic>('/selic'),
    ).thenThrow(DioException(requestOptions: RequestOptions(path: '/selic')));

    final result = await adapter.get<Map<String, dynamic>>('/selic');

    expect(result.isError, isTrue);
    expect(result.getErrorOrNull(), ServerErrorMessages.connectionError);
  });

  test(
    'get converte resposta em formato inesperado em erro de servidor',
    () async {
      when(() => dio.get<dynamic>('/selic')).thenAnswer(
        (_) async => Response<dynamic>(
          data: 'resposta inesperada',
          requestOptions: RequestOptions(path: '/selic'),
        ),
      );

      final result = await adapter.get<Map<String, dynamic>>('/selic');

      expect(result.isError, isTrue);
      expect(result.getErrorOrNull(), ServerErrorMessages.connectionError);
    },
  );
}
