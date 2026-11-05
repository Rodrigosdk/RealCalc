import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/themes/app_theme.dart';
import 'package:real_calc/modules/financial_calculators/domain/enum/financial_calculation_target.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/financing/financing_cubit.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/forms/financing_form_cubit.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/future_value/future_value_cubit.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/regular_deposits/regular_deposits_cubit.dart';
import 'package:real_calc/modules/financial_calculators/presentation/pages/financing_page.dart';
import 'package:real_calc/modules/financial_calculators/presentation/pages/future_value_page.dart';
import 'package:real_calc/modules/financial_calculators/presentation/pages/regular_deposits_page.dart';
import 'package:real_calc/modules/financial_calculators/use_case/financing/calculate_financing.dart';
import 'package:real_calc/modules/financial_calculators/use_case/future_value/calculate_future_value.dart';
import 'package:real_calc/modules/financial_calculators/use_case/regular_deposits/calculate_deposit.dart';

const _maxMoney = '99999999999999';
const _minMoney = '1';
const _maxMonths = '9999';
const _maxRate = '99999';

typedef _Inputs = Map<FinancialCalculationTarget, String>;

void main() {
  Future<void> calculate<C extends BlocBase<Object?>>(
    WidgetTester tester, {
    required C calculator,
    required Widget page,
    required _Inputs inputs,
  }) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final form = FinancingFormCubit();
    addTearDown(form.close);
    addTearDown(calculator.close);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: MultiBlocProvider(
          providers: [
            BlocProvider<C>.value(value: calculator),
            BlocProvider.value(value: form),
          ],
          child: page,
        ),
      ),
    );

    for (final MapEntry(key: field, value: text) in inputs.entries) {
      await tester.enterText(
        find.descendant(
          of: find.byKey(ValueKey(field)),
          matching: find.byType(TextField),
        ),
        text,
      );
      await tester.pump();
    }
    await tester.tap(find.text('Calcular'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Calcular'),
      0,
      scrollable: find.byType(Scrollable).first,
    );

    expect(tester.takeException(), isNull);
  }

  _Inputs without(FinancialCalculationTarget unknown, _Inputs all) => {
    for (final entry in all.entries)
      if (entry.key != unknown) entry.key: entry.value,
  };

  const maxed = {
    FinancialCalculationTarget.initialValue: _maxMoney,
    FinancialCalculationTarget.periods: _maxMonths,
    FinancialCalculationTarget.interestRate: _maxRate,
    FinancialCalculationTarget.finalValue: _maxMoney,
  };
  const tinyMoney = {
    FinancialCalculationTarget.initialValue: _minMoney,
    FinancialCalculationTarget.periods: '1',
    FinancialCalculationTarget.interestRate: _maxRate,
    FinancialCalculationTarget.finalValue: _minMoney,
  };

  final calculators = <String, Future<void> Function(WidgetTester, _Inputs)>{
    'Financiamento': (tester, inputs) => calculate(
      tester,
      calculator: FinancingCubit(CalculateFinancing()),
      page: const FinancingPage(),
      inputs: inputs,
    ),
    'Depósitos Regulares': (tester, inputs) => calculate(
      tester,
      calculator: RegularDepositsCubit(CalculateDeposit()),
      page: const RegularDepositsPage(),
      inputs: inputs,
    ),
    'Valor Futuro': (tester, inputs) => calculate(
      tester,
      calculator: FutureValueCubit(CalculateFutureValue()),
      page: const FutureValuePage(),
      inputs: inputs,
    ),
  };

  for (final MapEntry(key: name, value: run) in calculators.entries) {
    group('$name com valores extremos em 360dp e fonte em 130%', () {
      for (final unknown in FinancialCalculationTarget.values) {
        testWidgets('${unknown.name} com os outros campos no máximo', (
          tester,
        ) async {
          await run(tester, without(unknown, maxed));
        });

        testWidgets('${unknown.name} com R\$ 0,01 e taxa de 999,99%', (
          tester,
        ) async {
          await run(tester, without(unknown, tinyMoney));
        });
      }
    });
  }
}
