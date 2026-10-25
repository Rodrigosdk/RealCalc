class BandStatement {
  final String? kicker;

  final String value;

  final bool isMoney;

  final String? sub;

  const BandStatement({
    this.kicker,
    required this.value,
    this.isMoney = false,
    this.sub,
  });

  String get semanticsLabel =>
      [?kicker, isMoney ? 'R\$ $value' : value, ?sub].join(' ');

  @override
  bool operator ==(Object other) =>
      other is BandStatement &&
      other.kicker == kicker &&
      other.value == value &&
      other.isMoney == isMoney &&
      other.sub == sub;

  @override
  int get hashCode => Object.hash(kicker, value, isMoney, sub);
}
