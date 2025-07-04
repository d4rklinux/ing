import 'dart:ffi';

class ServizioUlteriore {
  final int idServizio;
  final Bool climatizzatore;
  final Bool balcone;
  final Bool portineria;
  final Bool giardino;
  final Bool ascensore;
  final Bool arredato;
  final int idFiltroAvanzato;

  ServizioUlteriore({
    required this.idServizio,
    required this.climatizzatore,
    required this.balcone,
    required this.portineria,
    required this.giardino,
    required this.ascensore,
    required this.arredato,
    required this.idFiltroAvanzato,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_servizio': idServizio,
      'climatizzatore': climatizzatore,
      'balcone': balcone,
      'portineria': portineria,
      'giardino': giardino,
      'ascensore': ascensore,
      'arredato': arredato,
      'id_filtro_avanzato': idFiltroAvanzato,
    };
  }

  factory ServizioUlteriore.fromJson(Map<String, dynamic> json) {
    return ServizioUlteriore(
      idServizio: json['id_servizio'],
      climatizzatore: json['climatizzatore'],
      balcone: json['balcone'],
      portineria: json['portineria'],
      giardino: json['giardino'],
      ascensore: json['ascensore'],
      arredato: json['arredato'],
      idFiltroAvanzato: json['id_filtro_avanzato'],
);
  }
}
