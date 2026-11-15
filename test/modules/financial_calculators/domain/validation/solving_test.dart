import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/modules/financial_calculators/domain/validation/solving.dart';

void main() {
  group('solveIncreasing', () {
    test('acha a raiz de uma função crescente', () {
      expect(solveIncreasing((x) => x * x - 2, 0, 2), closeTo(sqrt2, 1e-12));
    });
  });

  group('periodsFromMoney', () {
    test('devolve o prazo mais próximo quando ele é finito', () {
      final result = periodsFromMoney(
        value: 100,
        periodsFor: (value) => value / 10 + 0.3,
      );

      expect(result.getOrNull(), 10);
    });

    test('prazo infinito dentro do arredondamento é ambíguo', () {
      final result = periodsFromMoney(
        value: 100,
        periodsFor: (value) =>
            value <= 100 ? double.infinity : 1 / (value - 100) + 0.5,
      );

      final error = result.getErrorOrNull()!.message.single;
      expect(error, isA<AmbiguousPeriodsError>());
      expect((error as AmbiguousPeriodsError).from, 201);
    });
  });
}
