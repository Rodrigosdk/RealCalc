import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/core/seed_works/error.dart';
import 'package:real_calc/core/seed_works/result.dart';
import 'package:real_calc/modules/metrics/domain/entites/metric.dart';
import 'package:real_calc/modules/metrics/domain/repositories/selic/i_selic_network_only_repository.dart';
import 'package:real_calc/modules/metrics/use_cases/selic/selic_use_case.dart';
import 'package:real_calc/modules/metrics/use_cases/selic/selic_validation.dart';
import 'package:real_calc/shared/network/response/selic_bc_response_network.dart';

class MockSelicRepository extends Mock
    implements ISelicNetworkOnlyRepository {}

void main() {
  late MockSelicRepository repository;
  late SelicUseCase useCase;

  setUp(() {
    repository = MockSelicRepository();
    useCase = SelicUseCase(repository, SelicValidation());
  });

  test('mapeia os dados do repository para Metric', () async {
    when(() => repository.getSelicRate()).thenAnswer(
      (_) async => SuccessResult<ErrorMessages, List<SelicBcResponseNetwork>>([
        const SelicBcResponseNetwork(valor: '10.00'),
        const SelicBcResponseNetwork(valor: '10.50'),
      ]),
    );

    final result = await useCase.getSelicRate();

    final metric = result.getOrNull();
    expect(metric, isA<Metric>());
    expect(metric!.anualRate, 10.5);
    expect(metric.variationPercent, closeTo(0.5, 0.0001));
    expect(metric.sparklineData, [10.0, 10.5]);
  });

  test('não consulta o repository quando o período é inválido', () async {
    final result = await useCase.getSelicRateByPeriod(
      dataInicial: DateTime(2026, 1, 1),
      dataFinal: DateTime(2036, 1, 2),
    );

    expect(result.getErrorOrNull(), SelicValidationMessage.periodExceedsLimit);
    verifyNever(
      () => repository.getSelicRateByPeriod(
        dataInicial: any(named: 'dataInicial'),
        dataFinal: any(named: 'dataFinal'),
      ),
    );
  });

  test('consulta o repository quando o período é válido', () async {
    when(
      () => repository.getSelicRateByPeriod(
        dataInicial: DateTime(2025, 1, 1),
        dataFinal: DateTime(2026, 1, 1),
      ),
    ).thenAnswer(
      (_) async => SuccessResult<ErrorMessages, List<SelicBcResponseNetwork>>([
        const SelicBcResponseNetwork(valor: '12.00'),
      ]),
    );

    final result = await useCase.getSelicRateByPeriod(
      dataInicial: DateTime(2025, 1, 1),
      dataFinal: DateTime(2026, 1, 1),
    );

    expect(result.isSuccess, isTrue);
    verify(
      () => repository.getSelicRateByPeriod(
        dataInicial: DateTime(2025, 1, 1),
        dataFinal: DateTime(2026, 1, 1),
      ),
    ).called(1);
  });
}
