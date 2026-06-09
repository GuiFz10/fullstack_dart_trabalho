class Autor {
  final int? id;
  final String nome;
  final String nacionalidade;

  Autor({this.id, required this.nome, required this.nacionalidade});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'nacionalidade': nacionalidade,
    };
  }

  factory Autor.fromMap(Map<String, Object?> map) {
    return Autor(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      nacionalidade: map['nacionalidade'] as String,
    );
  }
}
