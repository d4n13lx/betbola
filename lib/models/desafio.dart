class Desafio {
  final int id;
  final String pergunta;
  final String tipo;

  Desafio({required this.id, required this.pergunta, required this.tipo});

  factory Desafio.fromMap(Map<String, dynamic> json) => Desafio(
        id: json['id'],
        pergunta: json['pergunta'],
        tipo: json['tipo'],
      );
}
