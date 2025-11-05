import 'package:sicredo/data/datasources/cotacao_remote_data_source.dart';
import 'package:sicredo/data/repositories/cotacao_repository_impl.dart';
import 'package:sicredo/domain/usecases/get_cotacoes.dart';

GetCotacoes makeGetCotacoes() {
  final ds = CotacaoRemoteDataSourceImpl();
  final repo = CotacaoRepositoryImpl(ds);
  return GetCotacoes(repo);
}