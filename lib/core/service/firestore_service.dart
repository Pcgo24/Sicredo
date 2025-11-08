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

  // Perfil do usuário: grava/atualiza nome, email e foto.
  // createdAt só é definido na primeira gravação (não sobrescreve em updates).
  Future<void> upsertUserProfile({
    required String name,
    String? email,
    String? photoUrl,
  }) async {
    await _db.runTransaction((tx) async {
      final snap = await tx.get(_userRef);
      final Map<String, dynamic> data = {
        'name': name,
        if (email != null) 'email': email,
        if (photoUrl != null) 'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      final hasCreatedAt = snap.exists && (snap.data()?['createdAt'] is Timestamp);
      if (!hasCreatedAt) {
        data['createdAt'] = FieldValue.serverTimestamp();
      }
      tx.set(_userRef, data, SetOptions(merge: true));
    });
  }

  // Documento completo do usuário (para ler nome e foto na Home)
  Stream<Map<String, dynamic>?> userDocStream() {
    return _userRef.snapshots().map((doc) => doc.data());
  }

  // Nome em tempo real com fallback ao Auth
  Stream<String> userNameStream() {
    return _userRef.snapshots().map((doc) {
      final data = doc.data();
      final name = data?['name'] as String?;
      if (name != null && name.trim().isNotEmpty) return name;
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
      final delta = kind == 'income' ? amount : -amount;
      transaction.set(
        _userRef,
        {'balance': FieldValue.increment(delta)},
        SetOptions(merge: true),
      );

      transaction.set(txRef, {
        'type': kind,
        'amount': amount,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}