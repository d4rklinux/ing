class Indirizzo {
  final int idIndirizzo;
  final String citta;
  final String provincia;
  final String via;
  final int cap;

  Indirizzo({
    required this.idIndirizzo,
    required this.citta,
    required this.provincia,
    required this.via,
    required this.cap,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_indirizzo': idIndirizzo,
      'città': citta,
      'provincia': provincia,
      'via': via,
      'cap': cap,
    };
  }

  factory Indirizzo.fromJson(Map<String, dynamic> json) {
    return Indirizzo(
      idIndirizzo: json['id_indirizzo'],
      citta: json['città'],
      provincia: json['provincia'],
      via: json['via'],
      cap: json['cap'],
    );
  }
}