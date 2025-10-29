import 'dart:convert';
import 'package:http/http.dart' as http;

class CotacaoService {
  static Future<Map<String, dynamic>> buscarCotacoes() async {
    final url = Uri.parse('https://economia.awesomeapi.com.br/json/last/USD-BRL,EUR-BRL,BTC-BRL');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao carregar cotações');
    }
  }
}