class SgsResponseNetwork {
  static const String _data = 'data';
  static const String _valor = 'valor';

  final String? data;
  final String? valor;

  const SgsResponseNetwork({
    this.data,
    this.valor,
  });

  factory SgsResponseNetwork.fromJson(Map<String, dynamic> json) {
    return SgsResponseNetwork(
      data: json[_data] is String ? json[_data] as String : null,
      valor: json[_valor] is String ? json[_valor] as String : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _data: data,
      _valor: valor,
    };
  }

  SgsResponseNetwork copyWith({
    String? data,
    String? valor,
  }) {
    return SgsResponseNetwork(
      data: data ?? this.data,
      valor: valor ?? this.valor,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SgsResponseNetwork &&
            other.data == data &&
            other.valor == valor;
  }

  @override
  int get hashCode => Object.hash(data, valor);
}
