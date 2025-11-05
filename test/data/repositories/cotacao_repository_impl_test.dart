import 'package:flutter_test/flutter_test.dart';
import 'package:sicredo/data/datasources/cotacao_remote_data_source.dart';
import 'package:sicredo/data/repositories/cotacao_repository_impl.dart';

class _FakeRemoteOK implements CotacaoRemoteDataSource {
  final Map<String, dynamic> payload;
  _FakeRemoteOK(this.payload);

  @override
  Future<Map<String, dynamic>> fetchCotacoesRaw() async => payload;
}

class _FakeRemoteError implements CotacaoRemoteDataSource {
  final Object error;
  _FakeRemoteError(this.error);

  @override
  Future<Map<String, dynamic>> fetchCotacoesRaw() => Future.error(error);
}

void main() {
  group('CotacaoRepositoryImpl', () {
    test('deve mapear USDBRL/EURBRL/BTCBRL para entidades', () async {
      final payload = {
        'USDBRL': {'name': 'Dólar', 'bid': '5.20'},
        'EURBRL': {'name': 'Euro', 'bid': '6.10'},
        'BTCBRL': {'name': 'Bitcoin', 'bid': '300000.00'},
      };
      final repo = CotacaoRepositoryImpl(_FakeRemoteOK(payload));

      final list = await repo.getCotacoes();

      expect(list.length, 3);
      expect(list[0].code, 'USDBRL');
      expect(list[1].name, 'Euro');
      expect(list[2].bid, '300000.00');
    });

    test('deve ignorar chaves ausentes', () async {
      final payload = {
        'USDBRL': {'name': 'Dólar', 'bid': '5.20'},
        // EURBRL ausente
        // BTCBRL ausente
      };
      final repo = CotacaoRepositoryImpl(_FakeRemoteOK(payload));

      final list = await repo.getCotacoes();

      expect(list.length, 1);
      expect(list.first.code, 'USDBRL');
    });

    test('deve propagar erro do data source', () async {
      final repo = CotacaoRepositoryImpl(_FakeRemoteError(Exception('falha')));
      expect(repo.getCotacoes(), throwsA(isA<Exception>()));
    });
  });
}