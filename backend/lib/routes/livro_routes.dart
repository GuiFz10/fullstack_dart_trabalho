import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../database/db.dart';
import '../models/livro.dart';

class LivroRoutes {
  final Router router = Router();
  final DatabaseService database = DatabaseService();

  LivroRoutes() {
    router.get('/livros', _listarLivros);
    router.get('/livros/<id>', _buscarLivroPorId);
    router.post('/livros', _criarLivro);
    router.put('/livros/<id>', _atualizarLivro);
    router.delete('/livros/<id>', _removerLivro);
  }

  Response _jsonResponse(int status, Object body) {
    return Response(
      status,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Response _listarLivros(Request request) {
    final result = database.db.select('SELECT * FROM livros ORDER BY id');
    final livros = result.map((row) => Livro.fromMap(row).toJson()).toList();
    return _jsonResponse(200, livros);
  }

  Response _buscarLivroPorId(Request request, String id) {
    final livroId = int.tryParse(id);
    if (livroId == null) {
      return _jsonResponse(400, {'erro': 'ID inválido.'});
    }

    final result = database.db.select('SELECT * FROM livros WHERE id = ?', [livroId]);
    if (result.isEmpty) {
      return _jsonResponse(404, {'erro': 'Livro não encontrado.'});
    }

    return _jsonResponse(200, Livro.fromMap(result.first).toJson());
  }

  Future<Response> _criarLivro(Request request) async {
    final body = await request.readAsString();
    if (body.isEmpty) {
      return _jsonResponse(400, {'erro': 'Body obrigatório.'});
    }

    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final titulo = data['titulo'];
      final ano = data['ano'];
      final autorId = data['autorId'];

      if (titulo == null || ano == null || autorId == null) {
        return _jsonResponse(400, {'erro': 'Campos titulo, ano e autorId são obrigatórios.'});
      }

      final autorExiste = database.db.select('SELECT id FROM autores WHERE id = ?', [autorId]);
      if (autorExiste.isEmpty) {
        return _jsonResponse(400, {'erro': 'autorId informado não existe.'});
      }

      database.db.execute(
        'INSERT INTO livros (titulo, ano, autor_id) VALUES (?, ?, ?)',
        [titulo, ano, autorId],
      );

      final id = database.db.select('SELECT last_insert_rowid() AS id').first['id'] as int;
      return _jsonResponse(201, {
        'mensagem': 'Livro criado com sucesso.',
        'livro': Livro(id: id, titulo: titulo, ano: ano, autorId: autorId).toJson(),
      });
    } catch (_) {
      return _jsonResponse(400, {'erro': 'JSON inválido.'});
    }
  }

  Future<Response> _atualizarLivro(Request request, String id) async {
    final livroId = int.tryParse(id);
    if (livroId == null) {
      return _jsonResponse(400, {'erro': 'ID inválido.'});
    }

    final body = await request.readAsString();
    if (body.isEmpty) {
      return _jsonResponse(400, {'erro': 'Body obrigatório.'});
    }

    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final titulo = data['titulo'];
      final ano = data['ano'];
      final autorId = data['autorId'];

      if (titulo == null || ano == null || autorId == null) {
        return _jsonResponse(400, {'erro': 'Campos titulo, ano e autorId são obrigatórios.'});
      }

      final autorExiste = database.db.select('SELECT id FROM autores WHERE id = ?', [autorId]);
      if (autorExiste.isEmpty) {
        return _jsonResponse(400, {'erro': 'autorId informado não existe.'});
      }

      database.db.execute(
        'UPDATE livros SET titulo = ?, ano = ?, autor_id = ? WHERE id = ?',
        [titulo, ano, autorId, livroId],
      );

      final total = database.db.select('SELECT changes() AS total').first['total'] as int;
      if (total == 0) {
        return _jsonResponse(404, {'erro': 'Livro não encontrado.'});
      }

      return _jsonResponse(200, {
        'mensagem': 'Livro atualizado com sucesso.',
        'livro': Livro(id: livroId, titulo: titulo, ano: ano, autorId: autorId).toJson(),
      });
    } catch (_) {
      return _jsonResponse(400, {'erro': 'JSON inválido.'});
    }
  }

  Response _removerLivro(Request request, String id) {
    final livroId = int.tryParse(id);
    if (livroId == null) {
      return _jsonResponse(400, {'erro': 'ID inválido.'});
    }

    database.db.execute('DELETE FROM livros WHERE id = ?', [livroId]);
    final total = database.db.select('SELECT changes() AS total').first['total'] as int;

    if (total == 0) {
      return _jsonResponse(404, {'erro': 'Livro não encontrado.'});
    }

    return Response(204, headers: {'Content-Type': 'application/json'});
  }
}
