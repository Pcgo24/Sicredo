import 'package:flutter/material.dart';
import '../../core/cotacao_service.dart';

class CotacoesScreen extends StatefulWidget {
  const CotacoesScreen({super.key});

  @override
  State<CotacoesScreen> createState() => _CotacoesScreenState();
}

class _CotacoesScreenState extends State<CotacoesScreen> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = CotacaoService.buscarCotacoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cotações')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Erro ao carregar cotações:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

            final data = snapshot.data!;
            // Extrai cada bloco
            final usd = data['USDBRL'] as Map<String, dynamic>?;
            final eur = data['EURBRL'] as Map<String, dynamic>?;
            final btc = data['BTCBRL'] as Map<String, dynamic>?;

            List<_CotacaoItemData> itens = [
              if (usd != null) _CotacaoItemData('USD', usd),
              if (eur != null) _CotacaoItemData('EUR', eur),
              if (btc != null) _CotacaoItemData('BTC', btc),
            ];

            if (itens.isEmpty) {
              return const Center(child: Text('Nenhuma cotação disponível.'));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: itens.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final item = itens[i];
                final m = item.raw;
                final bid = m['bid'];
                final ask = m['ask'];
                final high = m['high'];
                final low = m['low'];
                final pct = m['pctChange'];
                final name = m['name'];
                final time = m['create_date'];

                Color pctColor;
                double? pctValue = double.tryParse('$pct');
                if (pctValue == null) {
                  pctColor = Colors.grey;
                } else {
                  if (pctValue > 0) {
                    pctColor = Colors.green[700]!;
                  } else if (pctValue < 0) {
                    pctColor = Colors.red[700]!;
                  } else {
                    pctColor = Colors.grey;
                  }
                }

                return Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$name',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 24,
                          runSpacing: 8,
                          children: [
                            _info('Bid', bid),
                            _info('Ask', ask),
                            _info('Alta', high),
                            _info('Baixa', low),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Variação: ${pctValue != null ? pctValue.toStringAsFixed(2) : pct}%',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: pctColor,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '$time',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
        },
      ),
    );
  }

  Widget _info(String label, dynamic value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            )),
        Text(
          '$value',
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}

class _CotacaoItemData {
  final String code;
  final Map<String, dynamic> raw;
  _CotacaoItemData(this.code, this.raw);
}