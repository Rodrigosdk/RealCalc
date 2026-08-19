import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/modules/regular_deposits/domain/entities/regular_deposit.dart';
import 'package:real_calc/modules/regular_deposits/domain/validation/spec/regular_deposits_spec.dart';

void main() {
  double randomNumber() {
    final random = Random();
    final value = random.nextDouble();
    return value > 0 ? 1 : value;
  }

  RegularDeposit buildRegularDeposit({bool positive = true}) {
    return RegularDeposit(
      rate: positive == true ? randomNumber() : 0,
      months: positive == true ? int.tryParse(randomNumber().toString()) ?? 1:0,
      finalValue: positive == true ? randomNumber() : 0,
      depositAmount: positive == true ? randomNumber() : 0,
    );
  }

  group("PositiveMonthsValueSpecification", () {
    test("Deve validar se o valor do mês é maior que zero", () {
      final specification = PositiveMonthsValueSpecification();
      final regularDeposit = buildRegularDeposit();

      final spec = specification.validate(regularDeposit);

      expect(spec.length, 0);
    });

    test("Caso o valor seja negativo deve retornar uma menssagem de erro", () {
      final specification = PositiveMonthsValueSpecification();
      final regularDeposit = buildRegularDeposit(positive: false);

      final spec = specification.validate(regularDeposit);

      expect(spec.length, 1);
      expect(spec.last, RegularDepositsValidationMessage.positiveMonths);
    });
  });

  group("PositiveFinalValueSpecification", () {
    test("Deve validar se o valor do final é maior que zero", () {
      final specification = PositiveFinalValueSpecification();
      final regularDeposit = buildRegularDeposit();

      final spec = specification.validate(regularDeposit);

      expect(spec.length, 0);
    });

    test("Caso o valor seja negativo deve retornar uma menssagem de erro", () {
      final specification = PositiveFinalValueSpecification();
      final regularDeposit = buildRegularDeposit(positive: false);

      final spec = specification.validate(regularDeposit);

      expect(spec.length, 1);
      expect(spec.last, RegularDepositsValidationMessage.positiveFinalValue);
    });
  });
  group("PositiveDepositValueSpecification", () {
    test("Deve validar se o valor do deposito é maior que zero", () {
      final specification = PositiveDepositValueSpecification();
      final regularDeposit = buildRegularDeposit();

      final spec = specification.validate(regularDeposit);

      expect(spec.length, 0);
    });

    test("Deve retornar uma menssagem de erro caso o valor seja negativo", () {
      final specification = PositiveDepositValueSpecification();
      final regularDeposit = buildRegularDeposit(positive: false);

      final spec = specification.validate(regularDeposit);

      expect(spec.length, 1);
      expect(spec.last, RegularDepositsValidationMessage.positiveDepositValue);
    });
  });

  group("PositiveRateValueSpecification", () {
    test("Deve validar se o valor da taxa é maior que zero", () {
      final specification = PositiveRateValueSpecification();
      final regularDeposit = buildRegularDeposit();

      final spec = specification.validate(regularDeposit);

      expect(spec.length, 0);
    });

    test("Deve retornar uma menssagem de erro caso o valor seja negativo", () {
      final specification = PositiveRateValueSpecification();
      final regularDeposit = buildRegularDeposit(positive: false);

      final spec = specification.validate(regularDeposit);

      expect(spec.length, 1);
      expect(spec.last, RegularDepositsValidationMessage.positiveRate);
    });
  });
}
