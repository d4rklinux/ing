class Proposta {
  final int idProposta;
  final int idImmobileProposta;
  final double vecchioPrezzo;
  final double nuovoPrezzo;
  final String statoProposta;
  final DateTime dataProposta;
  final DateTime oraProposta;
  final String usernameUtenteProposta;
  final String usernameAgenteControProposta;
  final double controProposta;
  final String statoControProposta;

  Proposta({
    required this.idProposta,
    required this.idImmobileProposta,
    required this.vecchioPrezzo,
    required this.nuovoPrezzo,
    required this.statoProposta,
    required this.dataProposta,
    required this.oraProposta,
    required this.usernameUtenteProposta,
    required this.usernameAgenteControProposta,
    required this.controProposta,
    required this.statoControProposta,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_proposta': idProposta,
      'id_immobile_proposta': idImmobileProposta,
      'vecchio_prezzo': vecchioPrezzo,
      'nuovo_prezzo': nuovoPrezzo,
      'stato_proposta': statoProposta,
      'data_proposta': dataProposta.toIso8601String().split('T')[0],
      'ora_proposta': oraProposta.toIso8601String().split('T')[1],
      'username_utente_proposta': usernameUtenteProposta,
      'username_agente_contro_proposta': usernameAgenteControProposta,
      'contro_proposta': controProposta,
      'stato_contro_proposta': statoControProposta,
    };
  }

  factory Proposta.fromJson(Map<String, dynamic> json) {
    return Proposta(
      idProposta: json['id_proposta'],
      idImmobileProposta: json['id_immobile_proposta'],
      vecchioPrezzo: (json['vecchio_prezzo'] as num).toDouble(),
      nuovoPrezzo: (json['nuovo_prezzo'] as num).toDouble(),
      statoProposta: json['stato_proposta'],
      dataProposta: DateTime.parse(json['data_proposta']),
      oraProposta: DateTime.parse(json['ora_proposta']),
      usernameUtenteProposta: json['username_utente_proposta'],
      usernameAgenteControProposta: json['username_agente_contro_proposta'],
      controProposta: (json['contro_proposta'] as num).toDouble(),
      statoControProposta: json['stato_contro_proposta'],
    );
  }
}
