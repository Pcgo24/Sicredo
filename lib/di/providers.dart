import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicredo/data/datasources/cotacao_remote_data_source.dart';
import 'package:sicredo/data/repositories/cotacao_repository_impl.dart';
import 'package:sicredo/domain/repositories/cotacao_repository.dart';
import 'package:sicredo/domain/usecases/get_cotacoes.dart';

// DataSource
final cotacaoRemoteDataSourceProvider = Provider<CotacaoRemoteDataSource>(
  (ref) => CotacaoRemoteDataSourceImpl(),
);

// Repository
final cotacaoRepositoryProvider = Provider<CotacaoRepository>(
  (ref) => CotacaoRepositoryImpl(ref.watch(cotacaoRemoteDataSourceProvider)),
);

// Use case
final getCotacoesProvider = Provider<GetCotacoes>(
  (ref) => GetCotacoes(ref.watch(cotacaoRepositoryProvider)),
);