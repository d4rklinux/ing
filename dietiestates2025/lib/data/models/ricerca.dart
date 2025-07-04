class Ricerca {
  final int idRicerca;
  final int idIndirizzo;
  final int idFiltroAvanzato;


  Ricerca({
    required this.idRicerca,
    required this.idIndirizzo,
    required this.idFiltroAvanzato,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_ricerca': idRicerca,
      'id_indirizzo': idIndirizzo,
      'id_filtro_avanzato': idFiltroAvanzato,
    };
  }

  factory Ricerca.fromJson(Map<String, dynamic> json) {
    return Ricerca(
      idRicerca: json['id_ricerca'],
      idIndirizzo: json['id_indirizzo'],
      idFiltroAvanzato: json['id_filtro_avanzato'],
    );
  }
}
