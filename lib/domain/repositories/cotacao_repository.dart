import 'package:sicredo/domain/entities/cotacao.dart';

abstract class CotacaoRepository {
  Future<List<Cotacao>> getCotacoes();
}