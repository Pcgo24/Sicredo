import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/transaction_model.dart';
import '../data/repositories/firebase_transaction_repository.dart';
import '../services/auth_service.dart';

class EntradaExtrato {
  final String? id;
  final String nome;
  final double valor;
  final DateTime data;
  final bool isGanho;

  EntradaExtrato({
    this.id,
    required this.nome,
    required this.valor,
    required this.data,
    required this.isGanho,
  });

  // Factory to create from TransactionModel
  factory EntradaExtrato.fromModel(TransactionModel model) {
    return EntradaExtrato(
      id: model.id,
      nome: model.nome,
      valor: model.valor,
      data: model.data,
      isGanho: model.isGanho,
    );
  }
}

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  double saldoTotal = 0.0;
  List<EntradaExtrato> extrato = [];
  final FirebaseTransactionRepository _repository = FirebaseTransactionRepository();
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  String? _currentUserId;

  late AnimationController _saldoController;
  late Animation<double> _saldoAnim;

  @override
  void initState() {
    super.initState();
    _saldoController = AnimationController(
      duration: Duration(milliseconds: 700),
      vsync: this,
    );
    _saldoAnim = CurvedAnimation(parent: _saldoController, curve: Curves.elasticOut);
    _saldoController.forward();
    _checkAuthAndLoadData();
  }

  /// Check authentication and load data
  Future<void> _checkAuthAndLoadData() async {
    final user = _authService.currentUser;
    if (user == null) {
      // User not authenticated, redirect to auth screen
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/auth');
      }
      return;
    }

    _currentUserId = user.uid;
    await _loadData();
  }

  /// Loads data from Firestore
  Future<void> _loadData() async {
    if (_currentUserId == null) return;

    try {
      final balance = await _repository.calculateUserBalance(_currentUserId!);
      final transactions = await _repository.getUserTransactions(_currentUserId!);
      
      setState(() {
        saldoTotal = balance;
        extrato = transactions.map((t) => EntradaExtrato.fromModel(t)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _saldoController.dispose();
    super.dispose();
  }

  void _showAddDialog({required bool isGanho}) {
    final _formKey = GlobalKey<FormState>();
    String valorInput = '';
    String nomeInput = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isGanho ? 'Adicionar Saldo' : 'Registrar Gasto'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    hintText: isGanho ? 'Nome do saldo (ex: salário)' : 'Nome do gasto (ex: mercado)',
                    prefixIcon: Icon(Icons.text_fields),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Informe um nome';
                    return null;
                  },
                  onSaved: (value) => nomeInput = value ?? '',
                ),
                SizedBox(height: 16),
                TextFormField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'Valor em reais',
                    prefixIcon: Icon(isGanho ? Icons.attach_money : Icons.money_off),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Informe um valor';
                    final numValue = double.tryParse(value.replaceAll(',', '.'));
                    if (numValue == null || numValue < 0) return 'Valor inválido';
                    return null;
                  },
                  onSaved: (value) => valorInput = value ?? '',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  _formKey.currentState?.save();
                  final valor = double.tryParse(valorInput.replaceAll(',', '.')) ?? 0.0;
                  
                  // Close dialog first
                  Navigator.of(context).pop();
                  
                  // Save to Firestore
                  try {
                    if (_currentUserId == null) {
                      throw Exception('User not authenticated');
                    }

                    final now = DateTime.now();
                    final newTransaction = TransactionModel.fromReais(
                      userId: _currentUserId!,
                      nome: nomeInput,
                      valor: valor,
                      dataTime: now,
                      isGanho: isGanho,
                    );
                    
                    final id = await _repository.addTransaction(newTransaction);
                    
                    // Update balance
                    final newSaldo = isGanho ? saldoTotal + valor : saldoTotal - valor;
                    
                    setState(() {
                      saldoTotal = newSaldo;
                      extrato.insert(
                        0,
                        EntradaExtrato(
                          id: id,
                          nome: nomeInput,
                          valor: valor,
                          data: now,
                          isGanho: isGanho,
                        ),
                      );
                      _saldoController.forward(from: 0); // animação ao atualizar saldo
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isGanho ? 'Saldo adicionado!' : 'Gasto registrado!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao salvar: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isGanho ? Color(0xFF65a30d) : Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}";
  }

  double _gastosDoMes() {
    DateTime agora = DateTime.now();
    return extrato
        .where((e) => !e.isGanho && e.data.month == agora.month && e.data.year == agora.year)
        .fold(0.0, (soma, e) => soma + e.valor);
  }

  double _ganhosDoMes() {
    DateTime agora = DateTime.now();
    return extrato
        .where((e) => e.isGanho && e.data.month == agora.month && e.data.year == agora.year)
        .fold(0.0, (soma, e) => soma + e.valor);
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/auth');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao sair: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF1c365d);
    final Color accentColor = Color(0xFF65a30d);
    final Color bgColor = Color(0xFFF5F8FF);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Sicredo',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w700,
            fontSize: 28,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app, color: primaryColor),
            onPressed: _signOut,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              ScaleTransition(
                scale: _saldoAnim,
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  color: primaryColor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Saldo Total',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 10),
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 350),
                          child: Text(
                            'R\$ ${saldoTotal.toStringAsFixed(2)}',
                            key: ValueKey(saldoTotal),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Ganhos do mês',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'R\$ ${_ganhosDoMes().toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.greenAccent,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Gastos do mês',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'R\$ ${_gastosDoMes().toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _showAddDialog(isGanho: true),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.add_circle_outline, color: Colors.white, size: 32),
                            SizedBox(height: 8),
                            Text(
                              'Adicionar Saldo',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _showAddDialog(isGanho: false),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.remove_circle_outline, color: Colors.white, size: 32),
                            SizedBox(height: 8),
                            Text(
                              'Registrar Gasto',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () => Navigator.pushNamed(context, '/cotacao'),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.currency_exchange, color: Colors.white, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Ver Cotações',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Expanded(
                child: extrato.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Nenhuma transação ainda',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: extrato.length,
                        itemBuilder: (context, idx) {
                          final e = extrato[idx];
                          return Dismissible(
                            key: Key(e.id ?? idx.toString()),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) async {
                              try {
                                if (e.id != null) {
                                  await _repository.deleteTransaction(e.id!);
                                }

                                setState(() {
                                  saldoTotal = e.isGanho ? saldoTotal - e.valor : saldoTotal + e.valor;
                                  extrato.removeAt(idx);
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${e.nome} removido'),
                                    action: SnackBarAction(
                                      label: 'Desfazer',
                                      onPressed: () async {
                                        // Recreate the transaction
                                        try {
                                          if (_currentUserId == null) return;
                                          
                                          final newTransaction = TransactionModel.fromReais(
                                            userId: _currentUserId!,
                                            nome: e.nome,
                                            valor: e.valor,
                                            dataTime: e.data,
                                            isGanho: e.isGanho,
                                          );
                                          await _repository.addTransaction(newTransaction);
                                          await _loadData();
                                        } catch (err) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Erro ao desfazer: $err'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                );
                              } catch (err) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Erro ao remover: $err'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(Icons.delete, color: Colors.white, size: 32),
                            ),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              margin: EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                leading: CircleAvatar(
                                  backgroundColor: e.isGanho ? accentColor : Colors.red,
                                  child: Icon(
                                    e.isGanho ? Icons.arrow_upward : Icons.arrow_downward,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  e.nome,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  _formatDate(e.data),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                trailing: Text(
                                  'R\$ ${e.valor.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    color: e.isGanho ? accentColor : Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
