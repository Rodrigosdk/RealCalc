import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_calc/core/adapter/network/dio/dio_network_adapter.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/core/seed_works/error.dart';
import 'package:real_calc/core/seed_works/network.dart';
import 'package:real_calc/core/seed_works/result.dart';
import 'package:real_calc/modules/value_correction/domain/entites/series_point.dart';
import 'package:real_calc/modules/value_correction/domain/enum/correction_index.dart';
import 'package:real_calc/modules/value_correction/infrastructure/repositories/sgs_repository.dart';

class MockNetwork extends Mock implements Network {}

void main() {
  late MockNetwork network;
  late SgsRepository repository;

  setUp(() {
    network = MockNetwork();
    repository = SgsRepository(network);
  });

  group('SgsRepository', () {
    test('deve montar a URL e converter payload válido em SeriesPoint', () async {
      when(() => network.get<List<dynamic>>(any())).thenAnswer(
        (_) async => SuccessResult<ErrorMessages, List<dynamic>>([
          {'data': '01/01/2023', 'valor': '0.53'},
          {'data': '01/02/2023', 'valor': '0.81'},
        ]),
      );

      final result = await repository.getSeries(
        index: CorrectionIndex.ipca,
        start: DateTime(2023, 1, 1),
        end: DateTime(2023, 2, 1),
      );

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull(), [
        SeriesPoint(date: DateTime(2023, 1, 1), value: 0.53),
        SeriesPoint(date: DateTime(2023, 2, 1), value: 0.81),
      ]);
      verify(
        () => network.get<List<dynamic>>(
          any(that: contains('bcdata.sgs.433')),
        ),
      ).called(1);
    });

    test('deve ignorar pontos com valor inválido', () async {
      when(() => network.get<List<dynamic>>(any())).thenAnswer(
        (_) async => SuccessResult<ErrorMessages, List<dynamic>>([
          {'data': '01/01/2023', 'valor': '0.53'},
          {'data': '01/02/2023', 'valor': null},
          {'data': '01/03/2023', 'valor': 'abc'},
        ]),
      );

      final result = await repository.getSeries(
        index: CorrectionIndex.ipca,
        start: DateTime(2023, 1, 1),
        end: DateTime(2023, 3, 1),
      );

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull(), [
        SeriesPoint(date: DateTime(2023, 1, 1), value: 0.53),
      ]);
    });

    test('deve propagar erro de conexão da rede', () async {
      when(() => network.get<List<dynamic>>(any())).thenAnswer(
        (_) async => FailureResult<ErrorMessages, List<dynamic>>(
          ServerErrorMessages.connectionError,
        ),
      );

      final result = await repository.getSeries(
        index: CorrectionIndex.ipca,
        start: DateTime(2023, 1, 1),
        end: DateTime(2023, 2, 1),
      );

      expect(result.isError, isTrue);
      expect(result.getErrorOrNull(), ServerErrorMessages.connectionError);
    });

    test('deve conectar de verdade com a API do Banco Central', () async {
      final realRepository = SgsRepository(DioNetworkAdapter(Dio()));

      final result = await realRepository.getSeries(
        index: CorrectionIndex.ipca,
        start: DateTime(2024, 1, 1),
        end: DateTime(2024, 2, 29),
      );

      expect(result.isSuccess, isTrue, reason: 'A API do BCB deve responder com sucesso.');
      final points = result.getOrNull();
      expect(points, isNotNull);
      expect(points, isNotEmpty);
      expect(points!.any((point) => point.date.year == 2024), isTrue);
      expect(points.first.value, isA<double>());
    });
  });
}
