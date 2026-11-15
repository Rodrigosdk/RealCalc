import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/errors/failures.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/core/seed_works/error.dart';
import 'package:real_calc/core/seed_works/result.dart';
import 'package:real_calc/modules/financial_calculators/domain/entities/financial_calculation.dart';
import 'package:real_calc/modules/financial_calculators/domain/enum/financial_calculation_target.dart';
import 'package:real_calc/modules/financial_calculators/use_case/financing/calculate_financing.dart';
import 'package:real_calc/modules/financial_calculators/use_case/future_value/calculate_future_value.dart';
import 'package:real_calc/modules/financial_calculators/use_case/regular_deposits/calculate_deposit.dart';

typedef _Calculate =
    Result<Failure, FinancialCalculation> Function(FinancialCalculation);

double _shown(double value) => (value * 100).round() / 100;

FinancialCalculation _asShown(FinancialCalculation value) =>
    FinancialCalculation(
      initialValue: _shown(value.initialValue),
      rate: _shown(value.rate),
      periods: value.periods,
      finalValue: _shown(value.finalValue),
    );

FinancialCalculation _without(
  FinancialCalculation value,
  FinancialCalculationTarget field,
) => FinancialCalculation(
  initialValue: field == FinancialCalculationTarget.initialValue
      ? 0
      : value.initialValue,
  rate: field == FinancialCalculationTarget.interestRate ? 0 : value.rate,
  periods: field == FinancialCalculationTarget.periods ? 0 : value.periods,
  finalValue: value.finalValue,
);

bool _expectedError(ErrorMessages error) =>
    error is AmbiguousPeriodsError ||
    error is PaymentBelowInterestError ||
    error == FinancingValidationMessage.noPositiveRate ||
    error == FinancingValidationMessage.paymentAboveDebt ||
    error == RegularDepositsValidationMessage.noPositiveRate ||
    error == RegularDepositsValidationMessage.finalBelowFirstMonth ||
    error == FutureValueValidationMessage.finalNotAboveInitial ||
    error == FinancialCalculationValidationMessage.resultTooSmall ||
    error == FinancialCalculationValidationMessage.resultOutOfRange ||
    error == FinancialCalculationValidationMessage.invalidParameterCount;

void main() {
  final calculators = <String, _Calculate>{
    'Financiamento': CalculateFinancing().calculate,
    'Depósitos Regulares': CalculateDeposit().calculate,
    'Valor Futuro': CalculateFutureValue().calculate,
  };
  const values = [10.0, 1000.0, 250000.0, 1e9];
  const rates = [0.01, 0.5, 1.0, 2.0, 10.0, 100.0, 999.99];
  const periods = [1, 12, 70, 360, 1200, 9999];
  const unknowns = [
    FinancialCalculationTarget.initialValue,
    FinancialCalculationTarget.periods,
    FinancialCalculationTarget.interestRate,
  ];

  bool realistic(double value, double rate, int months) =>
      value >= 1000 && rate <= 2 && months <= 360;

  for (final MapEntry(key: name, value: calculate) in calculators.entries) {
    test('$name: recalcular um campo a partir dos valores mostrados '
        'reproduz a tela ou explica por que não dá', () {
      for (final value in values) {
        for (final rate in rates) {
          for (final months in periods) {
            final first = calculate(
              FinancialCalculation(
                initialValue: value,
                rate: rate,
                periods: months,
              ),
            ).getOrNull();
            if (first == null) continue;
            final shown = _asShown(first);

            for (final unknown in unknowns) {
              final context = '$value, $rate%, $months meses, ${unknown.name}';
              calculate(_without(shown, unknown)).fold(
                (failure) {
                  final error = failure.message.single;
                  expect(_expectedError(error), isTrue, reason: context);
                  expect(
                    realistic(value, rate, months),
                    isFalse,
                    reason: '$context: ${error.message}',
                  );
                },
                (result) {
                  final again = calculate(
                    FinancialCalculation(
                      initialValue: _shown(result.initialValue),
                      rate: _shown(result.rate),
                      periods: result.periods,
                    ),
                  ).getOrNull();
                  expect(again, isNotNull, reason: context);
                  expect(
                    _shown(again!.finalValue),
                    closeTo(shown.finalValue, 0.011 + shown.finalValue * 1e-4),
                    reason: context,
                  );
                },
              );
            }
          }
        }
      }
    });
  }
}
