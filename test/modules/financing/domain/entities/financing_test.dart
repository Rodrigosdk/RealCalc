import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/modules/financing/domain/entities/financing.dart';


void main() {
  group('Financing', () {
    late Financing financing;

    setUp(() {
      financing = Financing(
        initialValue: 1000.0,
        finalValue: 1100.0,
        rate: 0.1,
        months: 12,
      );
    });

    test('deve instanciar com valores informados', () {
      expect(financing.initialValue, 1000.0);
      expect(financing.finalValue, 1100.0);
      expect(financing.rate, 0.1);
      expect(financing.months, 12);
    });

    test('deve instanciar com valores padrão quando sem parâmetros', () {
      final defaultFinancing = Financing();

      expect(defaultFinancing.initialValue, 0);
      expect(defaultFinancing.finalValue, 0);
      expect(defaultFinancing.rate, 0);
      expect(defaultFinancing.months, 0);
    });

    test('copyWith substitui todos os valores quando informados', () {
      final sut = financing.copyWith(
        initialValue: 2000.0,
        finalValue: 2200.0,
        rate: 0.2,
        months: 24,
      );

      expect(sut.initialValue, 2000.0);
      expect(sut.finalValue, 2200.0);
      expect(sut.rate, 0.2);
      expect(sut.months, 24);
    });

    test('copyWith mantém valores originais quando não informados', () {
      final sut = financing.copyWith(initialValue: 2000.0);

      expect(sut.initialValue, 2000.0);
      expect(sut.finalValue, financing.finalValue);
      expect(sut.rate, financing.rate);
      expect(sut.months, financing.months);
    });
  });
}