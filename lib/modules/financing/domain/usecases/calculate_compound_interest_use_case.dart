import 'dart:math';

import '../entities/financing.dart';

class CalculateCompoundInterestUseCase {
  double calculateFinalValue(Financing params) {
    _validate(params, checkInitial: true, checkRate: true, checkMonths: true);
    final realRate = params.rate / 100;

    return params.initialValue * pow(1 + realRate, params.months.toDouble());
  }

  double calculateRate(Financing params) {
    _validate(params, checkInitial: true, checkFinal: true, checkMonths: true);

    return (pow(params.finalValue / params.initialValue, 1.0 / params.months.toDouble()) - 1) * 100;
  }

  int calculateMonths(Financing params) {
    _validate(params, checkInitial: true, checkFinal: true, checkRate: true);

    final realRate = params.rate / 100;
    return (log(params.finalValue / params.initialValue) / log(1 + realRate))
        .ceil()
        .toInt();
  }

  double calculateInitialValue(Financing params) {
    _validate(params, checkFinal: true, checkRate: true, checkMonths: true);

    final realRate = params.rate / 100;

    return params.finalValue / pow(1 + realRate, params.months.toDouble());
  }

  void _validate(
    Financing params, {
    bool checkInitial = false,
    bool checkFinal = false,
    bool checkRate = false,
    bool checkMonths = false,
  }) {
    final errors = <String>[];

    if (checkInitial && params.initialValue <= 0) {
      errors.add('O valor inicial deve ser maior que zero');
    }
    if (checkFinal && params.finalValue <= 0) {
      errors.add('O valor final deve ser maior que zero');
    }
    if (checkRate && params.rate <= 0) {
      errors.add('O valor da taxa deve ser maior que zero');
    }
    if (checkMonths && params.months <= 0) {
      errors.add('A quantidade de meses deve ser maior que zero');
    }

    if (errors.isNotEmpty) {
      throw ArgumentError(errors.join('; '));
    }
  }
}
