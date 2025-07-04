import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> buildImmobileData({
  required List<String> imageUrls,
  required String tipoContratto,
  required String tipologiaImmobile,
  required String usernameAgente,
  required String titolo,
  required String testo,
  required double superficie,
  required double prezzo,
  required String provincia,
  required String via,
  required String cap,
  required String citta,
  required int stanza,
  required int piano,
  required int bagno,
  required String parcheggio,
  required String classeEnergetica,
  required bool climatizzatore,
  required bool balcone,
  required bool portineria,
  required bool giardino,
  required bool ascensore,
  required bool arredato,
}) {
  DateTime currentDate = DateTime.now();

  return {
    'percorso_file': imageUrls,
    'ordine': 0,
    'data_creazione': currentDate.toIso8601String().split('T')[0],
    'ora_creazione': currentDate.toIso8601String().split('T')[1],
    'tipo_contratto': tipoContratto,
    'tipologia_immobile': tipologiaImmobile,
    'username_agente': usernameAgente,
    'titolo': titolo,
    'testo': testo,
    'superficie': superficie,
    'prezzo': prezzo,
    'provincia': provincia,
    'via': via,
    'cap': cap,
    'città': citta,
    'stanza': stanza,
    'piano': piano,
    'bagno': bagno,
    'parcheggio': parcheggio,
    'classe_energetica': classeEnergetica,
    'climatizzatore': climatizzatore,
    'balcone': balcone,
    'portineria': portineria,
    'giardino': giardino,
    'ascensore': ascensore,
    'arredato': arredato,
  };
}



void main() {
  test('Restituisce la struttura dati corretta con gli input forniti', () {
    final imageUrls = ['https://image.com/1.jpg', 'https://image.com/2.jpg'];

    final result = buildImmobileData(
      imageUrls: imageUrls,
      tipoContratto: 'Vendita',
      tipologiaImmobile: 'Appartamento',
      usernameAgente: 'agent007',
      titolo: 'Bellissimo Appartamento',
      testo: 'Descrizione dettagliata...',
      superficie: 100.5,
      prezzo: 250000.0,
      provincia: 'Roma',
      via: 'Via delle Rose',
      cap: '00100',
      citta: 'Roma',
      stanza: 3,
      piano: 2,
      bagno: 2,
      parcheggio: 'Box privato',
      classeEnergetica: 'A+',
      climatizzatore: true,
      balcone: true,
      portineria: false,
      giardino: true,
      ascensore: true,
      arredato: false,
    );

    expect(result['percorso_file'], imageUrls);
    expect(result['tipo_contratto'], 'Vendita');
    expect(result['tipologia_immobile'], 'Appartamento');
    expect(result['climatizzatore'], true);
    expect(result['giardino'], true);
    expect(result['arredato'], false);
  });

  test('I campi data e ora vengono generati correttamente', () {
    final result = buildImmobileData(
      imageUrls: [],
      tipoContratto: 'Affitto',
      tipologiaImmobile: 'Villa',
      usernameAgente: 'admin',
      titolo: 'Villa Lussuosa',
      testo: 'Con piscina e campo da tennis',
      superficie: 300.0,
      prezzo: 500000.0,
      provincia: 'Milano',
      via: 'Via Verde',
      cap: '20100',
      citta: 'Milano',
      stanza: 10,
      piano: 1,
      bagno: 4,
      parcheggio: 'Garage doppio',
      classeEnergetica: 'B',
      climatizzatore: false,
      balcone: false,
      portineria: false,
      giardino: true,
      ascensore: false,
      arredato: true,
    );

    expect(result['data_creazione'], isNotNull);
    expect(result['ora_creazione'], isNotNull);
    expect(result['data_creazione'], matches(r'\d{4}-\d{2}-\d{2}'));
    expect(result['ora_creazione'], matches(r'\d{2}:\d{2}:\d{2}.*'));
  });

  test('Gestisce input vuoti o minimi dove consentito', () {
    final result = buildImmobileData(
      imageUrls: [],
      tipoContratto: 'Affitto',
      tipologiaImmobile: 'Monolocale',
      usernameAgente: 'testuser',
      titolo: '',
      testo: '',
      superficie: 20.0,
      prezzo: 500.0,
      provincia: 'NA',
      via: '',
      cap: '',
      citta: 'Napoli',
      stanza: 1,
      piano: 0,
      bagno: 1,
      parcheggio: '',
      classeEnergetica: 'G',
      climatizzatore: false,
      balcone: false,
      portineria: false,
      giardino: false,
      ascensore: false,
      arredato: false,
    );

    expect(result['titolo'], '');
    expect(result['testo'], '');
    expect(result['via'], '');
    expect(result['cap'], '');
    expect(result['parcheggio'], '');
  });

  test('Tutte le chiavi previste sono presenti nella mappa dei risultati', () {
    final result = buildImmobileData(
      imageUrls: ['url'],
      tipoContratto: 'Vendita',
      tipologiaImmobile: 'Casa',
      usernameAgente: 'user',
      titolo: 'Casa in vendita',
      testo: 'Bella casa',
      superficie: 70.0,
      prezzo: 100000.0,
      provincia: 'BO',
      via: 'Via Roma',
      cap: '40100',
      citta: 'Bologna',
      stanza: 2,
      piano: 1,
      bagno: 1,
      parcheggio: 'Nessuno',
      classeEnergetica: 'C',
      climatizzatore: true,
      balcone: true,
      portineria: true,
      giardino: false,
      ascensore: false,
      arredato: true,
    );

    final expectedKeys = [
      'percorso_file',
      'ordine',
      'data_creazione',
      'ora_creazione',
      'tipo_contratto',
      'tipologia_immobile',
      'username_agente',
      'titolo',
      'testo',
      'superficie',
      'prezzo',
      'provincia',
      'via',
      'cap',
      'città',
      'stanza',
      'piano',
      'bagno',
      'parcheggio',
      'classe_energetica',
      'climatizzatore',
      'balcone',
      'portineria',
      'giardino',
      'ascensore',
      'arredato',
    ];

    for (final key in expectedKeys) {
      expect(result.containsKey(key), true, reason: 'Chiave mancante: $key');
    }
  });

  test('Gestisce superficie e prezzo con valori estremi', () {
    final result = buildImmobileData(
      imageUrls: [],
      tipoContratto: 'Affitto',
      tipologiaImmobile: 'Garage',
      usernameAgente: 'extreme_user',
      titolo: 'Posto auto',
      testo: 'Molto piccolo',
      superficie: 0.0,
      prezzo: 0.0,
      provincia: 'MI',
      via: 'Via Stretta',
      cap: '20100',
      citta: 'Milano',
      stanza: 0,
      piano: -1,
      bagno: 0,
      parcheggio: '',
      classeEnergetica: 'N/A',
      climatizzatore: false,
      balcone: false,
      portineria: false,
      giardino: false,
      ascensore: false,
      arredato: false,
    );

    expect(result['superficie'], 0.0);
    expect(result['prezzo'], 0.0);
    expect(result['piano'], -1);
  });

  test('Tutti i campi booleani vengono mappati correttamente', () {
    final result = buildImmobileData(
      imageUrls: [],
      tipoContratto: 'Affitto',
      tipologiaImmobile: 'Loft',
      usernameAgente: 'booltest',
      titolo: 'Loft moderno',
      testo: 'Open space',
      superficie: 60.0,
      prezzo: 1200.0,
      provincia: 'TO',
      via: 'Via Nuova',
      cap: '10100',
      citta: 'Torino',
      stanza: 1,
      piano: 3,
      bagno: 1,
      parcheggio: 'Pubblico',
      classeEnergetica: 'A',
      climatizzatore: true,
      balcone: false,
      portineria: true,
      giardino: false,
      ascensore: true,
      arredato: true,
    );

    expect(result['climatizzatore'], true);
    expect(result['balcone'], false);
    expect(result['portineria'], true);
    expect(result['giardino'], false);
    expect(result['ascensore'], true);
    expect(result['arredato'], true);

  });

  test('Il campo ordine è sempre inizializzato a 0', () {
    final result = buildImmobileData(
      imageUrls: ['img1.jpg'],
      tipoContratto: 'Vendita',
      tipologiaImmobile: 'Villa',
      usernameAgente: 'agente123',
      titolo: 'Villa moderna',
      testo: 'Con ampio giardino',
      superficie: 150.0,
      prezzo: 300000.0,
      provincia: 'FI',
      via: 'Via della Quiete',
      cap: '50100',
      citta: 'Firenze',
      stanza: 5,
      piano: 1,
      bagno: 3,
      parcheggio: 'Garage',
      classeEnergetica: 'A',
      climatizzatore: true,
      balcone: true,
      portineria: false,
      giardino: true,
      ascensore: false,
      arredato: true,
    );

    expect(result['ordine'], 0);
  });

  test('Il campo percorso_file mantiene tutti gli URL e l\'ordine', () {
    final urls = ['a.jpg', 'b.jpg', 'c.jpg'];
    final result = buildImmobileData(
      imageUrls: urls,
      tipoContratto: 'Vendita',
      tipologiaImmobile: 'Attico',
      usernameAgente: 'agente456',
      titolo: 'Attico panoramico',
      testo: 'Vista mozzafiato',
      superficie: 200.0,
      prezzo: 600000.0,
      provincia: 'GE',
      via: 'Via Mare',
      cap: '16100',
      citta: 'Genova',
      stanza: 4,
      piano: 5,
      bagno: 2,
      parcheggio: 'Posto auto',
      classeEnergetica: 'A+',
      climatizzatore: true,
      balcone: true,
      portineria: true,
      giardino: false,
      ascensore: true,
      arredato: false,
    );

    expect(result['percorso_file'], urls);
    expect(result['percorso_file'][0], 'a.jpg');
    expect(result['percorso_file'][2], 'c.jpg');
  });

}
