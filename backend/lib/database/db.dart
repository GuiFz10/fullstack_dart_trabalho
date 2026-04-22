import 'package:sqlite3/sqlite3.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() => _instance;

  late final Database db;

  DatabaseService._internal() {
    db = sqlite3.open('biblioteca.db');
    db.execute('PRAGMA foreign_keys = ON;');
    _createTables();
  }

  void _createTables() {
    db.execute('''
      CREATE TABLE IF NOT EXISTS autores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        nacionalidade TEXT NOT NULL
      )
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS livros (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        ano INTEGER NOT NULL,
        autor_id INTEGER NOT NULL,
        FOREIGN KEY (autor_id) REFERENCES autores(id) ON DELETE CASCADE
      )
    ''');
  }
}
