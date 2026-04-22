import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

import '../lib/routes/autor_routes.dart';
import '../lib/routes/livro_routes.dart';

void main() async {
  final autorRoutes = AutorRoutes();
  final livroRoutes = LivroRoutes();

  final app = Router()
    ..mount('/', autorRoutes.router)
    ..mount('/', livroRoutes.router)
    ..get('/', (Request request) {
      return Response.ok(
        '{"mensagem":"API Biblioteca funcionando"}',
        headers: {'Content-Type': 'application/json'},
      );
    });

  final handler = Pipeline().addMiddleware(logRequests()).addHandler(app.call);

  final server = await io.serve(handler, InternetAddress.anyIPv4, 8080);
  print('Servidor rodando em http://localhost:${server.port}');
}
