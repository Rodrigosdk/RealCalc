/// Um ponto de uma série do SGS do Banco Central (`{"data": "...", "valor": "..."}`).
/// Usado pela Selic e pelos índices da Correção de Valores.
class SgsPointResponse {
  static const String _data = 'data';
  static const String _valor = 'valor';

  final String? data;
  final String? valor;

  const SgsPointResponse({this.data, this.valor});

  factory SgsPointResponse.fromJson(Map<String, dynamic> json) {
    return SgsPointResponse(
      data: json[_data] is String ? json[_data] as String : null,
      valor: json[_valor] is String ? json[_valor] as String : null,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SgsPointResponse && other.data == data && other.valor == valor;
  }

  @override
  int get hashCode => Object.hash(data, valor);
}
