import 'package:flutter/material.dart';

import '../models/autor.dart';
import '../models/livro.dart';
import '../services/autor_service.dart';
import '../services/livro_service.dart';
import 'formulario_page.dart';

class DetalhePage extends StatefulWidget {
  final int livroId;

  const DetalhePage({super.key, required this.livroId});

  @override
  State<DetalhePage> createState() => _DetalhePageState();
}

class _DetalhePageState extends State<DetalhePage> {
  final LivroService _livroService = LivroService();
  final AutorService _autorService = AutorService();

  Livro? _livro;
  Autor? _autor;
  bool _carregando = true;
  bool _excluindo = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarDetalhes();
  }

  Future<void> _carregarDetalhes() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final livro = await _livroService.buscarLivroPorId(widget.livroId);
      Autor? autor;
      try {
        autor = await _autorService.buscarAutorPorId(livro.autorId);
      } catch (_) {
        autor = null;
      }

      if (!mounted) return;
      setState(() {
        _livro = livro;
        _autor = autor;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível carregar o detalhe.\n$e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _carregando = false;
      });
    }
  }

  Future<void> _editarLivro() async {
    if (_livro == null) return;

    final resultado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => FormularioPage(livro: _livro)),
    );

    if (resultado == true) {
      _carregarDetalhes();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Livro atualizado com sucesso.')),
      );
    }
  }

  Future<void> _confirmarExclusao() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir livro'),
          content: const Text('Tem certeza que deseja excluir este livro?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      _excluirLivro();
    }
  }

  Future<void> _excluirLivro() async {
    final livro = _livro;
    if (livro == null || livro.id == null) return;

    setState(() {
      _excluindo = true;
    });

    try {
      await _livroService.removerLivro(livro.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Livro excluído com sucesso.')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir livro: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _excluindo = false;
      });
    }
  }

  Widget _campoDetalhe(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe do Livro')),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_erro!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _carregarDetalhes,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                )
              : _livro == null
                  ? const Center(child: Text('Livro não encontrado.'))
                  : Stack(
                      children: [
                        ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _livro!.titulo,
                                      style: Theme.of(context).textTheme.headlineSmall,
                                    ),
                                    const SizedBox(height: 16),
                                    _campoDetalhe('ID', '${_livro!.id}'),
                                    _campoDetalhe('Título', _livro!.titulo),
                                    _campoDetalhe('Ano', '${_livro!.ano}'),
                                    _campoDetalhe('Autor ID', '${_livro!.autorId}'),
                                    _campoDetalhe(
                                      'Autor',
                                      _autor != null
                                          ? '${_autor!.nome} (${_autor!.nacionalidade})'
                                          : 'Autor não carregado',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: _editarLivro,
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Editar'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _confirmarExclusao,
                                    icon: const Icon(Icons.delete_outline),
                                    label: const Text('Excluir'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (_excluindo)
                          Container(
                            color: Colors.black26,
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                      ],
                    ),
    );
  }
}
