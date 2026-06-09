import 'dart:convert';

import 'package:http/http.dart' as http;

import '../app_config.dart';
import '../models/livro.dart';

class LivroService {
  final String baseUrl;

  LivroService({String? baseUrl}) : baseUrl = baseUrl ?? AppConfig.baseUrl;

  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  Future<List<Livro>> listarLivros() async {
    final response = await http.get(Uri.parse('$baseUrl/livros'));

    if (response.statusCode != 200) {
      throw Exception('Erro ao listar livros: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) => Livro.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Livro> buscarLivroPorId(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/livros/$id'));

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar livro: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Livro.fromJson(data);
  }

  Future<Livro> criarLivro(Livro livro) async {
    final response = await http.post(
      Uri.parse('$baseUrl/livros'),
      headers: _headers,
      body: jsonEncode(livro.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception(_extrairErro(response.body, 'Erro ao criar livro'));
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Livro.fromJson(data['livro'] as Map<String, dynamic>);
  }

  Future<Livro> atualizarLivro(int id, Livro livro) async {
    final response = await http.put(
      Uri.parse('$baseUrl/livros/$id'),
      headers: _headers,
      body: jsonEncode(livro.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception(_extrairErro(response.body, 'Erro ao atualizar livro'));
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Livro.fromJson(data['livro'] as Map<String, dynamic>);
  }

  Future<void> removerLivro(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/livros/$id'));

    if (response.statusCode != 204) {
      throw Exception(_extrairErro(response.body, 'Erro ao excluir livro'));
    }
  }

  String _extrairErro(String body, String fallback) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      return data['erro'] as String? ?? fallback;
    } catch (_) {
      return fallback;
    }
  }
}
