import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:real_calc/modules/financial_calculators/domain/enum/financial_calculation_target.dart';

import 'fake_financing.dart';



Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  registerFallbackValue(FinancialCalculationTarget.initialValue);
  registerFallbackValue(FakeFinancing());
  registerFallbackValue(FakeFinancialCalculation());

  await testMain();
}