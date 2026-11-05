import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/widgets/calculator_band/band_statement.dart';
import 'package:real_calc/modules/financial_calculators/domain/entities/financial_calculation.dart';
import 'package:real_calc/modules/financial_calculators/domain/enum/financial_calculation_target.dart';
import 'package:real_calc/modules/financial_calculators/presentation/utils/financing_statement.dart';

void main() {
  const initialValue = FinancialCalculationTarget.initialValue;
  const periods = FinancialCalculationTarget.periods;
  const rate = FinancialCalculationTarget.interestRate;
  const installment = FinancialCalculationTarget.finalValue;

  final solved = FinancialCalculation(
    initialValue: 2500,
    periods: 12,
    rate: 2,
    finalValue: 236.3990,
  );
  final nbsp = String.fromCharCode(0xA0);

  BandStatement statement(
    Set<FinancialCalculationTarget> empty, {
    FinancialCalculationTarget? calculated,
  }) => financingStatement(
    emptyFields: empty,
    values: calculated == null ? FinancialCalculation() : solved,
    calculatedField: calculated,
  );

  group('financingStatement', () {
    test('inicial', () {
      expect(
        statement({initialValue, periods, rate, installment}),
        const BandStatement(
          kicker: 'Informe três valores',
          value: 'e descubra o quarto',
          sub: 'Qualquer campo pode ser o resultado.',
        ),
      );
    });

    test('falta a prestação', () {
      expect(
        statement({installment}),
        const BandStatement(
          kicker: 'Você quer descobrir',
          value: 'a prestação',
          sub: 'Os outros três campos já estão preenchidos.',
        ),
      );
    });

    test('"Você quer descobrir" vale para os quatro campos', () {
      expect(statement({initialValue}).value, 'o valor financiado');
      expect(statement({periods}).value, 'o prazo');
      expect(statement({rate}).value, 'a taxa de juros');
    });

    test('prestação calculada', () {
      expect(
        statement({}, calculated: installment),
        const BandStatement(
          kicker: 'Sua prestação vai ser',
          value: '236,40',
          isMoney: true,
          sub: '12 parcelas iguais, pela Tabela Price',
        ),
      );
    });

    test('valor calculado', () {
      expect(
        statement({}, calculated: initialValue),
        BandStatement(
          kicker: 'Você pode financiar',
          value: '2.500,00',
          isMoney: true,
          sub: 'em 12 parcelas de R\$${nbsp}236,40',
        ),
      );
    });

    test('prazo calculado', () {
      expect(
        statement({}, calculated: periods),
        BandStatement(
          kicker: 'Você quita em',
          value: '12 meses',
          sub: 'com parcelas de R\$${nbsp}236,40',
        ),
      );
    });

    test('taxa calculada', () {
      expect(
        statement({}, calculated: rate),
        const BandStatement(
          kicker: 'A taxa de juros é de',
          value: '2,00% ao mês',
          sub: '26,82% ao ano',
        ),
      );
    });

    test('faltam campos: "falta 1" e "faltam 2"', () {
      expect(
        statement({rate, installment}),
        const BandStatement(
          kicker: 'Para calcular, ainda',
          value: 'falta 1 campo',
          sub: 'Deixe em branco só o que você quer descobrir.',
        ),
      );
      expect(statement({periods, rate, installment}).value, 'faltam 2 campos');
    });

    test('com os quatro preenchidos e nada calculado', () {
      expect(statement({}).value, '1 campo em branco');
    });
  });

  group('financingMissingFieldsMessage', () {
    test('cita os campos vazios na ordem da tela', () {
      expect(
        financingMissingFieldsMessage({installment, rate}),
        'Preencha a taxa de juros ou a prestação. '
        'O campo que ficar em branco é calculado.',
      );
      expect(
        financingMissingFieldsMessage({installment, periods, rate}),
        'Preencha o prazo, a taxa de juros ou a prestação. '
        'O campo que ficar em branco é calculado.',
      );
    });
  });
}
