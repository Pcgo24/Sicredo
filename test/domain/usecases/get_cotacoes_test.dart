import 'package:flutter_test/flutter_test.dart';
import 'package:sicredo/domain/entities/cotacao.dart';
import 'package:sicredo/domain/repositories/cotacao_repository.dart';
import 'package:sicredo/domain/usecases/get_cotacoes.dart';

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
  group('GetCotacoes UseCase', () {
    test('deve retornar lista do repositório (sucesso)', () async {
      final list = [
        const Cotacao(code: 'USDBRL', name: 'USD/BRL', bid: '5.20'),
        const Cotacao(code: 'EURBRL', name: 'EUR/BRL', bid: '6.10'),
      ];
      final usecase = GetCotacoes(_FakeRepoOk(list));

      final result = await usecase();

      expect(result, isA<List<Cotacao>>());
      expect(result.length, 2);
      expect(result.first.code, 'USDBRL');
    });

    test('deve propagar erro do repositório', () async {
      final usecase = GetCotacoes(_FakeRepoError(Exception('falha')));
      expect(usecase(), throwsA(isA<Exception>()));
    });
  });
}