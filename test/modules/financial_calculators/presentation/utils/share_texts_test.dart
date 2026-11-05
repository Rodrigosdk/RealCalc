import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/modules/financial_calculators/domain/entities/financial_calculation.dart';
import 'package:real_calc/modules/financial_calculators/domain/enum/financial_calculation_target.dart';
import 'package:real_calc/modules/financial_calculators/presentation/utils/share_texts.dart';

void main() {
  group('financingShareText', () {
    final values = FinancialCalculation(
      initialValue: 2500,
      periods: 12,
      rate: 2,
      finalValue: 236.3990,
    );

    test('prestação calculada, igual ao exemplo da issue', () {
      expect(
        financingShareText(values, FinancialCalculationTarget.finalValue),
        'RealCalc · Financiamento\n'
        'Sua prestação vai ser R\$ 236,40\n'
        '12 parcelas iguais, pela Tabela Price\n'
        '\n'
        'Valor financiado: R\$ 2.500,00\n'
        'Prazo: 12 meses\n'
        'Taxa de juros: 2,00% ao mês\n'
        'Total pago: R\$ 2.836,80\n'
        'Juros: R\$ 336,80\n'
        '\n'
        'Simulação feita no RealCalc, sem valor oficial.',
      );
    });

    test('taxa calculada lista a prestação no lugar da taxa', () {
      final text = financingShareText(
        values,
        FinancialCalculationTarget.interestRate,
      );

      expect(text, contains('A taxa de juros é de 2,00% ao mês\n'));
      expect(text, contains('26,82% ao ano\n'));
      expect(text, contains('Prestação: R\$ 236,40\n'));
      expect(text, isNot(contains('Taxa de juros:')));
    });

    test('não tem espaço não separável', () {
      final text = financingShareText(
        values,
        FinancialCalculationTarget.initialValue,
      );
      expect(text.contains(String.fromCharCode(0xA0)), isFalse);
      expect(text, contains('Você pode financiar R\$ 2.500,00\n'));
      expect(text, contains('em 12 parcelas de R\$ 236,40\n'));
    });
  });

  test('depositsShareText', () {
    expect(
      depositsShareText(
        FinancialCalculation(
          initialValue: 200,
          periods: 24,
          rate: 0.8,
          finalValue: 5310.7801,
        ),
        FinancialCalculationTarget.finalValue,
      ),
      'RealCalc · Depósitos Regulares\n'
      'Guardando R\$ 200,00 por mês, você terá R\$ 5.310,78\n'
      'em 24 meses, com R\$ 510,78 de rendimento\n'
      '\n'
      'Depósito mensal: R\$ 200,00\n'
      'Prazo: 24 meses\n'
      'Taxa de juros: 0,80% ao mês\n'
      'Total depositado: R\$ 4.800,00\n'
      'Rendimento: R\$ 510,78\n'
      '\n'
      'Simulação feita no RealCalc, sem valor oficial.',
    );
  });

  test('futureValueShareText', () {
    expect(
      futureValueShareText(
        FinancialCalculation(
          initialValue: 2555.55,
          periods: 25,
          rate: 0.33,
          finalValue: 2774.947,
        ),
        FinancialCalculationTarget.finalValue,
      ),
      'RealCalc · Valor Futuro\n'
      'Aplicando R\$ 2.555,55 hoje, você terá R\$ 2.774,95\n'
      'em 25 meses, com R\$ 219,40 de rendimento\n'
      '\n'
      'Valor aplicado: R\$ 2.555,55\n'
      'Prazo: 25 meses\n'
      'Taxa de juros: 0,33% ao mês\n'
      'Rendimento: R\$ 219,40\n'
      '\n'
      'Simulação feita no RealCalc, sem valor oficial.',
    );
  });
}
