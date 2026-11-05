/// Um lado da barra de composição: rótulo e percentual inteiro.
class ResultSegment {
  final String label;
  final int percent;

  const ResultSegment(this.label, this.percent);

  @override
  bool operator ==(Object other) =>
      other is ResultSegment &&
      other.label == label &&
      other.percent == percent;

  @override
  int get hashCode => Object.hash(label, percent);

  @override
  String toString() => '$label $percent%';
}

/// Linha de detalhe: rótulo à esquerda, valor já formatado à direita.
class ResultDetailLine {
  final String label;
  final String value;

  const ResultDetailLine(this.label, this.value);

  @override
  bool operator ==(Object other) =>
      other is ResultDetailLine && other.label == label && other.value == value;

  @override
  int get hashCode => Object.hash(label, value);

  @override
  String toString() => '$label: $value';
}

/// Composição do resultado: o que é da pessoa ([own]) e o que é juros,
/// rendimento ou correção ([other]). Os percentuais somam 100.
class ResultComposition {
  final ResultSegment own;
  final ResultSegment other;

  const ResultComposition._(this.own, this.other);

  /// Calcula os percentuais a partir dos valores em centavos. O lado [own] é
  /// arredondado e o [other] fica com o restante, para a soma dar 100.
  /// Devolve `null` se o total não for positivo ou se alguma parte for
  /// negativa (ex.: deflação), casos em que a barra não faz sentido.
  static ResultComposition? fromCents({
    required String ownLabel,
    required int ownCents,
    required String otherLabel,
    required int otherCents,
  }) {
    final total = ownCents + otherCents;
    if (total <= 0 || ownCents < 0 || otherCents < 0) return null;
    final ownPercent = (ownCents * 100 / total).round();
    return ResultComposition._(
      ResultSegment(ownLabel, ownPercent),
      ResultSegment(otherLabel, 100 - ownPercent),
    );
  }

  /// Texto lido pelo TalkBack, ex.: "Emprestado 88%, Juros 12%".
  String get semanticsLabel => '$own, $other';
}

/// Tudo o que o [ResultDetails] mostra abaixo da lista de campos.
class ResultSummary {
  final String title;
  final ResultComposition? composition;
  final List<ResultDetailLine> lines;

  const ResultSummary({
    required this.title,
    required this.composition,
    required this.lines,
  });
}
