import 'dart:convert';

import 'package:http/http.dart' as http;

import '../app_config.dart';
import '../models/autor.dart';

class AutorService {
  final String baseUrl;

  AutorService({String? baseUrl}) : baseUrl = baseUrl ?? AppConfig.baseUrl;

  Future<List<Autor>> listarAutores() async {
    final response = await http.get(Uri.parse('$baseUrl/autores'));

    if (response.statusCode != 200) {
      throw Exception('Erro ao listar autores: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) => Autor.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Autor> buscarAutorPorId(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/autores/$id'));

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar autor: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Autor.fromJson(data);
  }
}
