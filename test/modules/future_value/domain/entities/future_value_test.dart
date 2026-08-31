import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/modules/future_value/domain/entities/future_value.dart';

void main() {
  group('FutureValue', () {
    late FutureValue entity;

    setUp(() {
      entity = FutureValue(
        capital: 1000.0,
        finalValue: 1100.0,
        interestRate: 0.1,
        months: 12,
      );
    });

    test('deve instanciar com valores informados', () {
      expect(entity.capital, 1000.0);
      expect(entity.finalValue, 1100.0);
      expect(entity.interestRate, 0.1);
      expect(entity.months, 12);
    });

    test('deve instanciar com valores padrão quando sem parâmetros', () {
      final defaultFinancing = FutureValue();

      expect(defaultFinancing.capital, 0);
      expect(defaultFinancing.finalValue, 0);
      expect(defaultFinancing.interestRate, 0);
      expect(defaultFinancing.months, 0);
    });

    test('copyWith substitui todos os valores quando informados', () {
      final sut = entity.copyWith(
        capital: 2000.0,
        finalValue: 2200.0,
        interestRate: 0.2,
        months: 24,
      );

      expect(sut.capital, 2000.0);
      expect(sut.finalValue, 2200.0);
      expect(sut.interestRate, 0.2);
      expect(sut.months, 24);
    });

    test('copyWith mantém valores originais quando não informados', () {
      final sut = entity.copyWith(capital: 2000.0);

      expect(sut.capital, 2000.0);
      expect(sut.finalValue, entity.finalValue);
      expect(sut.interestRate, entity.interestRate);
      expect(sut.months, entity.months);
    });
  });
}