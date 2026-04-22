# Trabalho Prático — Full Stack com Dart

Projeto individual da disciplina de **Tópicos Especiais**.

## Tema escolhido
**Biblioteca**

### Entidades
- **Autor** (entidade pai)
- **Livro** (entidade filho)

### Relacionamento
Um **autor** pode ter **vários livros** (`1:N`).

---

## Estrutura do repositório

```bash
fullstack_dart_trabalho/
├── backend/
├── frontend/
├── postman/
├── arquitetura/
└── README.md
```

---

## Backend
API REST desenvolvida com **Dart + Shelf + SQLite**.

### Como instalar dependências
```bash
dart pub get
```

### Como rodar o servidor
```bash
dart run bin/server.dart
```

### URL base
```bash
http://localhost:8081
```

### Rotas da API
#### Autores
- `GET /autores`
- `GET /autores/:id`
- `POST /autores`
- `PUT /autores/:id`
- `DELETE /autores/:id`

#### Livros
- `GET /livros`
- `GET /livros/:id`
- `GET /autores/:id/livros`
- `POST /livros`
- `PUT /livros/:id`
- `DELETE /livros/:id`

---

## Postman
A coleção exportada está em:

```bash
postman/collection.json
```

A variável `{{base_url}}` já está configurada para:

```bash
http://localhost:8080
```

---

## Frontend Flutter
Tela simples de listagem da entidade filha (**livros**), usando o pacote `http`.

### Como instalar dependências
```bash
flutter pub get
```

### Como rodar o app Flutter
```bash
flutter run
```

> Observação: no emulador Android, a URL base usada foi `http://10.0.2.2:8080`.

---

## Arquitetura
A apresentação da arquitetura está em:

```bash
arquitetura/apresentacao_arquitetura.md
```

---

## Status HTTP utilizados
- `200 OK`
- `201 Created`
- `204 No Content`
- `400 Bad Request`
- `404 Not Found`

---

## Observações finais
O projeto segue o requisito de duas entidades com relacionamento `1:N`, respostas em JSON, uso de POO com classes e `toJson()`, coleção Postman organizada e tela Flutter consumindo a própria API.
