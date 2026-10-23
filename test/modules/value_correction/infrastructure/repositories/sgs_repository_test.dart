import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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
    test(
      'deve montar a URL e converter payload válido em SeriesPoint',
      () async {
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
          () =>
              network.get<List<dynamic>>(any(that: contains('bcdata.sgs.433'))),
        ).called(1);
      },
    );

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

    test('preserva dataFim nas observações da série TR', () async {
      when(() => network.get<List<dynamic>>(any())).thenAnswer(
        (_) async => SuccessResult<ErrorMessages, List<dynamic>>([
          {'data': '01/10/2025', 'dataFim': '31/10/2025', 'valor': '0.1738'},
          {'data': '01/10/2025', 'dataFim': '01/11/2025', 'valor': '0.1758'},
        ]),
      );

      final result = await repository.getSeries(
        index: CorrectionIndex.tr,
        start: DateTime(2025, 10, 1),
        end: DateTime(2025, 11, 1),
      );

      expect(result.getOrNull(), [
        SeriesPoint(
          date: DateTime(2025, 10, 1),
          value: 0.1738,
          periodEnd: DateTime(2025, 10, 31),
        ),
        SeriesPoint(
          date: DateTime(2025, 10, 1),
          value: 0.1758,
          periodEnd: DateTime(2025, 11, 1),
        ),
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

    test(
      'nova tentativa consulta a rede novamente após falha de conexão',
      () async {
        var requestCount = 0;
        when(() => network.get<List<dynamic>>(any())).thenAnswer((_) async {
          requestCount++;
          if (requestCount == 1) {
            return FailureResult<ErrorMessages, List<dynamic>>(
              ServerErrorMessages.connectionError,
            );
          }
          return SuccessResult<ErrorMessages, List<dynamic>>([
            {'data': '01/01/2023', 'valor': '0.53'},
          ]);
        });

        final firstAttempt = await repository.getSeries(
          index: CorrectionIndex.ipca,
          start: DateTime(2023, 1, 1),
          end: DateTime(2023, 1, 1),
        );
        final retry = await repository.getSeries(
          index: CorrectionIndex.ipca,
          start: DateTime(2023, 1, 1),
          end: DateTime(2023, 1, 1),
        );

        expect(firstAttempt.isError, isTrue);
        expect(retry.isSuccess, isTrue);
        expect(requestCount, 2);
      },
    );

    test(
      'deve dividir série diária em janelas de 10 anos sem duplicar a fronteira',
      () async {
        when(() => network.get<List<dynamic>>(any())).thenAnswer((
          invocation,
        ) async {
          final url = invocation.positionalArguments.first as String;

          if (url.contains('dataInicial=01/01/2014&dataFinal=01/01/2024')) {
            return SuccessResult<ErrorMessages, List<dynamic>>([
              {'data': '01/01/2014', 'valor': '1.40'},
              {'data': '01/01/2024', 'valor': '2.40'},
            ]);
          }

          if (url.contains('dataInicial=02/01/2024') && url.contains('2034')) {
            return SuccessResult<ErrorMessages, List<dynamic>>([
              {'data': '02/01/2024', 'valor': '3.40'},
              {'data': '02/01/2034', 'valor': '4.40'},
            ]);
          }

          if (url.contains('dataInicial=03/01/2034') && url.contains('2035')) {
            return SuccessResult<ErrorMessages, List<dynamic>>([
              {'data': '03/01/2034', 'valor': '5.40'},
              {'data': '15/01/2035', 'valor': '6.40'},
            ]);
          }

          return SuccessResult<ErrorMessages, List<dynamic>>([]);
        });

        final result = await repository.getSeries(
          index: CorrectionIndex.selic,
          start: DateTime(2014, 1, 1),
          end: DateTime(2035, 1, 15),
        );

        expect(result.isSuccess, isTrue);
        expect(result.getOrNull(), [
          SeriesPoint(date: DateTime(2014, 1, 1), value: 1.40),
          SeriesPoint(date: DateTime(2024, 1, 1), value: 2.40),
          SeriesPoint(date: DateTime(2024, 1, 2), value: 3.40),
          SeriesPoint(date: DateTime(2034, 1, 2), value: 4.40),
          SeriesPoint(date: DateTime(2034, 1, 3), value: 5.40),
          SeriesPoint(date: DateTime(2035, 1, 15), value: 6.40),
        ]);
        verify(() => network.get<List<dynamic>>(any())).called(3);
      },
    );

    test('deve reaproveitar resultado em cache para a mesma janela', () async {
      when(() => network.get<List<dynamic>>(any())).thenAnswer(
        (_) async => SuccessResult<ErrorMessages, List<dynamic>>([
          {'data': '01/01/2014', 'valor': '1.00'},
          {'data': '01/01/2024', 'valor': '2.00'},
        ]),
      );

      final first = await repository.getSeries(
        index: CorrectionIndex.selic,
        start: DateTime(2014, 1, 1),
        end: DateTime(2024, 1, 1),
      );
      final second = await repository.getSeries(
        index: CorrectionIndex.selic,
        start: DateTime(2014, 1, 1),
        end: DateTime(2024, 1, 1),
      );

      expect(first.isSuccess, isTrue);
      expect(second.isSuccess, isTrue);
      verify(() => network.get<List<dynamic>>(any())).called(1);
    });

    test(
      'deve retornar erro quando a série termina antes do mês final solicitado',
      () async {
        when(() => network.get<List<dynamic>>(any())).thenAnswer(
          (_) async => SuccessResult<ErrorMessages, List<dynamic>>([
            {'data': '15/02/2025', 'valor': '1.10'},
          ]),
        );

        final result = await repository.getSeries(
          index: CorrectionIndex.selic,
          start: DateTime(2025, 1, 1),
          end: DateTime(2025, 3, 31),
        );

        expect(result.isError, isTrue);
        expect(result.getErrorOrNull()!.message, contains('02/2025'));
      },
    );

    test('deve falhar o conjunto quando uma janela falha', () async {
      when(() => network.get<List<dynamic>>(any())).thenAnswer((
        invocation,
      ) async {
        final url = invocation.positionalArguments.first as String;

        if (url.contains('dataInicial=01/01/2014&dataFinal=01/01/2024')) {
          return SuccessResult<ErrorMessages, List<dynamic>>([
            {'data': '01/01/2014', 'valor': '1.20'},
          ]);
        }

        if (url.contains('dataInicial=02/01/2024') && url.contains('2034')) {
          return FailureResult<ErrorMessages, List<dynamic>>(
            ServerErrorMessages.connectionError,
          );
        }

        return SuccessResult<ErrorMessages, List<dynamic>>([]);
      });

      final result = await repository.getSeries(
        index: CorrectionIndex.selic,
        start: DateTime(2014, 1, 1),
        end: DateTime(2035, 1, 15),
      );

      expect(result.isError, isTrue);
      expect(result.getErrorOrNull(), ServerErrorMessages.connectionError);
    });
  });
}
