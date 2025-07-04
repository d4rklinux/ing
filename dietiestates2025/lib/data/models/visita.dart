class Visita {
  final int idVisita;
  final int idImmobile;
  final String usernameUtente;
  final DateTime dataVisita;
  final DateTime oraVisita;
  final String statoVisita;
  final String statoApprovazioneAgente;
  final String usernameAgenteApprovazione;

  Visita( {
    required this.idVisita,
    required this.idImmobile,
    required this.usernameUtente,
    required this.dataVisita,
    required this.oraVisita,
    required this.statoVisita,
    required this.statoApprovazioneAgente,
    required this.usernameAgenteApprovazione,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_visita': idVisita,
      'id_immobile': idImmobile,
      'username_utente': usernameUtente,
      'data_visita': dataVisita.toIso8601String().split('T')[0],
      'ora_visita': oraVisita.toIso8601String().split('T')[1],
      'stato_visita': statoVisita,
      'stato_approvazione_agente': statoApprovazioneAgente,
      'username_agente_approvazione': usernameAgenteApprovazione,
    };
  }

  factory Visita.fromJson(Map<String, dynamic> json) {
    return Visita(
      idVisita: json['id_visita'],
      idImmobile: json['id_immobile'],
      usernameUtente: json['username_utente'],
      dataVisita: DateTime.parse(json['data_visita']),
      oraVisita: DateTime.parse(json['ora_visita']),
      statoVisita: json['stato_visita'],
      statoApprovazioneAgente: json['stato_approvazione_agente'],
      usernameAgenteApprovazione: json['username_agente_approvazione'],
    );
  }
}
