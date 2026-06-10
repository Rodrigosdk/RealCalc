import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/seed_works/entity.dart';
import 'package:real_calc/modules/regular_deposits/domain/entities/regular_deposit.dart'; 

void main() {
  group('RegularDeposit', () {
    test('Deve instanciar com os valores fornecidos', () {
      final deposit = RegularDeposit(
        id: '123',
        depositAmount: 500.0,
        rate: 0.01,
        months: 12,
        finalValue: 6300.0,
      );

      expect(deposit.id, '123');
      expect(deposit.depositAmount, 500.0);
      expect(deposit.rate, 0.01);
      expect(deposit.months, 12);
      expect(deposit.finalValue, 6300.0);
    });

    test('Deve usar valores padrão quando nenhum for informado', () {
      final deposit = RegularDeposit();

      expect(deposit.id, isNull);
      expect(deposit.depositAmount, 0.0);
      expect(deposit.rate, 0.0);
      expect(deposit.months, 0);
      expect(deposit.finalValue, 0.0);
    });

    test('Deve herdar de Entity', () {
      final deposit = RegularDeposit();
      
      expect(deposit, isA<Entity>());
    });
  });
}
