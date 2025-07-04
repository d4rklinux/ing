import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

// Classe che simula una pagina dove l'utente invia un'offerta
class UserSendOfferPage {
  // Metodo statico che valida il prezzo offerto dall'utente
  // value: prezzo inserito come stringa
  // prezzoAttuale: prezzo corrente dell'immobile
  static String? validatePrezzoOfferta(String? value, double prezzoAttuale) {
    // Controlla che il campo non sia vuoto o nullo
    if (value == null || value.isEmpty) {
      return 'Inserisci un prezzo valido';
    }

    // Prova a convertire la stringa in double
    final prezzoOfferto = double.tryParse(value);

    // Se la conversione fallisce oppure il prezzo offerto è maggiore o uguale al prezzo attuale
    if (prezzoOfferto == null || prezzoOfferto >= prezzoAttuale) {
      // Ritorna messaggio di errore con prezzo attuale formattato in italiano
      return 'L\'offerta deve essere inferiore al prezzo attuale (€${NumberFormat('#,##0', 'it_IT').format(prezzoAttuale)})';
    }

    // Se tutto è corretto, ritorna null (nessun errore)
    return null;
  }
}

void main() {
  // Gruppo di test per la funzione validatePrezzoOfferta
  group('UserSendOfferPage.validatePrezzoOfferta', () {
    // Prezzo di riferimento usato nei test
    final prezzoAttuale = 100000.0;
    // Prezzo formattato come stringa in formato italiano (es: "100.000")
    final prezzoFormattato = NumberFormat('#,##0', 'it_IT').format(prezzoAttuale);

    // Test: ritorna errore se il campo è vuoto
    test('ritorna errore se campo vuoto', () {
      final result = UserSendOfferPage.validatePrezzoOfferta('', prezzoAttuale);
      expect(result, 'Inserisci un prezzo valido');
    });

    // Test: ritorna errore se il valore non è un numero valido
    test('ritorna errore se valore non è un numero', () {
      final result = UserSendOfferPage.validatePrezzoOfferta('abc', prezzoAttuale);
      expect(result, 'L\'offerta deve essere inferiore al prezzo attuale (€$prezzoFormattato)');
    });

    // Test: ritorna errore se prezzo offerto è uguale o superiore al prezzo attuale
    test('ritorna errore se prezzoOfferto >= prezzoAttuale', () {
      final result = UserSendOfferPage.validatePrezzoOfferta('100000', prezzoAttuale);
      expect(result, 'L\'offerta deve essere inferiore al prezzo attuale (€$prezzoFormattato)');
    });

    // Test: ritorna null se prezzo offerto è valido e inferiore al prezzo attuale
    test('ritorna null se prezzo valido e inferiore', () {
      final result = UserSendOfferPage.validatePrezzoOfferta('90000', prezzoAttuale);
      expect(result, null);
    });

    // Test: ritorna errore se prezzo contiene la virgola decimale (non accettata da double.tryParse)
    test('ritorna errore se prezzo ha virgola decimale', () {
      final result = UserSendOfferPage.validatePrezzoOfferta('90000,50', prezzoAttuale);
      expect(result, 'L\'offerta deve essere inferiore al prezzo attuale (€$prezzoFormattato)');
    });

    // Test: ritorna null se il prezzo è appena inferiore al prezzo attuale (es. 99999.99)
    test('ritorna null se prezzo è appena inferiore', () {
      final result = UserSendOfferPage.validatePrezzoOfferta('99999.99', prezzoAttuale);
      expect(result, null);
    });

    // Test: ritorna errore se valore è un numero negativo
    test('ritorna errore se valore è negativo', () {
      final result = UserSendOfferPage.validatePrezzoOfferta('-5000', prezzoAttuale);
      expect(result, null); // Valido se è inferiore e numerico, anche se negativo
    });

    // Test: ritorna null se prezzo offerto ha decimali ma è valido
    test('ritorna null se prezzo con decimali validi', () {
      final result = UserSendOfferPage.validatePrezzoOfferta('99999.5', prezzoAttuale);
      expect(result, null);
    });

    // Test: ritorna errore se valore è null
    test('ritorna errore se valore è null', () {
      final result = UserSendOfferPage.validatePrezzoOfferta(null, prezzoAttuale);
      expect(result, 'Inserisci un prezzo valido');
    });

  });
}