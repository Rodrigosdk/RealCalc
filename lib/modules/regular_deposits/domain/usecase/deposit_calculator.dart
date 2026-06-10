import 'dart:math';

import 'package:real_calc/core/errors/failures.dart';
import 'package:real_calc/core/seed_works/result.dart';

import '../entities/regular_deposit.dart';

class DepositCalculatorUseCase {
  static Result<Failure, double> calculateFinalValue(RegularDeposit params) {
    late double result;

    double r = params.rate / 100;

    if (r == 0) {
      result = params.depositAmount * params.months;

      return SuccessResult<Failure, double>(result);
    }
    result =
        params.depositAmount * ((pow(1 + r, params.months) - 1) / r) * (1 + r);

    return SuccessResult<Failure, double>(result);
  }

  static Result<Failure, double> calculateDepositAmount(RegularDeposit params) {
    double r = params.rate / 100;

    if (r == 0) {
      return SuccessResult<Failure, double>(params.finalValue / params.months);
    }

    double result = params.finalValue / (((pow(1 + r, params.months) - 1) / r) * (1 + r));

    return SuccessResult<Failure, double>(result);
  }

  static Result<Failure, int> calculateNumberOfMonths(RegularDeposit params) {
    late int result;
    double r = params.rate / 100;

    if (r == 0) {
      result = (params.finalValue / params.depositAmount).round();
      return SuccessResult(result);
    }

    double fvAjustado = params.finalValue / (1 + r);
    
    result = (log((fvAjustado * r / params.depositAmount) + 1) / log(1 + r)).round();

    return SuccessResult(result);
  }

  static Result<Failure, double> calculateInterestRate(RegularDeposit params) {
    double pmt = params.depositAmount;
    int n = params.months;
    double fv = params.finalValue;

    if (fv <= pmt * n) {
      return SuccessResult(0.0);
    }

    double r = 0.1; 
    double precision = 1e-7;
    int maxInteractions = 100;

    for (int i = 0; i < maxInteractions; i++) {
      double termo1 = pow(1 + r, n).toDouble();
      double termo2 = pow(1 + r, n - 1).toDouble();
      
      double f = pmt * ((termo1 - 1) / r) * (1 + r) - fv;

      double df = pmt * (
        ((n * termo2 * r - termo1 + 1) / (r * r)) * (1 + r) + 
        ((termo1 - 1) / r)
      );

      double novoR = r - f / df;

      if ((novoR - r).abs() < precision) {
        return SuccessResult(novoR * 100); 
      }
      r = novoR;
    }
    
    return SuccessResult(r * 100);
  }
}
