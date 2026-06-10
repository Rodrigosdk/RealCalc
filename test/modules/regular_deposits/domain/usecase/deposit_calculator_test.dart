import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/modules/regular_deposits/domain/entities/regular_deposit.dart';
import 'package:real_calc/modules/regular_deposits/domain/usecase/deposit_calculator.dart';


void main() {
  late double initalValue;
  late int months;
  late double rate;
  late double finalValue;

  RegularDeposit buildEntity({
    double? initalValueParams,
    int? monthsParams,
    double? rateParams,
    double? finalValueParams,
  }) {
    return RegularDeposit(
      depositAmount: initalValueParams ?? initalValue,
      months: monthsParams ?? months,
      rate: rateParams ?? rate,
      finalValue: finalValueParams ?? finalValue,
    );
  }

  setUp(() {
    initalValue = 100;
    months = 12;
    rate = 1.50;
    finalValue = 1323.68;
  });

  group("DepositCalculatorUseCase", () {
    test("Deve conseguir calcular o valor futuro do deposito", () {
      final params = buildEntity(finalValueParams: 0);

      final sut = DepositCalculatorUseCase.calculateFinalValue(params);

      expect(sut.isSuccess, true);
      expect(sut.getOrNull(), closeTo(finalValue, 0.01));
    });

    test("Deve conseguir calcular o valor futuro do deposito quando a taxa de juros for ZERO", () {
        final params = buildEntity(rateParams: 0, finalValueParams: 0);
        final result = 1200;

        final sut = DepositCalculatorUseCase.calculateFinalValue(params);

        expect(sut.isSuccess, true);
        expect(sut.getOrNull(), result);
      },
    );

    test("Deve conseguir calcular o valor de depósito regular", () {
      final params = buildEntity(initalValueParams: 0);

      final sut = DepositCalculatorUseCase.calculateDepositAmount(params);

      expect(sut.isSuccess, true);
      expect(sut.getOrNull(), closeTo(initalValue, 0.01));
    });
    
    test("Deve conseguir calcular o valor de depósito regular quando a taxa de juros for ZERO", () {
      final params = buildEntity(
        initalValueParams: 0.0,    
        finalValueParams: 1200.00,
        monthsParams: 12,          
        rateParams: 0.0,           
      );

      final sut = DepositCalculatorUseCase.calculateDepositAmount(params);

      expect(sut.isSuccess, true);
      expect(sut.getOrNull(), 100.00);
    });

    test("Deve conseguir calcular o número do mes", () {
      final params = buildEntity(monthsParams: 0);

      final sut = DepositCalculatorUseCase.calculateNumberOfMonths(params);

      expect(sut.isSuccess, true);
      expect(sut.getOrNull(), closeTo(months, 0.01));
    });

    test("Deve conseguir calcular o o número do mes quando a taxa de juros for ZERO", () {
      final params = buildEntity(
        rateParams: 0,
        finalValueParams: 1200,
        monthsParams: 0,               
      );

      final sut = DepositCalculatorUseCase.calculateNumberOfMonths(params);

      expect(sut.isSuccess, true);
      expect(sut.getOrNull(), 12);
    });

    test("Deve conseguir calcular a taxa de juros mensal quando houver rendimento", () {
      final params = buildEntity(
        rateParams: 0.0, 
        finalValueParams: 1323.68,
      );

      final sut = DepositCalculatorUseCase.calculateInterestRate(params);

      expect(sut.isSuccess, true);
      expect(sut.getOrNull(), closeTo(rate, 0.01)); 
    });

    test("Deve retornar taxa ZERO quando o valor final for exatamente igual à soma linear dos depósitos", () {
      final paramsSemJuros = buildEntity(
        rateParams: 0.0,
        finalValueParams: 1200.00,
      );

      final sut = DepositCalculatorUseCase.calculateInterestRate(paramsSemJuros);

      expect(sut.isSuccess, true);
      expect(sut.getOrNull(), 0.0);
    });

    test("Deve retornar taxa ZERO quando o valor final for menor do que a soma linear dos depósitos", () {
      final paramsComPerda = buildEntity(
        rateParams: 0.0,
        finalValueParams: 1100.00,
      );

      final sut = DepositCalculatorUseCase.calculateInterestRate(paramsComPerda);

      expect(sut.isSuccess, true);
      expect(sut.getOrNull(), 0.0);
    });
  });
}
