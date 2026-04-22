import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Biblioteca App',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const LivrosPage(),
    );
  }
}

class Livro {
  final int id;
  final String titulo;
  final int ano;
  final int autorId;

  Livro({
    required this.id,
    required this.titulo,
    required this.ano,
    required this.autorId,
  });

  factory Livro.fromJson(Map<String, dynamic> json) {
    return Livro(
      id: json['id'] as int,
      titulo: json['titulo'] as String,
      ano: json['ano'] as int,
      autorId: json['autorId'] as int,
    );
  }
}

class LivrosPage extends StatefulWidget {
  const LivrosPage({super.key});

  @override
  State<LivrosPage> createState() => _LivrosPageState();
}

class _LivrosPageState extends State<LivrosPage> {
  final String baseUrl = 'http://10.0.2.2:8080';
  List<Livro> _itens = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/livros'));

      if (response.statusCode == 200) {
        final List<dynamic> dados = jsonDecode(response.body);
        setState(() {
          _itens = dados.map((e) => Livro.fromJson(e)).toList();
          _carregando = false;
        });
      } else {
        setState(() {
          _erro = 'Erro ao carregar livros: ${response.statusCode}';
          _carregando = false;
        });
      }
    } catch (e) {
      setState(() {
        _erro = 'Falha na requisição: $e';
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Livros')),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _erro!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _itens.length,
                  itemBuilder: (context, index) {
                    final livro = _itens[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(livro.titulo),
                        subtitle: Text('Ano: ${livro.ano} | Autor ID: ${livro.autorId}'),
                      ),
                    );
                  },
                ),
    );
  }
}
