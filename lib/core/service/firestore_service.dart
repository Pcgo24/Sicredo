import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/models/transaction_model.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }
    return user.uid;
  }

  DocumentReference<Map<String, dynamic>> get _userRef =>
      _db.collection('users').doc(_uid);

  CollectionReference<Map<String, dynamic>> get _txCol =>
      _userRef.collection('transactions');

  // Perfil do usuário: grava/atualiza nome e email
  Future<void> upsertUserProfile({
    required String name,
    String? email,
  }) async {
    await _userRef.set(
      {
        'name': name,
        if (email != null) 'email': email,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // Nome do usuário em tempo real (com fallback para displayName/email do Auth)
  Stream<String> userNameStream() {
    return _userRef.snapshots().map((doc) {
      final data = doc.data();
      final name = data?['name'] as String?;
      if (name != null && name.trim().isNotEmpty) return name;
      // Fallbacks caso o Firestore não tenha nome
      final authUser = _auth.currentUser;
      return authUser?.displayName ?? authUser?.email ?? 'usuário';
    });
  }

  // Saldo em tempo real
  Stream<double> balanceStream() {
    return _userRef.snapshots().map((doc) {
      final data = doc.data();
      final bal = (data?['balance'] as num?)?.toDouble() ?? 0.0;
      return bal;
    });
  }

  // Transações em tempo real (mais recentes primeiro)
  Stream<List<LedgerTransaction>> transactionsStream({int limit = 50}) {
    return _txCol
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(LedgerTransaction.fromDoc).toList());
  }

  Future<void> addIncome(double amount, {String? description}) {
    return _addTransaction(amount, kind: 'income', description: description);
  }

  Future<void> addExpense(double amount, {String? description}) {
    return _addTransaction(amount, kind: 'expense', description: description);
  }

  Future<void> _addTransaction(
    double amount, {
    required String kind, // 'income' ou 'expense'
    String? description,
  }) async {
    if (amount <= 0) throw Exception('O valor deve ser positivo');

    final txRef = _txCol.doc();

    // Atualiza saldo e registra transação de forma atômica
    await _db.runTransaction((transaction) async {
      // Atualiza saldo com FieldValue.increment (positivo para income, negativo para expense)
      final delta = kind == 'income' ? amount : -amount;
      transaction.set(
        _userRef,
        {'balance': FieldValue.increment(delta)},
        SetOptions(merge: true),
      );

      transaction.set(txRef, {
        'type': kind,
        'amount': amount, // guardamos positivo e derivamos o sinal pelo tipo
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
