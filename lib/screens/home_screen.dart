import 'package:flutter/material.dart';
import '../data/models/transaction_model.dart';
import '../data/repositories/transaction_repository.dart';

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

  // Convert to TransactionModel
  TransactionModel toModel() {
    return TransactionModel(
      id: id,
      nome: nome,
      valor: valor,
      data: data,
      isGanho: isGanho,
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
  final TransactionRepository _repository = TransactionRepository();
  bool _isLoading = true;

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
    _loadData();
  }

  /// Loads data from the database
  Future<void> _loadData() async {
    try {
      final balance = await _repository.getSaldoTotal();
      final transactions = await _repository.getAllTransactions();
      
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
                  
                  // Save to database
                  try {
                    final now = DateTime.now();
                    final newTransaction = TransactionModel(
                      nome: nomeInput,
                      valor: valor,
                      data: now,
                      isGanho: isGanho,
                    );
                    
                    final id = await _repository.insertTransaction(newTransaction);
                    
                    // Note: Using current saldoTotal for calculation is safe in this UI context
                    // as transactions are added one at a time. For concurrent scenarios,
                    // consider using repository.calculateSaldoTotal() instead.
                    final newSaldo = isGanho ? saldoTotal + valor : saldoTotal - valor;
                    await _repository.updateSaldoTotal(newSaldo);
                    
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
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _ResumoCard(
                              label: "Ganhos do mês",
                              valor: _ganhosDoMes(),
                              color: accentColor,
                              icon: Icons.arrow_upward,
                            ),
                            _ResumoCard(
                              label: "Gastos do mês",
                              valor: _gastosDoMes(),
                              color: Colors.red,
                              icon: Icons.arrow_downward,
                            ),
                          ],
                        ),
                        SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                splashColor: accentColor.withOpacity(0.3),
                                onTap: () => _showAddDialog(isGanho: true),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: accentColor,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add, color: Colors.white),
                                      SizedBox(width: 6),
                                      Text(
                                        'Adicionar Saldo',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                splashColor: Colors.red.withOpacity(0.3),
                                onTap: () => _showAddDialog(isGanho: false),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.remove, color: Colors.white),
                                      SizedBox(width: 6),
                                      Text(
                                        'Registrar Gasto',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/cotacao');
                            },
                            icon: Icon(Icons.attach_money),
                            label: Text('Ver cotações de moedas'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF1c365d),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Extrato do mês',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
              ),
              SizedBox(height: 12),
              Expanded(
                child: extrato.isEmpty
                    ? Center(
                        child: Text(
                          'Nenhum saldo ou gasto registrado ainda.',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: extrato.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: 1, color: Colors.grey[300]),
                        itemBuilder: (context, index) {
                          final entry = extrato[index];
                          return Dismissible(
                            key: ValueKey(entry.nome + entry.data.toString()),
                            background: Container(
                              color: Colors.red.withOpacity(0.8),
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(right: 20),
                              child: Icon(Icons.delete, color: Colors.white, size: 28),
                            ),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) async {
                              final entryToDelete = entry;
                              
                              try {
                                // Delete from database
                                if (entryToDelete.id != null) {
                                  await _repository.deleteTransaction(entryToDelete.id!);
                                }
                                
                                final newSaldo = saldoTotal + (entryToDelete.isGanho ? -entryToDelete.valor : entryToDelete.valor);
                                await _repository.updateSaldoTotal(newSaldo);
                                
                                setState(() {
                                  saldoTotal = newSaldo;
                                  extrato.removeAt(index);
                                  _saldoController.forward(from: 0);
                                });
                              } catch (e) {
                                // If error, reload from database
                                await _loadData();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Erro ao deletar: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            child: InkWell(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Item "${entry.nome}" (${entry.isGanho ? "ganho" : "gasto"})',
                                    ),
                                    duration: Duration(milliseconds: 900),
                                    backgroundColor: entry.isGanho
                                        ? accentColor
                                        : Colors.red,
                                  ),
                                );
                              },
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      entry.isGanho ? accentColor : Colors.red,
                                  child: Icon(
                                    entry.isGanho
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  entry.nome,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                  ),
                                ),
                                subtitle: Text(
                                  _formatDate(entry.data),
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                  ),
                                ),
                                trailing: Text(
                                  (entry.isGanho ? '+ ' : '- ') +
                                      'R\$ ${entry.valor.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: entry.isGanho ? accentColor : Colors.red,
                                    fontSize: 16,
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

class _ResumoCard extends StatelessWidget {
  final String label;
  final double valor;
  final Color color;
  final IconData icon;

  _ResumoCard({
    required this.label,
    required this.valor,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.15),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'R\$ ${valor.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}