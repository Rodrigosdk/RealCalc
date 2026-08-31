import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/modules/future_value/domain/entities/future_value.dart';
import 'package:real_calc/modules/future_value/domain/validation/spec/future_value_spec.dart';

void main() {
  double randomNumber() {
    final random = Random();
    final value = random.nextDouble() * 10;
    return value > 0 ? value : 1;
  }

  FutureValue buildFutureValue({bool positive = true}) {
    return FutureValue(
      capital: positive ? randomNumber() : 0,
      finalValue: positive ? randomNumber() : 0,
      interestRate: positive ? randomNumber() : 0,
      months: positive ? (randomNumber().round()) : 0,
    );
  }

  group('PositiveCapitalSpecification', () {
    test('Deve validar se o capital é maior que zero', () {
      final specification = PositiveCapitalSpecification();
      final entity = buildFutureValue();

      final spec = specification.validate(entity);

      expect(spec.length, 0);
    });

    test('Caso o capital seja zero deve retornar mensagem de erro', () {
      final specification = PositiveCapitalSpecification();
      final entity = buildFutureValue(positive: false);

      final spec = specification.validate(entity);

      expect(spec.length, 1);
      expect(spec.last, FutureValueValidationMessage.positiveCapital);
    });
  });

  group('PositiveFinalValueSpecification', () {
    test('Deve validar se o valor final é maior que zero', () {
      final specification = PositiveFinalValueSpecification();
      final entity = buildFutureValue();

      final spec = specification.validate(entity);

      expect(spec.length, 0);
    });

    test('Caso o valor final seja zero deve retornar mensagem de erro', () {
      final specification = PositiveFinalValueSpecification();
      final entity = buildFutureValue(positive: false);

      final spec = specification.validate(entity);

      expect(spec.length, 1);
      expect(spec.last, FutureValueValidationMessage.positiveFinalValue);
    });
  });

  group('PositiveInterestRateSpecification', () {
    test('Deve validar se a taxa de juros é maior que zero', () {
      final specification = PositiveInterestRateSpecification();
      final entity = buildFutureValue();

      final spec = specification.validate(entity);

      expect(spec.length, 0);
    });

    test('Caso a taxa seja zero deve retornar mensagem de erro', () {
      final specification = PositiveInterestRateSpecification();
      final entity = buildFutureValue(positive: false);

      final spec = specification.validate(entity);

      expect(spec.length, 1);
      expect(spec.last, FutureValueValidationMessage.positiveInterestRate);
    });
  });

  group('PositiveMonthsSpecification', () {
    test('Deve validar se os meses são maiores que zero', () {
      final specification = PositiveMonthsSpecification();
      final entity = buildFutureValue();

      final spec = specification.validate(entity);

      expect(spec.length, 0);
    });

    test('Caso os meses sejam zero deve retornar mensagem de erro', () {
      final specification = PositiveMonthsSpecification();
      final entity = buildFutureValue(positive: false);

      final spec = specification.validate(entity);

      expect(spec.length, 1);
      expect(spec.last, FutureValueValidationMessage.positiveMonths);
    });
  });
}
