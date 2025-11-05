import 'package:sicredo/domain/entities/cotacao.dart';

class CotacaoModel {
  final String code;
  final String name;
  final String bid;

  CotacaoModel({
    required this.code,
    required this.name,
    required this.bid,
  });

  factory CotacaoModel.fromMap(String code, Map<String, dynamic> map) {
    return CotacaoModel(
      code: code,
      name: (map['name'] ?? '').toString(),
      bid: (map['bid'] ?? '').toString(),
    );
  }

  Cotacao toEntity() => Cotacao(code: code, name: name, bid: bid);
}