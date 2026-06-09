import 'package:flutter/material.dart';

import '../models/autor.dart';
import '../models/livro.dart';
import '../services/autor_service.dart';
import '../services/livro_service.dart';

class FormularioPage extends StatefulWidget {
  final Livro? livro;

  const FormularioPage({super.key, this.livro});

  @override
  State<FormularioPage> createState() => _FormularioPageState();
}

class _FormularioPageState extends State<FormularioPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _anoController = TextEditingController();

  final LivroService _livroService = LivroService();
  final AutorService _autorService = AutorService();

  List<Autor> _autores = [];
  int? _autorIdSelecionado;
  bool _carregandoAutores = true;
  bool _salvando = false;
  String? _erroAutores;

  bool get _modoEdicao => widget.livro != null;

  @override
  void initState() {
    super.initState();
    final livro = widget.livro;
    if (livro != null) {
      _tituloController.text = livro.titulo;
      _anoController.text = livro.ano.toString();
      _autorIdSelecionado = livro.autorId;
    }
    _carregarAutores();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _anoController.dispose();
    super.dispose();
  }

  Future<void> _carregarAutores() async {
    setState(() {
      _carregandoAutores = true;
      _erroAutores = null;
    });

    try {
      final autores = await _autorService.listarAutores();
      if (!mounted) return;
      setState(() {
        _autores = autores;
        if (_autorIdSelecionado == null && autores.isNotEmpty) {
          _autorIdSelecionado = autores.first.id;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erroAutores = 'Não foi possível carregar os autores.\n$e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _carregandoAutores = false;
      });
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_autorIdSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um autor.')),
      );
      return;
    }

    final livro = Livro(
      id: widget.livro?.id,
      titulo: _tituloController.text.trim(),
      ano: int.parse(_anoController.text.trim()),
      autorId: _autorIdSelecionado!,
    );

    setState(() {
      _salvando = true;
    });

    try {
      if (_modoEdicao) {
        await _livroService.atualizarLivro(widget.livro!.id!, livro);
      } else {
        await _livroService.criarLivro(livro);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _modoEdicao ? 'Livro atualizado com sucesso.' : 'Livro criado com sucesso.',
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar livro: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _salvando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modoEdicao ? 'Editar Livro' : 'Novo Livro'),
      ),
      body: Stack(
        children: [
          if (_carregandoAutores)
            const Center(child: CircularProgressIndicator())
          else if (_erroAutores != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_erroAutores!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _carregarAutores,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            )
          else
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _tituloController,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe o título do livro.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _anoController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Ano',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe o ano.';
                        }
                        if (int.tryParse(value.trim()) == null) {
                          return 'Informe um ano válido.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _autorIdSelecionado,
                      decoration: const InputDecoration(
                        labelText: 'Autor',
                        border: OutlineInputBorder(),
                      ),
                      items: _autores
                          .map(
                            (autor) => DropdownMenuItem<int>(
                              value: autor.id,
                              child: Text('${autor.nome} (${autor.id})'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _autorIdSelecionado = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Selecione um autor.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _salvando ? null : () => Navigator.of(context).pop(),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: _salvando ? null : _salvar,
                            child: Text(_modoEdicao ? 'Salvar alterações' : 'Criar livro'),
                          ),
                        ),
                      ],
                    ),
                    if (_autores.isEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Cadastre autores pela API antes de criar livros.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          if (_salvando)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
