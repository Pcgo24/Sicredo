import 'package:flutter/material.dart';
import '../core/cotacao_service.dart';

class CotacoesScreen extends StatelessWidget {
  CotacoesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cotações de Moedas'),
        backgroundColor: Color(0xFF1c365d),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: CotacaoService.buscarCotacoes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao buscar cotações'));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            return ListView(
              padding: EdgeInsets.all(16),
              children: [
                _CotacaoTile(
                  nome: data['USDBRL']['name'],
                  valor: data['USDBRL']['bid'],
                  sigla: 'USD',
                  cor: Colors.blue.shade700,
                ),
                _CotacaoTile(
                  nome: data['EURBRL']['name'],
                  valor: data['EURBRL']['bid'],
                  sigla: 'EUR',
                  cor: Colors.green.shade700,
                ),
                _CotacaoTile(
                  nome: data['BTCBRL']['name'],
                  valor: data['BTCBRL']['bid'],
                  sigla: 'BTC',
                  cor: Colors.orange.shade700,
                ),
              ],
            );
          } else {
            return Center(child: Text('Nenhum dado disponível.'));
          }
        },
      ),
    );
  }
}

class _CotacaoTile extends StatelessWidget {
  final String nome;
  final String valor;
  final String sigla;
  final Color cor;

  const _CotacaoTile({
    required this.nome,
    required this.valor,
    required this.sigla,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cor,
          child: Text(
            sigla,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(nome),
        subtitle: Text('Valor: R\$ $valor'),
      ),
    );
  }
}