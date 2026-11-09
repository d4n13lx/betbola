import 'dart:convert';

class Partida {
  final int id;
  final Campeonato campeonato;
  final String placar;
  final TimeAnte timeMandante;
  final TimeAnte timeVisitante;
  final int placarMandante;
  final int placarVisitante;
  final bool disputaPenalti;
  final String status;
  final String slug;
  final String dataRealizacao;
  final String horaRealizacao;
  final String dataRealizacaoIso;
  final Estadio estadio;
  final String link;

  Partida({
    required this.id,
    required this.campeonato,
    required this.placar,
    required this.timeMandante,
    required this.timeVisitante,
    required this.placarMandante,
    required this.placarVisitante,
    required this.disputaPenalti,
    required this.status,
    required this.slug,
    required this.dataRealizacao,
    required this.horaRealizacao,
    required this.dataRealizacaoIso,
    required this.estadio,
    required this.link,
  });

  factory Partida.fromJson(String str) => Partida.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Partida.fromMap(Map<String, dynamic> json) => Partida(
        id: json["partida_id"],
        campeonato: Campeonato.fromMap(json["campeonato"]),
        placar: json["placar"],
        timeMandante: TimeAnte.fromMap(json["time_mandante"]),
        timeVisitante: TimeAnte.fromMap(json["time_visitante"]),
        placarMandante: json["placar_mandante"],
        placarVisitante: json["placar_visitante"],
        disputaPenalti: json["disputa_penalti"],
        status: json["status"],
        slug: json["slug"],
        dataRealizacao: json["data_realizacao"],
        horaRealizacao: json["hora_realizacao"],
        dataRealizacaoIso: json["data_realizacao_iso"],
        estadio: Estadio.fromMap(json["estadio"]),
        link: json["_link"],
      );

  Map<String, dynamic> toMap() => {
        "partida_id": id,
        "campeonato": campeonato.toMap(),
        "placar": placar,
        "time_mandante": timeMandante.toMap(),
        "time_visitante": timeVisitante.toMap(),
        "placar_mandante": placarMandante,
        "placar_visitante": placarVisitante,
        "disputa_penalti": disputaPenalti,
        "status": status,
        "slug": slug,
        "data_realizacao": dataRealizacao,
        "hora_realizacao": horaRealizacao,
        "data_realizacao_iso": dataRealizacaoIso,
        "estadio": estadio.toMap(),
        "_link": link,
      };
}

class Campeonato {
  final int campeonatoId;
  final String nome;
  final String slug;

  Campeonato({
    required this.campeonatoId,
    required this.nome,
    required this.slug,
  });

  factory Campeonato.fromJson(String str) =>
      Campeonato.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Campeonato.fromMap(Map<String, dynamic> json) => Campeonato(
        campeonatoId: json["campeonato_id"],
        nome: json["nome"],
        slug: json["slug"],
      );

  Map<String, dynamic> toMap() => {
        "campeonato_id": campeonatoId,
        "nome": nome,
        "slug": slug,
      };
}

class Estadio {
  final int estadioId;
  final String nomePopular;

  Estadio({
    required this.estadioId,
    required this.nomePopular,
  });

  factory Estadio.fromJson(String str) => Estadio.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Estadio.fromMap(Map<String, dynamic> json) => Estadio(
        estadioId: json["estadio_id"],
        nomePopular: json["nome_popular"],
      );

  Map<String, dynamic> toMap() => {
        "estadio_id": estadioId,
        "nome_popular": nomePopular,
      };
}

class TimeAnte {
  final int timeId;
  final String nomePopular;
  final String sigla;
  final String escudo;

  TimeAnte({
    required this.timeId,
    required this.nomePopular,
    required this.sigla,
    required this.escudo,
  });

  factory TimeAnte.fromJson(String str) => TimeAnte.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory TimeAnte.fromMap(Map<String, dynamic> json) => TimeAnte(
        timeId: json["time_id"],
        nomePopular: json["nome_popular"],
        sigla: json["sigla"],
        escudo: json["escudo"],
      );

  Map<String, dynamic> toMap() => {
        "time_id": timeId,
        "nome_popular": nomePopular,
        "sigla": sigla,
        "escudo": escudo,
      };
}
