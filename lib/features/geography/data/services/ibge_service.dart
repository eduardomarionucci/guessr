import 'dart:convert';
import 'package:http/http.dart' as http;

class IbgeService {
  Future<List<Map<String, dynamic>>> states() async {
    final response = await http
        .get(
          Uri.parse(
            'https://servicodados.ibge.gov.br/api/v1/localidades/estados?orderBy=nome',
          ),
        )
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw Exception('API do IBGE indisponível.');
    }
    final result = (jsonDecode(utf8.decode(response.bodyBytes)) as List)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();
    if (result.length != 27 ||
        result.any(
          (row) =>
              row['nome'] is! String ||
              row['sigla'] is! String ||
              row['regiao'] is! Map,
        )) {
      throw const FormatException('Resposta inesperada do IBGE.');
    }
    return result;
  }
}
