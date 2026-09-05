import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/core/seed_works/error.dart';
import 'package:real_calc/core/seed_works/network.dart';
import 'package:real_calc/core/seed_works/result.dart';
import 'package:real_calc/modules/metrics/infrastructure/repositories/selic_repository.dart';
import 'package:real_calc/shared/network/response/selic_bc_response_network.dart';

class MockNetwork extends Mock implements Network {}

void main() {
  late MockNetwork network;
  late SelicRepository repository;

  setUp(() {
    network = MockNetwork();
    repository = SelicRepository(network);
  });

  group('getSelicRate', () {
    test('converte o payload da API em responses tipados', () async {
      when(() => network.get<List<dynamic>>(any())).thenAnswer(
        (_) async => SuccessResult<ErrorMessages, List<dynamic>>([
          {'data': '01/01/2026', 'valor': '10.50'},
          {'data': '02/01/2026', 'valor': '10.75'},
        ]),
      );

      final result = await repository.getSelicRate();

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull(), [
        const SelicBcResponseNetwork(data: '01/01/2026', valor: '10.50'),
        const SelicBcResponseNetwork(data: '02/01/2026', valor: '10.75'),
      ]);
      verify(() => network.get<List<dynamic>>(any())).called(1);
    });

    test('propaga o ErrorMessages retornado pela rede', () async {
      when(() => network.get<List<dynamic>>(any())).thenAnswer(
        (_) async => FailureResult<ErrorMessages, List<dynamic>>(
          ServerErrorMessages.connectionError,
        ),
      );

      final result = await repository.getSelicRate();

      expect(result.isError, isTrue);
      expect(result.getErrorOrNull(), ServerErrorMessages.connectionError);
    });
  });
}
