import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/modules/financing/domain/entities/financing.dart';


void main() {
  test('Deve conseguir instanciar Financing', () {
    final financing = Financing(
      initialValue: 1000.0,
      finalValue: 1100.0,
      rate: 0.1,
      months: 12,
    );

    expect(financing.initialValue, 1000.0);
    expect(financing.finalValue, 1100.0);
    expect(financing.rate, 0.1);
    expect(financing.months, 12);
  });

  test('Deve conseguir instanciar Financing com valores 0', () {
    final financing = Financing();

    expect(financing.initialValue, 0);
    expect(financing.finalValue, 0);
    expect(financing.rate, 0);
    expect(financing.months, 0);
  });
}