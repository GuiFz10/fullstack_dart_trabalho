import 'package:flutter/material.dart';

import '../models/livro.dart';
import '../services/autor_service.dart';
import '../services/livro_service.dart';
import 'detalhe_page.dart';
import 'formulario_page.dart';

class ListaPage extends StatefulWidget {
  const ListaPage({super.key});

  @override
  State<ListaPage> createState() => _ListaPageState();
}

class _ListaPageState extends State<ListaPage> {
  final LivroService _livroService = LivroService();
  final AutorService _autorService = AutorService();

  List<Livro> _livros = [];
  Map<int, String> _autoresPorId = {};

  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarLivros();
  }

  Future<void> _carregarLivros() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final livros = await _livroService.listarLivros();
      final autores = await _autorService.listarAutores();

      final mapaAutores = <int, String>{};
      for (final autor in autores) {
        mapaAutores[autor.id] = autor.nome;
      }

      if (!mounted) return;
      setState(() {
        _livros = livros;
        _autoresPorId = mapaAutores;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível carregar os livros.\n$e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _carregando = false;
      });
    }
  }

  Future<void> _abrirFormularioCriacao() async {
    final resultado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const FormularioPage()),
    );

    if (resultado == true) {
      _carregarLivros();
    }
  }

  Future<void> _abrirDetalhe(Livro livro) async {
    final resultado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => DetalhePage(livroId: livro.id!)),
    );

    if (resultado == true) {
      _carregarLivros();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca - Livros'),
        actions: [
          IconButton(
            onPressed: _carregarLivros,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar lista',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirFormularioCriacao,
        icon: const Icon(Icons.add),
        label: const Text('Novo livro'),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _erro!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _carregarLivros,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                )
              : _livros.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum livro cadastrado.',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _carregarLivros,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _livros.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final livro = _livros[index];
                          final nomeAutor =
                              _autoresPorId[livro.autorId] ?? 'Autor não encontrado';

                          return Card(
                            child: ListTile(
                              onTap: () => _abrirDetalhe(livro),
                              leading: const CircleAvatar(
                                child: Icon(Icons.menu_book_outlined),
                              ),
                              title: Text(livro.titulo),
                              subtitle: Text(
                                'Ano: ${livro.ano} • Autor: $nomeAutor',
                              ),
                              trailing: const Icon(Icons.chevron_right),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}