import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sicredo/domain/entities/cotacao.dart';
import 'package:sicredo/domain/repositories/cotacao_repository.dart';
import 'package:sicredo/di/providers.dart';
import 'package:sicredo/presentation/screens/cotacoes_screen.dart';

class _SwitchableRepo implements CotacaoRepository {
  bool shouldFail;
  List<Cotacao> data;

  _SwitchableRepo({
    required this.shouldFail,
    required this.data,
  });

  @override
  Future<List<Cotacao>> getCotacoes() async {
    if (shouldFail) {
      return Future.error(Exception('falha'));
    }
    return data;
  }
}

void main() {
  group('CotacoesScreen Widget', () {
    testWidgets('renderiza lista em caso de sucesso', (tester) async {
      final repo = _SwitchableRepo(
        shouldFail: false,
        data: [
          const Cotacao(code: 'USDBRL', name: 'Dólar Americano/Real Brasileiro', bid: '5.20'),
          const Cotacao(code: 'EURBRL', name: 'Euro/Real Brasileiro', bid: '6.10'),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cotacaoRepositoryProvider.overrideWithValue(repo),
          ],
          child: const MaterialApp(home: CotacoesScreen()),
        ),
      );

      // Deixa o Notifier auto-load completar
      await tester.pumpAndSettle();

      expect(find.textContaining('Dólar Americano/Real Brasileiro'), findsOneWidget);
      expect(find.textContaining('Euro/Real Brasileiro'), findsOneWidget);
      expect(find.text('Valor: R\$ 5.20'), findsOneWidget);
      expect(find.text('Valor: R\$ 6.10'), findsOneWidget);
    });

    testWidgets('exibe erro e permite tentar novamente', (tester) async {
      final repo = _SwitchableRepo(
        shouldFail: true,
        data: [
          const Cotacao(code: 'USDBRL', name: 'Dólar', bid: '5.20'),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cotacaoRepositoryProvider.overrideWithValue(repo),
          ],
          child: const MaterialApp(home: CotacoesScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Erro ao buscar cotações'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);

      // Agora ajusta o repositório para sucesso e clica no retry
      repo.shouldFail = false;
      await tester.tap(find.text('Tentar novamente'));
      await tester.pump(); // inicia o load
      await tester.pumpAndSettle(); // conclui

      expect(find.text('Erro ao buscar cotações'), findsNothing);
      expect(find.textContaining('Dólar'), findsOneWidget);
      expect(find.text('Valor: R\$ 5.20'), findsOneWidget);
    });
  });
}