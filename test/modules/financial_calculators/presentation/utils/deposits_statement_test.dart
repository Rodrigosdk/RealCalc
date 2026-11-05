import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/widgets/calculator_band/band_statement.dart';
import 'package:real_calc/modules/financial_calculators/domain/entities/financial_calculation.dart';
import 'package:real_calc/modules/financial_calculators/domain/enum/financial_calculation_target.dart';
import 'package:real_calc/modules/financial_calculators/presentation/utils/deposits_statement.dart';

void main() {
  const deposit = FinancialCalculationTarget.initialValue;
  const periods = FinancialCalculationTarget.periods;
  const rate = FinancialCalculationTarget.interestRate;
  const finalValue = FinancialCalculationTarget.finalValue;

  final solved = FinancialCalculation(
    initialValue: 200,
    periods: 24,
    rate: 0.8,
    finalValue: 5310.7801,
  );
  final nbsp = String.fromCharCode(0xA0);
  String money(String value) => 'R\$$nbsp$value';

  BandStatement statement(
    Set<FinancialCalculationTarget> empty, {
    FinancialCalculationTarget? calculated,
  }) => depositsStatement(
    emptyFields: empty,
    values: calculated == null ? FinancialCalculation() : solved,
    calculatedField: calculated,
  );

  group('depositsStatement', () {
    test('valor final calculado', () {
      expect(
        statement({}, calculated: finalValue),
        BandStatement(
          kicker: 'Guardando ${money('200,00')} por mês, você terá',
          value: '5.310,78',
          isMoney: true,
          sub: 'em 24 meses, com ${money('510,78')} de rendimento',
        ),
      );
    });

    test('depósito calculado', () {
      expect(
        statement({}, calculated: deposit),
        BandStatement(
          kicker: 'Para juntar ${money('5.310,78')}, guarde por mês',
          value: '200,00',
          isMoney: true,
          sub: 'durante 24 meses',
        ),
      );
    });

    test('prazo calculado', () {
      expect(
        statement({}, calculated: periods),
        BandStatement(
          kicker:
              'Guardando ${money('200,00')} por mês, você junta '
              '${money('5.310,78')} em',
          value: '24 meses',
          sub: 'com ${money('510,78')} de rendimento',
        ),
      );
    });

    test('taxa calculada', () {
      expect(
        statement({}, calculated: rate),
        const BandStatement(
          kicker: 'Para isso, o dinheiro precisa render',
          value: '0,80% ao mês',
          sub: '10,03% ao ano',
        ),
      );
    });

    test('inicial, pergunta e aviso seguem o Financiamento', () {
      expect(
        statement({deposit, periods, rate, finalValue}).value,
        'e descubra o quarto',
      );
      expect(statement({finalValue}).value, 'o valor final');
      expect(statement({deposit}).value, 'o depósito');
      expect(statement({rate, finalValue}).value, 'falta 1 campo');
    });

    test('aviso cita os campos vazios', () {
      expect(
        depositsMissingFieldsMessage({deposit, finalValue}),
        'Preencha o depósito ou o valor final. '
        'O campo que ficar em branco é calculado.',
      );
    });
  });
}
