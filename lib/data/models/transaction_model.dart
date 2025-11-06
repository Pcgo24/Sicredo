import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Transaction model for Firestore persistence
/// Represents a financial transaction (income or expense)
class TransactionModel {
  final String? id; // Firestore document ID
  final String userId; // User who owns this transaction
  final String nome;
  final int amountCents; // Amount in cents to avoid floating point issues
  final Timestamp date; // Timestamp for queries and sorting
  final String dateStr; // Formatted date string (dd/MM/yyyy) for display
  final String type; // "entrada" or "saida"

  TransactionModel({
    this.id,
    required this.userId,
    required this.nome,
    required this.amountCents,
    required this.date,
    required this.dateStr,
    required this.type,
  });

  /// Helper to get amount in reais (double)
  double get valor => amountCents / 100.0;

  /// Helper to check if it's income
  bool get isGanho => type == 'entrada';

  /// Creates a TransactionModel from amount in reais
  factory TransactionModel.fromReais({
    String? id,
    required String userId,
    required String nome,
    required double valor,
    required DateTime dataTime,
    required bool isGanho,
  }) {
    final dateFormatter = DateFormat('dd/MM/yyyy');
    return TransactionModel(
      id: id,
      userId: userId,
      nome: nome,
      amountCents: (valor * 100).round(),
      date: Timestamp.fromDate(dataTime),
      dateStr: dateFormatter.format(dataTime),
      type: isGanho ? 'entrada' : 'saida',
    );
  }

  /// Creates a TransactionModel from Firestore document
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      userId: data['userId'] as String,
      nome: data['nome'] as String? ?? '',
      amountCents: data['amountCents'] as int,
      date: data['date'] as Timestamp,
      dateStr: data['dateStr'] as String,
      type: data['type'] as String,
    );
  }

  /// Converts TransactionModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'nome': nome,
      'amountCents': amountCents,
      'date': date,
      'dateStr': dateStr,
      'type': type,
    };
  }

  /// Creates a copy of the model with updated fields
  TransactionModel copyWith({
    String? id,
    String? userId,
    String? nome,
    int? amountCents,
    Timestamp? date,
    String? dateStr,
    String? type,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nome: nome ?? this.nome,
      amountCents: amountCents ?? this.amountCents,
      date: date ?? this.date,
      dateStr: dateStr ?? this.dateStr,
      type: type ?? this.type,
    );
  }

  /// Helper to get DateTime from Timestamp
  DateTime get data => date.toDate();

  @override
  String toString() {
    return 'TransactionModel{id: $id, userId: $userId, nome: $nome, valor: $valor, date: $dateStr, type: $type}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TransactionModel &&
        other.id == id &&
        other.userId == userId &&
        other.nome == nome &&
        other.amountCents == amountCents &&
        other.date == date &&
        other.dateStr == dateStr &&
        other.type == type;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        nome.hashCode ^
        amountCents.hashCode ^
        date.hashCode ^
        dateStr.hashCode ^
        type.hashCode;
  }
}
