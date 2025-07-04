class Immobile {
  final int idImmobile;
  final DateTime dataCreazione;
  final DateTime oraCreazione;
  final String usernameAgente;
  final String tipoContratto;
  final String tipologiaImmobile;
  final String titolo;
  final String testo;
  final double superficie;
  final double prezzo;
  final int idIndirizzoImmobile;
  final int idFiltroAvanzato;
  final int idServizioUlteriore;

  Immobile({
    required this.idImmobile,
    required this.dataCreazione,
    required this.oraCreazione,
    required this.usernameAgente,
    required this.tipoContratto,
    required this.tipologiaImmobile,
    required this.titolo,
    required this.testo,
    required this.superficie,
    required this.prezzo,
    required this.idIndirizzoImmobile,
    required this.idFiltroAvanzato,
    required this.idServizioUlteriore,
  });

  factory Immobile.fromJson(Map<String, dynamic> json) {
    return Immobile(
      idImmobile: json['id_immobile'],
      dataCreazione: DateTime.parse(json['data_creazione']),
      oraCreazione: DateTime.parse(json['ora_creazione']),
      usernameAgente: json['username_agente'],
      tipoContratto: json['tipo_contratto'],
      tipologiaImmobile: json['tipologia_immobile'],
      titolo: json['titolo'],
      testo: json['testo'],
      superficie: (json['superficie'] as num).toDouble(),
      prezzo: (json['prezzo'] as num).toDouble(),
      idIndirizzoImmobile: json['id_indirizzo_immobile'],
      idFiltroAvanzato: json['id_filtro_avanzato'],
      idServizioUlteriore: json['id_servizio_ulteriore'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_immobile': idImmobile,
      'data_creazione': dataCreazione.toIso8601String().split('T')[0],
      'ora_creazione': oraCreazione.toIso8601String().split('T')[1],
      'username_agente': usernameAgente,
      'tipo_contratto': tipoContratto,
      'tipologia_immobile': tipologiaImmobile,
      'titolo': titolo,
      'testo': testo,
      'superficie': superficie,
      'prezzo': prezzo,
      'id_indirizzo_immobile': idIndirizzoImmobile,
      'id_filtro_avanzato': idFiltroAvanzato,
      'id_servizio_ulteriore': idServizioUlteriore,
    };
  }
}
