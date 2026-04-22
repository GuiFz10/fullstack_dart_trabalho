class Livro {
  final int? id;
  final String titulo;
  final int ano;
  final int autorId;

  Livro({
    this.id,
    required this.titulo,
    required this.ano,
    required this.autorId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'ano': ano,
      'autorId': autorId,
    };
  }

  factory Livro.fromMap(Map<String, Object?> map) {
    return Livro(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      ano: map['ano'] as int,
      autorId: map['autor_id'] as int,
    );
  }
}
