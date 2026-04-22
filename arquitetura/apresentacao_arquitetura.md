# Apresentação da Arquitetura

## Slide 1 — Tema do projeto
- Biblioteca
- Backend em Dart + Shelf
- Frontend em Flutter
- Banco de dados SQLite

## Slide 2 — Entidades
- Autor (pai)
- Livro (filho)
- Relacionamento 1:N

## Slide 3 — Fluxo da aplicação
- Flutter faz requisição HTTP
- API Dart recebe a requisição
- API acessa o banco SQLite
- API retorna JSON
- Flutter exibe os dados em lista

## Slide 4 — Backend
- `bin/server.dart` como ponto de entrada
- Rotas separadas por entidade
- Modelos com classes tipadas e `toJson()`
- SQLite para persistência

## Slide 5 — Postman
- Coleção organizada em duas pastas
- Autores
- Livros
- 11 requests documentados
- Variável `{{base_url}}`

## Slide 6 — Frontend Flutter
- `StatefulWidget`
- `initState()` para carregar os dados
- `http.get()` para buscar livros
- `ListView.builder` para exibição
- `CircularProgressIndicator` e tratamento de erro

## Slide 7 — Conclusão
- Projeto full stack funcional
- API, documentação, frontend e arquitetura integrados
- Estrutura pronta para entrega no GitHub
