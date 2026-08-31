import 'dart:math';

import 'package:real_calc/core/errors/failures.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/core/seed_works/result.dart';
import 'package:real_calc/modules/future_value/domain/entities/future_value.dart';
import '../validation/future_value_validator.dart';
import '../enum/future_value_type.dart';

class CalculateCompoundInterestUseCase {
  final FutureValueValidator validator;

  CalculateCompoundInterestUseCase(this.validator);

  // Cálculo do Valor Futuro (Sₙ)
  Result<Failure, double> calculateFinalValue(FutureValue params) {
    return validator.validateForFinalValue(params).map((futureValue) {
      final realRate = (futureValue.interestRate ?? 0) / 100;
      return (futureValue.capital ?? 0) *
          pow(1 + realRate, (futureValue.months ?? 0).toDouble());
    });
  }

  // Cálculo da Taxa de Juros (j)
  Result<Failure, double> calculateRate(FutureValue params) {
    return validator.validateForInterestRate(params).map((futureValue) {
      return (pow(
                (futureValue.finalValue ?? 0) / (futureValue.capital ?? 0),
                1.0 / (futureValue.months ?? 0).toDouble(),
              ) -
              1) *
          100;
    });
  }

  // Cálculo do Número de Meses (n)
  Result<Failure, int> calculateMonths(FutureValue params) {
    return validator.validateForMonths(params).map((futureValue) {
      final realRate = (futureValue.interestRate ?? 0) / 100;
      return (log((futureValue.finalValue ?? 0) / (futureValue.capital ?? 0)) /
              log(1 + realRate))
          .round();
    });
  }

  // Cálculo do Valor Inicial (q₀)
  Result<Failure, double> calculateInitialValue(FutureValue params) {
    return validator.validateForCapital(params).map((futureValue) {
      final realRate = (futureValue.interestRate ?? 0) / 100;
      return (futureValue.finalValue ?? 0) /
          pow(1 + realRate, (futureValue.months ?? 0).toDouble());
    });
  }

  // Método genérico que detecta o tipo de cálculo automaticamente
  Result<Failure, double> calculate(FutureValue params) {
    return validator.detectTypeCalculation(params).fold(
      (error) => FailureResult<Failure, double>(error),
      (calculationType) {
        return switch (calculationType) {
          FutureValueType.finalValue => calculateFinalValue(params),
          FutureValueType.interestRate => calculateRate(params),
          FutureValueType.months => calculateMonths(params).map((value) => value.toDouble()),
          FutureValueType.capital => calculateInitialValue(params),
        };
      },
    );
  }

  // Método específico para calcular apenas o Valor Futuro (mantendo o padrão)
  Result<Failure, double> calculateFutureValue({
    required double capital,
    required double interestRate,
    required int months,
  }) {
    try {
      final realRate = interestRate / 100;
      final futureValue = capital * pow(1 + realRate, months.toDouble());
      return SuccessResult(futureValue);
    } catch (e) {
      return FailureResult<Failure, double>(
        UnexpectedFailure(message: [UnexpectedErrorMessages.defaultError]),
      );
    }
  }
}