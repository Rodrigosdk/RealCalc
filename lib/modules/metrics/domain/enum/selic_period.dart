enum SelicPeriod {
  months12('12 meses', 12),
  years5('5 anos', 60);

  final String label;
  final int months;

  const SelicPeriod(this.label, this.months);
}
