import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/modules/financing/domain/usecases/calculate_compound_interest_use_case.dart';
import 'package:real_calc/modules/financing/domain/validation/financing_validator.dart';
import 'package:real_calc/modules/financing/module.dart';
import 'package:real_calc/modules/financing/presentation/cubit/financing_cubit.dart';

void main() {
  group('FinancingModule', () {
    
    setUp(() {
      Modular.init(FinancingModule());
    });

    tearDown(() {
      Modular.destroy();
    });

    test('Deve conseguir recuperar o FinancingValidator com sucesso do módulo', () {
      final validator = Modular.get<FinancingValidator>();
      expect(validator, isA<FinancingValidator>());
    });

    test('Deve conseguir recuperar o CalculateCompoundInterestUseCase com sucesso do módulo', () {
      final useCase = Modular.get<CalculateCompoundInterestUseCase>();
      expect(useCase, isA<CalculateCompoundInterestUseCase>());
    });

    test('Deve conseguir recuperar o FinancingCubit e garantir a resolução da árvore de dependências', () {
      final cubit = Modular.get<FinancingCubit>();
      expect(cubit, isA<FinancingCubit>());
    });
  });
}
