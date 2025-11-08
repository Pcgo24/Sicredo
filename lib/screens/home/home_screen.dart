import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/service/auth_service.dart';
import '../../core/service/firestore_service.dart';
import '../../domain/models/transaction_model.dart';
import '../cotacoes/cotacoes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _addIncome() async {
    await _submit(kind: 'income');
  }

  Future<void> _addExpense() async {
    await _submit(kind: 'expense');
  }

  Future<void> _submit({required String kind}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final v = double.tryParse(_amountCtrl.text.replaceAll(',', '.'));
      if (v == null || v <= 0) {
        throw Exception('Informe um valor numérico positivo');
      }
      if (kind == 'income') {
        await FirestoreService.instance.addIncome(
          v,
          description:
              _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        );
      } else {
        await FirestoreService.instance.addExpense(
          v,
          description:
              _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        );
      }
      _amountCtrl.clear();
      _descCtrl.clear();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sicredo'),
        actions: [
          // Avatar (foto do Google se existir; caso contrário, ícone padrão)
          if (user != null)
            StreamBuilder<Map<String, dynamic>?>(
              stream: FirestoreService.instance.userDocStream(),
              builder: (context, snapshot) {
                final data = snapshot.data;
                final photoUrl =
                    (data?['photoUrl'] as String?) ?? user.photoURL;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                        ? NetworkImage(photoUrl)
                        : null,
                    child: (photoUrl == null || photoUrl.isEmpty)
                        ? const Icon(Icons.person, size: 18)
                        : null,
                  ),
                );
              },
            ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CotacoesScreen()),
              );
            },
            icon: const Icon(Icons.currency_exchange),
            tooltip: 'Ver cotações',
          ),
          IconButton(
            onPressed: () => AuthService.instance.signOut(),
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (user != null)
              StreamBuilder<String>(
                stream: FirestoreService.instance.userNameStream(),
                builder: (context, snapshot) {
                  final name = snapshot.data ?? (user.displayName ?? 'usuário');
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Olá, $name'),
                  );
                },
              ),
            const SizedBox(height: 8),
            StreamBuilder<double>(
              stream: FirestoreService.instance.balanceStream(),
              builder: (context, snapshot) {
                final bal = snapshot.data ?? 0.0;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Saldo atual',
                            style: TextStyle(fontSize: 18)),
                        Text('R\$ ${bal.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 20,
                              color: bal >= 0
                                  ? Colors.green[700]
                                  : Colors.red[700],
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _amountCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Valor (ex.: 100.50)',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _descCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Descrição (opcional)',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _loading ? null : _addIncome,
                    child: const Text('Adicionar saldo'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _loading ? null : _addExpense,
                    child: const Text('Registrar gasto'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<LedgerTransaction>>(
                stream:
                    FirestoreService.instance.transactionsStream(limit: 100),
                builder: (context, snapshot) {
                  final items = snapshot.data ?? [];
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (items.isEmpty) {
                    return const Center(child: Text('Nenhuma transação ainda'));
                  }
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final t = items[i];
                      final isIncome = t.type == 'income';
                      final sign = isIncome ? '+' : '-';
                      return ListTile(
                        leading: Icon(
                          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isIncome ? Colors.green : Colors.red,
                        ),
                        title: Text(
                            t.description ?? (isIncome ? 'Entrada' : 'Gasto')),
                        subtitle: t.createdAt != null
                            ? Text('${t.createdAt}')
                            : const Text('Aguardando servidor'),
                        trailing: Text(
                          '$sign R\$ ${t.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: isIncome ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
