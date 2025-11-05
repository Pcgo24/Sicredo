import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicredo/domain/entities/cotacao.dart';
import 'package:sicredo/domain/usecases/get_cotacoes.dart';
import 'package:sicredo/di/providers.dart';

// Notifier que gerencia o estado de cotações (loading, data, error)
class CotacoesNotifier extends StateNotifier<AsyncValue<List<Cotacao>>> {
  final GetCotacoes _getCotacoes;

  CotacoesNotifier(this._getCotacoes) : super(const AsyncValue.loading());

  Future<void> load() async {
    try {
      state = const AsyncValue.loading();
      final list = await _getCotacoes();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// Provider do Notifier
final cotacoesNotifierProvider =
    StateNotifierProvider<CotacoesNotifier, AsyncValue<List<Cotacao>>>(
  (ref) {
    final usecase = ref.watch(getCotacoesProvider);
    final notifier = CotacoesNotifier(usecase);
    // Auto-load ao criar o provider
    notifier.load();
    return notifier;
  },
);