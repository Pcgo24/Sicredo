import 'package:sicredo/domain/entities/cotacao.dart';
import 'package:sicredo/domain/repositories/cotacao_repository.dart';

class GetCotacoes {
  final CotacaoRepository repository;

  GetCotacoes(this.repository);

  Future<List<Cotacao>> call() {
    return repository.getCotacoes();
  }
}