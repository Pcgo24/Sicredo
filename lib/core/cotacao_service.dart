import 'dart:convert';
import 'package:http/http.dart' as http;

class CotacaoService {
  /// Busca cotações da API AwesomeAPI (USD, EUR, BTC em relação ao BRL)
  /// Retorna um Map com os dados decodificados ou lança uma exceção em caso de erro.
  static Future<Map<String, dynamic>> buscarCotacoes() async {
    final url = Uri.parse(
        'https://economia.awesomeapi.com.br/json/last/USD-BRL,EUR-BRL,BTC-BRL');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Erro ao buscar cotações: ${response.statusCode}');
    }
  }
}
