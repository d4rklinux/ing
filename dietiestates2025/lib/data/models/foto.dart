class Foto {
  final int idFoto;
  final int idImmobile;
  final String percorsoFile;
  final int ordine;

  Foto({
    required this.idFoto,
    required this.idImmobile,
    required this.percorsoFile,
    required this.ordine,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_foto': idFoto,
      'id_immobile': idImmobile,
      'percorso_file': percorsoFile,
      'ordine': ordine,
    };
  }

  factory Foto.fromJson(Map<String, dynamic> json) {
    return Foto(
      idFoto: json['id_foto'],
      idImmobile: json['id_immobile'],
      percorsoFile: json['percorso_file'],
      ordine: json['ordine'],
    );
  }
}
