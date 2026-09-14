import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_calc/modules/financial_calculators/domain/enum/financial_calculation_target.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/financing/financing_cubit.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/forms/financing_form_state.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/future_value/future_value_cubit.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/regular_deposits/regular_deposits_cubit.dart';
import 'package:real_calc/modules/home/presentation/cubit/selic_cubit.dart';
import 'package:real_calc/modules/metrics/domain/entites/metric.dart';

import 'test_app_module.dart';
import 'mock_cubits.dart';

class TestHarness {
  final financingCubit = MockFinancingCubit();
  final futureValueCubit = MockFutureValueCubit();
  final selicCubit = MockSelicCubit();
  final greetingCubit = MockGreetingCubit();
  final financingFormCubit = MockFinancingFormCubit();
  final regularDepositsCubit = MockRegularDepositsCubit();

  late final Map<FinancialCalculationTarget, TextEditingController>
  formControllers;

  void setUpDefaults() {
    formControllers = {
      for (final target in FinancialCalculationTarget.values)
        target: TextEditingController(),
    };

    when(() => financingFormCubit.controllerFor(any())).thenAnswer(
      (invocation) =>
          formControllers[invocation.positionalArguments.first
              as FinancialCalculationTarget]!,
    );

    when(()=> regularDepositsCubit.state).thenReturn(RegularDepositsInitial());
    when(() => financingCubit.state).thenReturn(FinancingInitial());
    when(() => futureValueCubit.state).thenReturn(FutureValueInitial());
    when(
      () => financingFormCubit.state,
    ).thenReturn(FinancingFormState.initial());

    whenListen(
      selicCubit,
      const Stream<SelicState>.empty(),
      initialState: SelicLoaded(
        Metric(
          anualRate: 10.75,
          variationPercent: 0.25,
          sparklineData: const [10.5, 10.6, 10.75],
        ),
      ),
    );
    when(() => selicCubit.load()).thenAnswer((_) async {});

    whenListen(
      greetingCubit,
      const Stream<String>.empty(),
      initialState: 'Bom dia',
    );
  }

  /// Descarta os controllers criados para não vazar entre testes.
  void dispose() {
    for (final controller in formControllers.values) {
      controller.dispose();
    }
  }

  AppModuleTest buildModule() => AppModuleTest(
    financingCubit: financingCubit,
    futureValueCubit: futureValueCubit,
    selicCubit: selicCubit,
    greetingCubit: greetingCubit,
    financingFormCubit: financingFormCubit,
  );
}
