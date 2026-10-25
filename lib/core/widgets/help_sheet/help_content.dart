import 'package:real_calc/core/themes/calculator_palette.dart';

class HelpField {
  final String name;
  final String description;

  const HelpField(this.name, this.description);
}

class HelpContent {
  final String intro;
  final List<HelpField> fields;
  final String example;
  final String exampleResult;
  final String methodology;
  final String formula;

  const HelpContent({
    required this.intro,
    required this.fields,
    required this.example,
    required this.exampleResult,
    required this.methodology,
    required this.formula,
  });

  static HelpContent of(CalculatorKind kind) => switch (kind) {
    CalculatorKind.financing => financing,
    CalculatorKind.deposits => deposits,
    CalculatorKind.futureValue => futureValue,
    CalculatorKind.correction => correction,
  };

  static const _rate = HelpField(
    'Taxa de juros',
    'Os juros de cada mês, em porcentagem.',
  );

  static const financing = HelpContent(
    intro:
        'Descubra a prestação, o valor financiado, o prazo ou a taxa. '
        'Preencha três campos e o app calcula o que falta.',
    fields: [
      HelpField(
        'Valor financiado',
        'Quanto você vai pegar emprestado, sem os juros.',
      ),
      HelpField('Prazo', 'Em quantos meses a dívida será paga.'),
      _rate,
      HelpField('Prestação', 'O valor fixo pago todo mês.'),
    ],
    example: 'R\$ 2.500,00 a 2% ao mês, em 12 meses, dão uma prestação de',
    exampleResult: 'R\$ 236,40',
    methodology:
        'Usamos a tabela Price, com prestações iguais. V é o valor '
        'financiado, i a taxa mensal e n o prazo.',
    formula: 'P = V × i ÷ (1 − (1 + i)⁻ⁿ)',
  );

  static const deposits = HelpContent(
    intro:
        'Veja quanto junta guardando o mesmo valor todo mês, ou descubra o '
        'depósito, o prazo ou a taxa para chegar a um objetivo.',
    fields: [
      HelpField(
        'Depósito mensal',
        'O valor guardado todo mês, sempre no início do mês.',
      ),
      HelpField('Prazo', 'Por quantos meses você vai depositar.'),
      _rate,
      HelpField('Valor final', 'Quanto você terá no fim do prazo.'),
    ],
    example: 'R\$ 100,00 por mês a 1% ao mês, durante 12 meses, viram',
    exampleResult: 'R\$ 1.280,93',
    methodology:
        'O depósito é feito no início de cada mês e já rende no próprio '
        'mês. D é o depósito, i a taxa mensal e n o prazo.',
    formula: 'VF = D × (1 + i) × ((1 + i)ⁿ − 1) ÷ i',
  );

  static const futureValue = HelpContent(
    intro:
        'Veja quanto um valor aplicado hoje rende com juros compostos, ou '
        'descubra o capital, o prazo ou a taxa.',
    fields: [
      HelpField('Capital', 'O valor aplicado hoje, uma única vez.'),
      HelpField('Prazo', 'Por quantos meses o dinheiro fica aplicado.'),
      _rate,
      HelpField('Valor final', 'Quanto o capital vale no fim do prazo.'),
    ],
    example: 'R\$ 1.000,00 a 1% ao mês, durante 12 meses, viram',
    exampleResult: 'R\$ 1.126,83',
    methodology:
        'Juros compostos: os juros de cada mês também passam a render. VP '
        'é o capital, i a taxa mensal e n o prazo.',
    formula: 'VF = VP × (1 + i)ⁿ',
  );

  static const correction = HelpContent(
    intro:
        'Atualize um valor pela inflação ou por outro índice entre duas '
        'datas, com os dados oficiais do Banco Central.',
    fields: [
      HelpField(
        'Índice de correção',
        'A série usada na correção, como IPCA, IGP-M ou CDI.',
      ),
      HelpField('Data inicial', 'De quando o valor parte.'),
      HelpField('Data final', 'Até quando o valor é corrigido.'),
      HelpField(
        'Percentual',
        'Só no CDI: quanto do CDI aplicar, como 100% ou 110%.',
      ),
      HelpField(
        'Valor a ser corrigido',
        'O valor na data inicial. Sem ele, mostramos só o fator.',
      ),
    ],
    example:
        'Se o índice subiu 0,5% em um mês e 0,4% no seguinte, '
        'R\$ 1.000,00 viram',
    exampleResult: 'R\$ 1.009,02',
    methodology:
        'Multiplicamos as variações de cada período e aplicamos o fator ao '
        'valor. i₁ … iₙ são as variações do índice no período.',
    formula: 'fator = (1 + i₁) × … × (1 + iₙ)',
  );
}
