import 'package:cloud_firestore/cloud_firestore.dart';

/// Transaction model for Firestore persistence
/// Represents a financial transaction (income or expense)
class TransactionModel {
  final String? id;
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

  /// Converts the model to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'valor': valor,
      'data': Timestamp.fromDate(data),
      'isGanho': isGanho,
    };
  }

  /// Creates a model from a Firestore DocumentSnapshot
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      nome: data['nome'] as String,
      valor: (data['valor'] as num).toDouble(),
      data: (data['data'] as Timestamp).toDate(),
      isGanho: data['isGanho'] as bool,
    );
  }

  /// Creates a model from a Map (for compatibility)
  factory TransactionModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return TransactionModel(
      id: id ?? map['id'] as String?,
      nome: map['nome'] as String,
      valor: (map['valor'] as num).toDouble(),
      data: map['data'] is Timestamp 
          ? (map['data'] as Timestamp).toDate()
          : map['data'] is int
              ? DateTime.fromMillisecondsSinceEpoch(map['data'] as int)
              : map['data'] as DateTime,
      isGanho: map['isGanho'] is int 
          ? map['isGanho'] == 1 
          : map['isGanho'] as bool,
    );
  }

  /// Creates a copy of the model with updated fields
  TransactionModel copyWith({
    String? id,
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
