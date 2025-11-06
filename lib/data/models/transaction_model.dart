/// Transaction model for database persistence
/// Represents a financial transaction (income or expense)
class TransactionModel {
  final int? id;
  final String nome;
  final double valor;
  final DateTime data;
  final bool isGanho;

  TransactionModel({
    this.id,
    required this.nome,
    required this.valor,
    required this.data,
    required this.isGanho,
  });

  /// Converts the model to a Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'valor': valor,
      'data': data.millisecondsSinceEpoch,
      'isGanho': isGanho ? 1 : 0,
    };
  }

  /// Creates a model from a database Map
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      valor: map['valor'] as double,
      data: DateTime.fromMillisecondsSinceEpoch(map['data'] as int),
      isGanho: map['isGanho'] == 1,
    );
  }

  /// Creates a copy of the model with updated fields
  TransactionModel copyWith({
    int? id,
    String? nome,
    double? valor,
    DateTime? data,
    bool? isGanho,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      valor: valor ?? this.valor,
      data: data ?? this.data,
      isGanho: isGanho ?? this.isGanho,
    );
  }

  @override
  String toString() {
    return 'TransactionModel{id: $id, nome: $nome, valor: $valor, data: $data, isGanho: $isGanho}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TransactionModel &&
        other.id == id &&
        other.nome == nome &&
        other.valor == valor &&
        other.data == data &&
        other.isGanho == isGanho;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        nome.hashCode ^
        valor.hashCode ^
        data.hashCode ^
        isGanho.hashCode;
  }
}
