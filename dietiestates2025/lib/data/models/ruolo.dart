class Ruolo {
  final int idRuolo;
  final String nomeRuolo;

  Ruolo({
    required this.idRuolo,
    required this.nomeRuolo,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_ruolo': idRuolo,
      'nome_ruolo': nomeRuolo,
    };
  }

  factory Ruolo.fromJson(Map<String, dynamic> json) {
    return Ruolo(
      idRuolo: json['id_ruolo'],
      nomeRuolo: json['nome_ruolo'],
    );
  }
}

