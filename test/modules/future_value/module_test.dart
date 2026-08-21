import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/modules/future_value/domain/usecase/calculate_compound_interest_use_case.dart';
import 'package:real_calc/modules/future_value/domain/validation/future_value_validator.dart';
import 'package:real_calc/modules/future_value/module.dart';
import 'package:real_calc/modules/future_value/presentation/cubit/future_value_cubit.dart';

void main() {
  group('FutureValueModule', () {
    setUp(() {
      Modular.init(FutureValueModule());
    });

    tearDown(() {
      Modular.destroy();
    });

    test('Deve conseguir recuperar o FutureValueValidator com sucesso do módulo', () {
      final validator = Modular.get<FutureValueValidator>();
      expect(validator, isA<FutureValueValidator>());
    });

    test('Deve conseguir recuperar o CalculateCompoundInterestUseCase com sucesso do módulo', () {
      final useCase = Modular.get<CalculateCompoundInterestUseCase>();
      expect(useCase, isA<CalculateCompoundInterestUseCase>());
    });

    test('Deve conseguir recuperar o FutureValueCubit e garantir a resolução da árvore de dependências', () {
      final cubit = Modular.get<FutureValueCubit>();
      expect(cubit, isA<FutureValueCubit>());
    });
  });
}
