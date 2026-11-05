import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/modules/financial_calculators/domain/entities/financial_calculation.dart';
import 'package:real_calc/modules/financial_calculators/domain/validation/calculation_limits.dart';

void main() {
  FinancialCalculation calc({
    double initialValue = 1000,
    double rate = 1,
    double finalValue = 1126.83,
  }) => FinancialCalculation(
    initialValue: initialValue,
    rate: rate,
    periods: 12,
    finalValue: finalValue,
  );

  void expectOutOfRange(FinancialCalculation value) {
    expect(
      ensureWithinLimits(value).getErrorOrNull()!.message.single,
      FinancialCalculationValidationMessage.resultOutOfRange,
    );
  }

  group('ensureWithinLimits', () {
    test('resultado finito e até R\$ 1 trilhão passa', () {
      final value = calc(finalValue: maxCalculatedMoney);
      expect(ensureWithinLimits(value).getOrNull(), same(value));
    });

    test('valor acima de R\$ 1 trilhão falha', () {
      expectOutOfRange(calc(finalValue: maxCalculatedMoney + 1));
      expectOutOfRange(calc(initialValue: 2e12));
    });

    test('infinito ou NaN falha', () {
      expectOutOfRange(calc(finalValue: double.infinity));
      expectOutOfRange(calc(initialValue: double.nan));
      expectOutOfRange(calc(rate: double.nan));
    });
  });
}
