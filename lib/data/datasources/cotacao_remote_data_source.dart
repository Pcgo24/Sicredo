import 'package:sicredo/core/cotacao_service.dart';

abstract class CotacaoRemoteDataSource {
  Future<Map<String, dynamic>> fetchCotacoesRaw();
}

class CotacaoRemoteDataSourceImpl implements CotacaoRemoteDataSource {
  @override
  Future<Map<String, dynamic>> fetchCotacoesRaw() {
    // Reaproveita o service existente para minimizar mudanças
    return CotacaoService.buscarCotacoes();
  }
}