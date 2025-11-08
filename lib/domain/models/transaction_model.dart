import 'package:cloud_firestore/cloud_firestore.dart';

class LedgerTransaction {
  final String id;
  final String type; // 'income' | 'expense'
  final double amount; // sempre positivo
  final String? description;
  final DateTime? createdAt;

  LedgerTransaction({
    required this.id,
    required this.type,
    required this.amount,
    this.description,
    required this.createdAt,
  });

  factory LedgerTransaction.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final ts = data['createdAt'];
    DateTime? created;
    if (ts is Timestamp) created = ts.toDate();

    return LedgerTransaction(
      id: doc.id,
      type: (data['type'] as String?) ?? 'income',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      description: data['description'] as String?,
      createdAt: created,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'amount': amount,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}