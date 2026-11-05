import 'package:real_calc/core/themes/calculator_palette.dart';

class MethodologyItem {
  final String title;
  final String text;

  const MethodologyItem(this.title, this.text);
}

/// Notas de metodologia da folha "Como funciona". Fica separado do
/// [HelpContent] para outras explicações, como SAC e Price, usarem a mesma
/// estrutura.
class Methodology {
  static const title = 'Metodologia';

  final List<MethodologyItem> items;

  const Methodology(this.items);

  static Methodology? of(CalculatorKind kind) => switch (kind) {
    CalculatorKind.correction => correction,
    _ => null,
  };

  static const correction = Methodology([
    MethodologyItem(
      'Fator acumulado',
      'O fator junta as variações do índice no período, uma multiplicando a '
          'outra. Com 1% em um mês e 2% no seguinte, o fator é 1,0302, e '
          'não 1,03.',
    ),
    MethodologyItem(
      'Mês inicial e mês final',
      'Nos índices mensais, os dois meses entram no cálculo. De 01/2024 até '
          '03/2024 usa as variações de janeiro, fevereiro e março. Nos '
          'índices diários, como CDI e Selic, a conta começa no dia seguinte '
          'à data inicial.',
    ),
    MethodologyItem(
      'Um mês só',
      'Para corrigir um único mês, use o mesmo mês em De e Até. De 05/2024 '
          'até 05/2024 aplica só a variação de maio.',
    ),
    MethodologyItem(
      'Valores antes do Real',
      'Antes de 07/1994, informe o valor na moeda da época, como cruzeiro ou '
          'cruzado. O app não converte moedas: o resultado sai na mesma moeda '
          'do valor informado.',
    ),
    MethodologyItem(
      'IGP-M',
      'Usamos a série de alta precisão do IGP-M no Banco Central, com dados '
          'desde 06/1989. Em períodos que começam antes de 03/2021, o '
          'resultado pode diferir em centavos de outras calculadoras.',
    ),
  ]);
}
