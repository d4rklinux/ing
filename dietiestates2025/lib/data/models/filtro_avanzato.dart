class FiltroAvanzato {
  final int idFiltroAvanzato;
  final String tipologiaImmobile;
  final int stanza;
  final int piano;
  final int bagno;
  final String parcheggio;
  final String classeEnergetica;

  FiltroAvanzato({
    required this.idFiltroAvanzato,
    required this.tipologiaImmobile,
    required this.stanza,
    required this.piano,
    required this.bagno,
    required this.parcheggio,
    required this.classeEnergetica,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_filtro_avanzato': idFiltroAvanzato,
      'tipologia_immobile': tipologiaImmobile,
      'stanza': stanza,
      'piano': piano,
      'bagno': bagno,
      'parcheggio': parcheggio,
      'classe_energetica': classeEnergetica,
    };
  }

  factory FiltroAvanzato.fromJson(Map<String, dynamic> json) {
    return FiltroAvanzato(
      idFiltroAvanzato: json['id_filtro_avanzato'],
      tipologiaImmobile: json['tipologia_immobile'],
      stanza: json['stanza'],
      piano: json['piano'],
      bagno: json['bagno'],
      parcheggio: json['parcheggio'],
      classeEnergetica: json['classe_energetica'],
    );
  }
}
