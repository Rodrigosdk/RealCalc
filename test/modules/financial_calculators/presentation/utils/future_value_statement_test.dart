import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/widgets/calculator_band/band_statement.dart';
import 'package:real_calc/modules/financial_calculators/domain/entities/financial_calculation.dart';
import 'package:real_calc/modules/financial_calculators/domain/enum/financial_calculation_target.dart';
import 'package:real_calc/modules/financial_calculators/presentation/utils/future_value_statement.dart';

void main() {
  const applied = FinancialCalculationTarget.initialValue;
  const periods = FinancialCalculationTarget.periods;
  const rate = FinancialCalculationTarget.interestRate;
  const future = FinancialCalculationTarget.finalValue;

  final solved = FinancialCalculation(
    initialValue: 2555.55,
    periods: 25,
    rate: 0.33,
    finalValue: 2774.947,
  );
  final nbsp = String.fromCharCode(0xA0);
  String money(String value) => 'R\$$nbsp$value';

  BandStatement statement(
    Set<FinancialCalculationTarget> empty, {
    FinancialCalculationTarget? calculated,
  }) => futureValueStatement(
    emptyFields: empty,
    values: calculated == null ? FinancialCalculation() : solved,
    calculatedField: calculated,
  );

  group('futureValueStatement', () {
    test('valor futuro calculado', () {
      expect(
        statement({}, calculated: future),
        BandStatement(
          kicker: 'Aplicando ${money('2.555,55')} hoje, você terá',
          value: '2.774,95',
          isMoney: true,
          sub: 'em 25 meses, com ${money('219,40')} de rendimento',
        ),
      );
    });

    test('valor aplicado calculado', () {
      expect(
        statement({}, calculated: applied),
        BandStatement(
          kicker: 'Para ter ${money('2.774,95')}, aplique hoje',
          value: '2.555,55',
          isMoney: true,
          sub: 'por 25 meses',
        ),
      );
    });

    test('prazo calculado', () {
      expect(
        statement({}, calculated: periods),
        BandStatement(
          kicker: '${money('2.555,55')} viram ${money('2.774,95')} em',
          value: '25 meses',
          sub: 'com ${money('219,40')} de rendimento',
        ),
      );
    });

    test('taxa calculada', () {
      expect(
        statement({}, calculated: rate),
        const BandStatement(
          kicker: 'Para isso, o dinheiro precisa render',
          value: '0,33% ao mês',
          sub: '4,03% ao ano',
        ),
      );
    });

    test('inicial, pergunta e aviso seguem o Financiamento', () {
      expect(
        statement({applied, periods, rate, future}).value,
        'e descubra o quarto',
      );
      expect(statement({future}).value, 'o valor futuro');
      expect(statement({applied}).value, 'o valor aplicado');
      expect(statement({periods, rate, future}).value, 'faltam 2 campos');
    });

    test('aviso cita os campos vazios', () {
      expect(
        futureValueMissingFieldsMessage({rate, future}),
        'Preencha a taxa de juros ou o valor futuro. '
        'O campo que ficar em branco é calculado.',
      );
    });
  });
}
