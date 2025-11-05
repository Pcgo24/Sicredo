import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicredo/presentation/state/cotacoes_notifier.dart';

class CotacoesScreen extends ConsumerWidget {
  const CotacoesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cotacoesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cotações de Moedas'),
        backgroundColor: const Color(0xFF1c365d),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Erro ao buscar cotações'),
              const SizedBox(height: 12),
              Text(
                '$error',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.red.shade700),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    ref.read(cotacoesNotifierProvider.notifier).load(),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
        data: (value) => value.isEmpty
            ? const Center(child: Text('Nenhum dado disponível.'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: value.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final c = value[index];
                  final Color color = switch (c.code) {
                    'USDBRL' => Colors.blue.shade700,
                    'EURBRL' => Colors.green.shade700,
                    'BTCBRL' => Colors.orange.shade700,
                    _ => Colors.grey.shade700,
                  };
                  final sigla = c.code.replaceAll('BRL', ''); // USD, EUR, BTC
                  return _CotacaoTile(
                    nome: c.name,
                    valor: c.bid,
                    sigla: sigla,
                    cor: color,
                  );
                },
              ),
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
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cor,
          child: Text(
            sigla,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(nome),
        subtitle: Text('Valor: R\$ $valor'),
      ),
    );
  }
}