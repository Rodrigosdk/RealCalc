import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/modules/financial_calculators/module.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/financing/financing_cubit.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/future_value/future_value_cubit.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/regular_deposits/regular_deposits_cubit.dart';
import 'package:real_calc/modules/financial_calculators/use_case/financing/i_calculate_financing.dart';
import 'package:real_calc/modules/financial_calculators/use_case/future_value/i_calculate_future_value.dart';
import 'package:real_calc/modules/financial_calculators/use_case/regular_deposits/i_calculate_deposit.dart';

void main() {
  group('FinancialCalculatorsModule', () {
    setUp(() {
      Modular.init(FinancialCalculatorsModule());
    });

    tearDown(() {
      Modular.destroy();
    });

    test('deve inicializar o módulo com sucesso', () {
      expect(Modular.to, isNotNull);
    });

    test('deve resolver o caso de uso de financiamento', () {
      final useCase = Modular.get<ICalculateFinancing>();

      expect(useCase, isA<ICalculateFinancing>());
    });

    test('deve resolver o caso de uso de valor futuro', () {
      final useCase = Modular.get<ICalculateFutureValue>();

      expect(useCase, isA<ICalculateFutureValue>());
    });

    test('deve resolver o caso de uso de depósitos regulares', () {
      final useCase = Modular.get<ICalculateDeposit>();

      expect(useCase, isA<ICalculateDeposit>());
    });

    test('deve resolver o FinancingCubit e suas dependências', () {
      final cubit = Modular.get<FinancingCubit>();

      expect(cubit, isA<FinancingCubit>());
      expect(cubit.useCase, isA<ICalculateFinancing>());
    });

    test('deve resolver o FutureValueCubit e suas dependências', () {
      final cubit = Modular.get<FutureValueCubit>();

      expect(cubit, isA<FutureValueCubit>());
      expect(cubit.useCase, isA<ICalculateFutureValue>());
    });

    test('deve resolver o RegularDepositsCubit e suas dependências', () {
      final cubit = Modular.get<RegularDepositsCubit>();

      expect(cubit, isA<RegularDepositsCubit>());
      expect(cubit.useCase, isA<ICalculateDeposit>());
    });
  });
}