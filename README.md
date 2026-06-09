# Trabalho Prático — Flutter CRUD Completo

Projeto desenvolvido para a disciplina de **Tópicos Especiais**.

## Tema do projeto
**Biblioteca**

## Descrição
Este trabalho consiste em uma aplicação fullstack com:

- **Backend** em Dart + Shelf
- **Frontend** em Flutter
- **Banco de dados** SQLite
- **Postman** para testes dos endpoints

O projeto evolui a versão anterior, que possuía apenas uma tela de listagem, para uma versão com **CRUD completo** no app Flutter.

## Funcionalidades do app
O aplicativo permite:

- listar livros cadastrados
- visualizar o detalhe de um livro
- criar um novo livro
- editar um livro existente
- excluir um livro com confirmação

## Entidades
### Autor
- id
- nome
- nacionalidade

### Livro
- id
- título
- ano
- autorId

## Estrutura do projeto

```text
fullstack_dart_trabalho/
├── backend/
├── frontend/
├── postman/
├── docs/
└── README.md
Estrutura do frontend
frontend/lib/
├── models/
│   ├── autor.dart
│   └── livro.dart
├── services/
│   ├── autor_service.dart
│   └── livro_service.dart
├── screens/
│   ├── lista_page.dart
│   ├── detalhe_page.dart
│   └── formulario_page.dart
├── app_config.dart
└── main.dart
Tecnologias utilizadas
Backend
Dart
Shelf
Shelf Router
SQLite
Frontend
Flutter
Dart
pacote http
Testes
Postman
Como rodar o backend

Abra o terminal na pasta backend e execute:

cd backend
dart pub get
dart run bin/server.dart

A API ficará disponível em:

http://localhost:8081
Como rodar o frontend

Abra outro terminal na pasta frontend e execute:

cd frontend
flutter pub get
flutter run -d chrome
URL base da API

A URL base utilizada no frontend está em:

frontend/lib/app_config.dart

Base configurada:

http://localhost:8081
Rotas principais da API
Autores
GET /autores
GET /autores/:id
POST /autores
PUT /autores/:id
DELETE /autores/:id
Livros
GET /livros
GET /livros/:id
GET /autores/:id/livros
POST /livros
PUT /livros/:id
DELETE /livros/:id
Diagrama

O diagrama de navegação e arquitetura está disponível na pasta:

docs/
Postman

A coleção utilizada para testar a API está na pasta:

postman/collection.json
Evolução do projeto
Versão anterior
tela de listagem conectada à API
Versão atual
listagem
detalhe
criação
edição
exclusão com confirmação