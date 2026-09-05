class SelicBcResponseNetwork {
  static const String _data = 'data';
  static const String _valor = 'valor';

  final String? data;
  final String? valor;

  const SelicBcResponseNetwork({
    this.data,
    this.valor,
  });

  factory SelicBcResponseNetwork.fromJson(Map<String, dynamic> json) {
    return SelicBcResponseNetwork(
      data: json[_data] as String?,
      valor: json[_valor] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _data: data,
      _valor: valor,
    };
  }

  SelicBcResponseNetwork copyWith({
    String? data,
    String? valor,
  }) {
    return SelicBcResponseNetwork(
      data: data ?? this.data,
      valor: valor ?? this.valor,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SelicBcResponseNetwork &&
            other.data == data &&
            other.valor == valor;
  }

  @override
  int get hashCode => Object.hash(data, valor);
}