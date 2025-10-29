import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart'; // Importa o MockClient
import 'package:sicredo/core/cotacao_service.dart';

void main() {
  group('CotacaoService Unit Tests', () {
    // 1. Define uma resposta JSON de sucesso mockada
    final mockSuccessResponse = json.encode({
      "USDBRL": {"name": "Dólar Americano/Real Brasileiro", "bid": "5.20"},
      "EURBRL": {"name": "Euro/Real Brasileiro", "bid": "6.10"},
      "BTCBRL": {"name": "Bitcoin/Real Brasileiro", "bid": "300000.00"}
    });

    // 2. Define a URL exata que o serviço chama
    final targetUrl = Uri.parse(
        'https://economia.awesomeapi.com.br/json/last/USD-BRL,EUR-BRL,BTC-BRL');

    test('TU-01: Deve retornar o Map de cotações em caso de sucesso (200)',
        () async {
      // Arrange: Cria um cliente mock que retorna 200 OK
      final mockClient = MockClient((request) async {
        // Verifica se a URL chamada no teste é a mesma do serviço
        expect(request.url, targetUrl);
        return http.Response(mockSuccessResponse, 200);
      });

      // Act
      final data = await http.runWithClient(
        () => CotacaoService.buscarCotacoes(),
        () => mockClient,
      );

      // Assert
      expect(data, isA<Map<String, dynamic>>());
      expect(data['USDBRL']['bid'], '5.20');
      expect(data['EURBRL']['name'], 'Euro/Real Brasileiro');
    });

    test('TU-02: Deve lançar uma Exception em caso de erro (ex: 404)', () async {
      // Arrange: Cria um cliente mock que retorna 404 Not Found
      final mockClient = MockClient((request) async {
        expect(request.url, targetUrl);
        return http.Response('Not Found', 404);
      });

      // Act
      final futureCall = http.runWithClient(
        () => CotacaoService.buscarCotacoes(),
        () => mockClient,
      );

      // Assert
      expect(futureCall, throwsA(isA<Exception>()));
    });
  });
}