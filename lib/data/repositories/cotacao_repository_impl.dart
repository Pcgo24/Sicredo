import 'package:sicredo/data/datasources/cotacao_remote_data_source.dart';
import 'package:sicredo/data/models/cotacao_model.dart';
import 'package:sicredo/domain/entities/cotacao.dart';
import 'package:sicredo/domain/repositories/cotacao_repository.dart';

class CotacaoRepositoryImpl implements CotacaoRepository {
  final CotacaoRemoteDataSource remote;

  CotacaoRepositoryImpl(this.remote);

  @override
  Future<List<Cotacao>> getCotacoes() async {
    final raw = await remote.fetchCotacoesRaw();

    // Chaves esperadas da AwesomeAPI
    final keys = ['USDBRL', 'EURBRL', 'BTCBRL'];

    final result = <Cotacao>[];
    for (final key in keys) {
      final data = raw[key];
      if (data is Map<String, dynamic>) {
        final model = CotacaoModel.fromMap(key, data);
        result.add(model.toEntity());
      }
    }
    return result;
  }
}