class Utente {
  final String username;
  final String password;
  final int idRuolo;
  final String nome;
  final String cognome;
  final String email;

  Utente({
    required this.username,
    required this.password,
    required this.idRuolo,
    required this.nome,
    required this.cognome,
    required this.email,
  });

  // Factory per creare un oggetto Utente da una mappa (da JSON)
  factory Utente.fromJson(Map<String, dynamic> json) {
    return Utente(
      username: json['username_utente'] as String? ?? '',
      password: json['password'] as String? ?? '',
      // Se il campo non è già un intero, tentiamo di convertirlo in intero
      idRuolo: json['id_ruolo'] is int
          ? json['id_ruolo']
          : int.tryParse(json['id_ruolo'].toString()) ?? 0,
      nome: json['nome'] as String? ?? '',
      cognome: json['cognome'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }
  
  // Metodo per convertire un oggetto Utente in una mappa (per JSON)
  Map<String, dynamic> toJson() {
    return {
      'username_utente': username,
      'password': password,
      'nome': nome,
      'cognome': cognome,
      'email': email,
      'id_ruolo': idRuolo,
    };
  }

  }

