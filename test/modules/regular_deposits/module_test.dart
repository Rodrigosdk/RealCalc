import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/modules/regular_deposits/domain/usecase/deposit_calculator.dart';
import 'package:real_calc/modules/regular_deposits/domain/validation/regular_deposits_validator.dart';
import 'package:real_calc/modules/regular_deposits/module.dart';
import 'package:real_calc/modules/regular_deposits/presentation/cubit/regular_deposits_cubit.dart';

void main() {
  group('RegularDepositsModule', () {
    setUp(() {
      Modular.init(RegularDepositsModule());
    });

    tearDown(() {
      Modular.destroy();
    });

    test('Deve conseguir recuperar o RegularDepositsValidator com sucesso do módulo', () {
      final validator = Modular.get<RegularDepositsValidator>();
      expect(validator, isA<RegularDepositsValidator>());
    });

    test('Deve conseguir recuperar o DepositCalculatorUseCase com sucesso do módulo', () {
      final useCase = Modular.get<DepositCalculatorUseCase>();
      expect(useCase, isA<DepositCalculatorUseCase>());
    });

    test('Deve conseguir recuperar o RegularDepositsCubit e garantir a resolução da árvore de dependências', () {
      final cubit = Modular.get<RegularDepositsCubit>();
      expect(cubit, isA<RegularDepositsCubit>());
    });
  });
}
