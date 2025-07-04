class Modifica {
  final int idModifica;
  final int idImmobile;
  final String usernameAgente;
  final DateTime dataModifica;
  final DateTime oraModifica;
  final String nuovoTipoContratto;
  final String nuovaTipologiaImmobile;
  final String nuovoTitolo;
  final String nuovoTesto;
  final double nuovaSuperficie;
  final double nuovoPrezzo;
  final int nuovoIdIndirizzoImmobile;
  final int nuovoIdFiltroAvanzato;
  final int nuovoIdServizioUlteriore;

  Modifica({
    required this.idModifica,
    required this.idImmobile,
    required this.usernameAgente,
    required this.dataModifica,
    required this.oraModifica,
    required this.nuovoTipoContratto,
    required this.nuovaTipologiaImmobile,
    required this.nuovoTitolo,
    required this.nuovoTesto,
    required this.nuovaSuperficie,
    required this.nuovoPrezzo,
    required this.nuovoIdIndirizzoImmobile,
    required this.nuovoIdFiltroAvanzato,
    required this.nuovoIdServizioUlteriore,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_modifica': idModifica,
      'id_immobile': idImmobile,
      'username_agente': usernameAgente,
      'data_modifica': dataModifica.toIso8601String().split('T')[0],
      'ora_modifica': oraModifica.toIso8601String().split('T')[1],
      'nuovo_tipo_contratto': nuovoTipoContratto,
      'nuova_tipologia_immobile': nuovaTipologiaImmobile,
      'nuovo_titolo': nuovoTitolo,
      'nuovo_testo': nuovoTesto,
      'nuova_superficie': nuovaSuperficie,
    };
  }

  factory Modifica.fromJson(Map<String, dynamic> json) {
    return Modifica(
      idModifica: json['id_modifica'],
      idImmobile: json['id_immobile'],
      usernameAgente: json['username_agente'],
      dataModifica: DateTime.parse(json['data_modifica']),
      oraModifica: DateTime.parse("1970-01-01T${json['ora_modifica']}"),
      nuovoTipoContratto: json['nuovo_tipo_contratto'],
      nuovaTipologiaImmobile: json['nuova_tipologia_immobile'],
      nuovoTitolo: json['nuovo_titolo'],
      nuovoTesto: json['nuovo_testo'],
      nuovaSuperficie: (json['nuova_superficie'] as num).toDouble(),
      nuovoPrezzo: (json['nuovo_prezzo'] as num).toDouble(),
      nuovoIdIndirizzoImmobile: json['nuovo_id_indirizzo_immobile'],
      nuovoIdFiltroAvanzato: json['nuovo_id_filtro_avanzato'],
      nuovoIdServizioUlteriore: json['nuovo_id_servizio_ulteriore'],
    );
  }
}
