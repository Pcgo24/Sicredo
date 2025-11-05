import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicredo/domain/entities/cotacao.dart';
import 'package:sicredo/domain/repositories/cotacao_repository.dart';
import 'package:sicredo/di/providers.dart';
import 'package:sicredo/presentation/state/cotacoes_notifier.dart';

class _FakeRepoOk implements CotacaoRepository {
  final List<Cotacao> data;
  _FakeRepoOk(this.data);
  @override
  Future<List<Cotacao>> getCotacoes() async => data;
}

class _FakeRepoError implements CotacaoRepository {
  final Object error;
  _FakeRepoError(this.error);
  @override
  Future<List<Cotacao>> getCotacoes() => Future.error(error);
}

void main() {
  group('CotacoesNotifier', () {
    test('deve carregar dados com sucesso', () async {
      final fakeData = [
        const Cotacao(code: 'USDBRL', name: 'Dólar Americano/Real Brasileiro', bid: '5.20'),
        const Cotacao(code: 'EURBRL', name: 'Euro/Real Brasileiro', bid: '6.10'),
      ];

      final container = ProviderContainer(overrides: [
        cotacaoRepositoryProvider.overrideWithValue(_FakeRepoOk(fakeData)),
      ]);

      addTearDown(container.dispose);

      final notifier = container.read(cotacoesNotifierProvider.notifier);
      await notifier.load();

      final state = container.read(cotacoesNotifierProvider);
      expect(state.hasValue, true);
      expect(state.value, isNotNull);
      expect(state.value!.length, 2);
      expect(state.value!.first.code, 'USDBRL');
    });

    test('deve entrar em estado de erro quando repositório falhar', () async {
      final container = ProviderContainer(overrides: [
        cotacaoRepositoryProvider.overrideWithValue(_FakeRepoError(Exception('falha'))),
      ]);

      addTearDown(container.dispose);

      final notifier = container.read(cotacoesNotifierProvider.notifier);
      await notifier.load();

      final state = container.read(cotacoesNotifierProvider);
      expect(state.hasError, true);
    });
  });
}