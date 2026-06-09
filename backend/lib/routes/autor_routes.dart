import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../database/db.dart';
import '../models/autor.dart';
import '../models/livro.dart';

class AutorRoutes {
  final Router router = Router();
  final DatabaseService database = DatabaseService();

  AutorRoutes() {
    router.get('/autores', _listarAutores);
    router.get('/autores/<id>', _buscarAutorPorId);
    router.post('/autores', _criarAutor);
    router.put('/autores/<id>', _atualizarAutor);
    router.delete('/autores/<id>', _removerAutor);
    router.get('/autores/<id>/livros', _listarLivrosDoAutor);
  }

  Response _jsonResponse(int status, Object body) {
    return Response(
      status,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Response _listarAutores(Request request) {
    final result = database.db.select('SELECT * FROM autores ORDER BY id');
    final autores = result.map((row) => Autor.fromMap(row).toJson()).toList();
    return _jsonResponse(200, autores);
  }

  Response _buscarAutorPorId(Request request, String id) {
    final autorId = int.tryParse(id);
    if (autorId == null) {
      return _jsonResponse(400, {'erro': 'ID inválido.'});
    }

    final result = database.db.select('SELECT * FROM autores WHERE id = ?', [autorId]);
    if (result.isEmpty) {
      return _jsonResponse(404, {'erro': 'Autor não encontrado.'});
    }

    return _jsonResponse(200, Autor.fromMap(result.first).toJson());
  }

  Future<Response> _criarAutor(Request request) async {
    final body = await request.readAsString();
    if (body.isEmpty) {
      return _jsonResponse(400, {'erro': 'Body obrigatório.'});
    }

    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final nome = data['nome'];
      final nacionalidade = data['nacionalidade'];

      if (nome == null || nacionalidade == null) {
        return _jsonResponse(400, {'erro': 'Campos nome e nacionalidade são obrigatórios.'});
      }

      database.db.execute(
        'INSERT INTO autores (nome, nacionalidade) VALUES (?, ?)',
        [nome, nacionalidade],
      );

      final id = database.db.select('SELECT last_insert_rowid() AS id').first['id'] as int;
      return _jsonResponse(201, {
        'mensagem': 'Autor criado com sucesso.',
        'autor': Autor(id: id, nome: nome, nacionalidade: nacionalidade).toJson(),
      });
    } catch (_) {
      return _jsonResponse(400, {'erro': 'JSON inválido.'});
    }
  }

  Future<Response> _atualizarAutor(Request request, String id) async {
    final autorId = int.tryParse(id);
    if (autorId == null) {
      return _jsonResponse(400, {'erro': 'ID inválido.'});
    }

    final body = await request.readAsString();
    if (body.isEmpty) {
      return _jsonResponse(400, {'erro': 'Body obrigatório.'});
    }

    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final nome = data['nome'];
      final nacionalidade = data['nacionalidade'];

      if (nome == null || nacionalidade == null) {
        return _jsonResponse(400, {'erro': 'Campos nome e nacionalidade são obrigatórios.'});
      }

      database.db.execute(
        'UPDATE autores SET nome = ?, nacionalidade = ? WHERE id = ?',
        [nome, nacionalidade, autorId],
      );

      final total = database.db.select('SELECT changes() AS total').first['total'] as int;
      if (total == 0) {
        return _jsonResponse(404, {'erro': 'Autor não encontrado.'});
      }

      return _jsonResponse(200, {
        'mensagem': 'Autor atualizado com sucesso.',
        'autor': Autor(id: autorId, nome: nome, nacionalidade: nacionalidade).toJson(),
      });
    } catch (_) {
      return _jsonResponse(400, {'erro': 'JSON inválido.'});
    }
  }

  Response _removerAutor(Request request, String id) {
    final autorId = int.tryParse(id);
    if (autorId == null) {
      return _jsonResponse(400, {'erro': 'ID inválido.'});
    }

    database.db.execute('DELETE FROM autores WHERE id = ?', [autorId]);
    final total = database.db.select('SELECT changes() AS total').first['total'] as int;

    if (total == 0) {
      return _jsonResponse(404, {'erro': 'Autor não encontrado.'});
    }

    return Response(204, headers: {'Content-Type': 'application/json'});
  }

  Response _listarLivrosDoAutor(Request request, String id) {
    final autorId = int.tryParse(id);
    if (autorId == null) {
      return _jsonResponse(400, {'erro': 'ID inválido.'});
    }

    final autor = database.db.select('SELECT * FROM autores WHERE id = ?', [autorId]);
    if (autor.isEmpty) {
      return _jsonResponse(404, {'erro': 'Autor não encontrado.'});
    }

    final result = database.db.select(
      'SELECT * FROM livros WHERE autor_id = ? ORDER BY id',
      [autorId],
    );
    final livros = result.map((row) => Livro.fromMap(row).toJson()).toList();
    return _jsonResponse(200, livros);
  }
}
