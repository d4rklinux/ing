import 'package:flutter_test/flutter_test.dart';

/// Classe per filtrare una lista di immobili in base a criteri specifici.
class ImmobileFilter {
  /// Applica i filtri alla lista di immobili.
  static List<Map<String, dynamic>> applyFilters({
    required List<Map<String, dynamic>> immobili,
    required String tipoContratto,
    required String superficie,
    required String stanze,
    required String bagni,
    required String piano,
    required String classeEnergetica,
    required String parcheggio,
    required bool climatizzatore,
    required bool balcone,
    required bool portineria,
    required bool giardino,
    required bool ascensore,
    required bool arredato,
  }) {
    return immobili.where((result) {
      // Verifica tipo contratto (se diverso da "Tutti")
      bool matchesTipoContratto = tipoContratto == 'Tutti' || result['tipo_contratto'] == tipoContratto;

      // Filtro per superficie
      bool matchesSuperficie = true;
      int superficieVal = result['superficie'] ?? 0;
      switch (superficie) {
        case 'Da 0 a 50 m²':
          matchesSuperficie = superficieVal <= 50;
          break;
        case 'Da 51 a 100 m²':
          matchesSuperficie = superficieVal > 50 && superficieVal <= 100;
          break;
        case 'Da 101 a 200 m²':
          matchesSuperficie = superficieVal > 100 && superficieVal <= 200;
          break;
        case 'Da 201 a 300 m²':
          matchesSuperficie = superficieVal > 200 && superficieVal <= 300;
          break;
        case 'Da 301 a 400 m²':
          matchesSuperficie = superficieVal > 300 && superficieVal <= 400;
          break;
        case 'Da 401 a 500 m²':
          matchesSuperficie = superficieVal > 400 && superficieVal <= 500;
          break;
        case 'Da 501 a 1000 m²':
          matchesSuperficie = superficieVal > 500 && superficieVal <= 1000;
          break;
        default:
          matchesSuperficie = true;
      }

      // Filtro per numero di stanze
      bool matchesStanze = true;
      int stanzeVal = result['stanza'] ?? 0;
      switch (stanze) {
        case '0-5':
          matchesStanze = stanzeVal <= 5;
          break;
        case '6-10':
          matchesStanze = stanzeVal > 5 && stanzeVal <= 10;
          break;
        case '11-15':
          matchesStanze = stanzeVal > 10 && stanzeVal <= 15;
          break;
        case '16-20':
          matchesStanze = stanzeVal > 15 && stanzeVal <= 20;
          break;
        case '21-25':
          matchesStanze = stanzeVal > 20 && stanzeVal <= 25;
          break;
        case '26-30':
          matchesStanze = stanzeVal > 25 && stanzeVal <= 30;
          break;
        case '30+':
          matchesStanze = stanzeVal > 30;
          break;
        default:
          matchesStanze = true;
      }

      // Filtro per numero di bagni
      bool matchesBagni = true;
      int bagnoVal = result['bagno'] ?? 0;
      switch (bagni) {
        case '1':
          matchesBagni = bagnoVal == 1;
          break;
        case '2':
          matchesBagni = bagnoVal == 2;
          break;
        case '3':
          matchesBagni = bagnoVal == 3;
          break;
        case '4+':
          matchesBagni = bagnoVal > 3;
          break;
        default:
          matchesBagni = true;
      }

      // Filtro per piano
      bool matchesPiano = true;
      int pianoVal = result['piano'] ?? 0;
      switch (piano) {
        case '1':
          matchesPiano = pianoVal == 1;
          break;
        case '2':
          matchesPiano = pianoVal == 2;
          break;
        case '3':
          matchesPiano = pianoVal == 3;
          break;
        case '4+':
          matchesPiano = pianoVal > 3;
          break;
        default:
          matchesPiano = true;
      }

      // Filtro per classe energetica
      bool matchesClasseEnergetica = classeEnergetica == 'Tutti' || result['classe_energetica'] == classeEnergetica;

      // Filtro per tipo di parcheggio
      bool matchesParcheggio = parcheggio == 'Tutti' || result['parcheggio'] == parcheggio;

      // Filtri booleani (si attivano solo se true)
      bool matchesClimatizzatore = !climatizzatore || result['climatizzatore'] == true;
      bool matchesBalcone = !balcone || result['balcone'] == true;
      bool matchesPortineria = !portineria || result['portineria'] == true;
      bool matchesGiardino = !giardino || result['giardino'] == true;
      bool matchesAscensore = !ascensore || result['ascensore'] == true;
      bool matchesArredato = !arredato || result['arredato'] == true;

      // L'immobile viene incluso solo se rispetta tutti i filtri
      return matchesTipoContratto &&
          matchesSuperficie &&
          matchesStanze &&
          matchesBagni &&
          matchesPiano &&
          matchesClasseEnergetica &&
          matchesParcheggio &&
          matchesClimatizzatore &&
          matchesBalcone &&
          matchesPortineria &&
          matchesGiardino &&
          matchesAscensore &&
          matchesArredato;
    }).toList(); // Ritorna la lista filtrata
  }
}


void main() {
  group('ImmobileFilter', () {
    // Lista di immobili di esempio da usare nei test
    final immobili = [
      {
        'tipo_contratto': 'Vendita',
        'superficie': 80,
        'stanza': 3,
        'bagno': 1,
        'piano': 1,
        'classe_energetica': 'A',
        'parcheggio': 'Garage',
        'climatizzatore': true,
        'balcone': true,
        'portineria': false,
        'giardino': true,
        'ascensore': true,
        'arredato': false,
      },
      {
        'tipo_contratto': 'Affitto',
        'superficie': 120,
        'stanza': 5,
        'bagno': 2,
        'piano': 2,
        'classe_energetica': 'B',
        'parcheggio': 'Nessuno',
        'climatizzatore': false,
        'balcone': false,
        'portineria': false,
        'giardino': false,
        'ascensore': false,
        'arredato': true,
      },
    ];

    // Verifica che venga filtrato solo l'immobile in vendita
    test('Filtra per tipo contratto "Vendita"', () {
      final filtered = ImmobileFilter.applyFilters(
        immobili: immobili,
        tipoContratto: 'Vendita',
        superficie: 'Tutti',
        stanze: 'Tutti',
        bagni: 'Tutti',
        piano: 'Tutti',
        classeEnergetica: 'Tutti',
        parcheggio: 'Tutti',
        climatizzatore: false,
        balcone: false,
        portineria: false,
        giardino: false,
        ascensore: false,
        arredato: false,
      );

      expect(filtered.length, 1);
      expect(filtered[0]['tipo_contratto'], 'Vendita');
    });

    // Verifica che venga filtrato solo l'immobile con classe energetica B
    test('Filtra per classe energetica "B"', () {
      final filtered = ImmobileFilter.applyFilters(
        immobili: immobili,
        tipoContratto: 'Tutti',
        superficie: 'Tutti',
        stanze: 'Tutti',
        bagni: 'Tutti',
        piano: 'Tutti',
        classeEnergetica: 'B',
        parcheggio: 'Tutti',
        climatizzatore: false,
        balcone: false,
        portineria: false,
        giardino: false,
        ascensore: false,
        arredato: false,
      );

      expect(filtered.length, 1);
      expect(filtered[0]['classe_energetica'], 'B');
    });

    // Verifica che venga filtrato solo l'immobile con garage
    test('Filtra per parcheggio "Garage"', () {
      final filtered = ImmobileFilter.applyFilters(
        immobili: immobili,
        tipoContratto: 'Tutti',
        superficie: 'Tutti',
        stanze: 'Tutti',
        bagni: 'Tutti',
        piano: 'Tutti',
        classeEnergetica: 'Tutti',
        parcheggio: 'Garage',
        climatizzatore: false,
        balcone: false,
        portineria: false,
        giardino: false,
        ascensore: false,
        arredato: false,
      );

      expect(filtered.length, 1);
      expect(filtered[0]['parcheggio'], 'Garage');
    });

    // Nessun immobile ha portineria, ci si aspetta risultato vuoto
    test('Filtra per portineria true', () {
      final filtered = ImmobileFilter.applyFilters(
        immobili: immobili,
        tipoContratto: 'Tutti',
        superficie: 'Tutti',
        stanze: 'Tutti',
        bagni: 'Tutti',
        piano: 'Tutti',
        classeEnergetica: 'Tutti',
        parcheggio: 'Tutti',
        climatizzatore: false,
        balcone: false,
        portineria: true,
        giardino: false,
        ascensore: false,
        arredato: false,
      );

      expect(filtered.isEmpty, true); // Nessun immobile ha portineria true
    });

    // Nessun immobile ha entrambe le caratteristiche: ascensore e arredato
    test('Filtra per ascensore e arredato', () {
      final filtered = ImmobileFilter.applyFilters(
        immobili: immobili,
        tipoContratto: 'Tutti',
        superficie: 'Tutti',
        stanze: 'Tutti',
        bagni: 'Tutti',
        piano: 'Tutti',
        classeEnergetica: 'Tutti',
        parcheggio: 'Tutti',
        climatizzatore: false,
        balcone: false,
        portineria: false,
        giardino: false,
        ascensore: true,
        arredato: true,
      );

      expect(filtered.isEmpty, true);
    });

    // Verifica il range di superficie (incluso 100 m²)
    test('Filtra per superficie "Da 51 a 100 m²"', () {
      final filtered = ImmobileFilter.applyFilters(
        immobili: immobili,
        tipoContratto: 'Tutti',
        superficie: 'Da 51 a 100 m²',
        stanze: 'Tutti',
        bagni: 'Tutti',
        piano: 'Tutti',
        classeEnergetica: 'Tutti',
        parcheggio: 'Tutti',
        climatizzatore: false,
        balcone: false,
        portineria: false,
        giardino: false,
        ascensore: false,
        arredato: false,
      );

      expect(filtered.length, 1);
      expect(filtered[0]['superficie'], 80);
    });

    // Entrambi gli immobili hanno da 0 a 5 stanze
    test('Filtra per stanze "0-5"', () {
      final filtered = ImmobileFilter.applyFilters(
        immobili: immobili,
        tipoContratto: 'Tutti',
        superficie: 'Tutti',
        stanze: '0-5',
        bagni: 'Tutti',
        piano: 'Tutti',
        classeEnergetica: 'Tutti',
        parcheggio: 'Tutti',
        climatizzatore: false,
        balcone: false,
        portineria: false,
        giardino: false,
        ascensore: false,
        arredato: false,
      );

      expect(filtered.length, 2);
    });

    // Solo un immobile ha 2 bagni
    test('Filtra per bagni "2"', () {
      final filtered = ImmobileFilter.applyFilters(
        immobili: immobili,
        tipoContratto: 'Tutti',
        superficie: 'Tutti',
        stanze: 'Tutti',
        bagni: '2',
        piano: 'Tutti',
        classeEnergetica: 'Tutti',
        parcheggio: 'Tutti',
        climatizzatore: false,
        balcone: false,
        portineria: false,
        giardino: false,
        ascensore: false,
        arredato: false,
      );

      expect(filtered.length, 1);
      expect(filtered[0]['bagno'], 2);
    });

    // Solo un immobile è al secondo piano
    test('Filtra per piano "2"', () {
      final filtered = ImmobileFilter.applyFilters(
        immobili: immobili,
        tipoContratto: 'Tutti',
        superficie: 'Tutti',
        stanze: 'Tutti',
        bagni: 'Tutti',
        piano: '2',
        classeEnergetica: 'Tutti',
        parcheggio: 'Tutti',
        climatizzatore: false,
        balcone: false,
        portineria: false,
        giardino: false,
        ascensore: false,
        arredato: false,
      );

      expect(filtered.length, 1);
      expect(filtered[0]['piano'], 2);
    });

    // Verifica un caso con più filtri contemporaneamente
    test('Filtra per più parametri attivi', () {
      final filtered = ImmobileFilter.applyFilters(
        immobili: immobili,
        tipoContratto: 'Vendita',
        superficie: 'Da 51 a 100 m²',
        stanze: '0-5',
        bagni: '1',
        piano: '1',
        classeEnergetica: 'A',
        parcheggio: 'Garage',
        climatizzatore: true,
        balcone: true,
        portineria: false,
        giardino: true,
        ascensore: true,
        arredato: false,
      );

      expect(filtered.length, 1);
    });

    // Verifica che l'immobile con superficie 100 m² venga incluso correttamente
    test('Filtra superficie edge: esattamente 100 m²', () {
      final edgeImmobile = [
        {
          'tipo_contratto': 'Vendita',
          'superficie': 100,
          'stanza': 2,
          'bagno': 1,
          'piano': 1,
          'classe_energetica': 'A',
          'parcheggio': 'Garage',
          'climatizzatore': true,
          'balcone': false,
          'portineria': false,
          'giardino': false,
          'ascensore': false,
          'arredato': false,
        }
      ];

      // La lista degli immobili è vuota → risultato atteso: vuoto
      final filtered = ImmobileFilter.applyFilters(
        immobili: edgeImmobile,
        tipoContratto: 'Tutti',
        superficie: 'Da 51 a 100 m²',
        stanze: 'Tutti',
        bagni: 'Tutti',
        piano: 'Tutti',
        classeEnergetica: 'Tutti',
        parcheggio: 'Tutti',
        climatizzatore: false,
        balcone: false,
        portineria: false,
        giardino: false,
        ascensore: false,
        arredato: false,
      );

      expect(filtered.length, 1);
      expect(filtered[0]['superficie'], 100);
    });


    // L'immobile ha tutti i valori nulli → deve essere escluso
    test('Comportamento con lista vuota', () {
      final filtered = ImmobileFilter.applyFilters(
        immobili: [],
        tipoContratto: 'Vendita',
        superficie: 'Da 0 a 50 m²',
        stanze: '0-5',
        bagni: '1',
        piano: '1',
        classeEnergetica: 'A',
        parcheggio: 'Garage',
        climatizzatore: true,
        balcone: true,
        portineria: true,
        giardino: true,
        ascensore: true,
        arredato: true,
      );

      expect(filtered.isEmpty, true);
    });

    // Test per gestire immobili con valori nulli: nessuno dovrebbe soddisfare i criteri attivi
    test('Comportamento con valori nulli nel dato', () {
      final immobiliConNull = [
        {
          'tipo_contratto': 'Vendita',
          'superficie': null,
          'stanza': null,
          'bagno': null,
          'piano': null,
          'classe_energetica': null,
          'parcheggio': null,
          'climatizzatore': null,
          'balcone': null,
          'portineria': null,
          'giardino': null,
          'ascensore': null,
          'arredato': null,
        }
      ];

      // Applichiamo filtri restrittivi su tutti i campi → nessun immobile con valori nulli dovrebbe essere incluso
      final filtered = ImmobileFilter.applyFilters(
        immobili: immobiliConNull,
        tipoContratto: 'Tutti',
        superficie: 'Da 0 a 50 m²',
        stanze: '0-5',
        bagni: '1',
        piano: '1',
        classeEnergetica: 'A',
        parcheggio: 'Garage',
        climatizzatore: true,
        balcone: true,
        portineria: true,
        giardino: true,
        ascensore: true,
        arredato: true,
      );

      // Ci si aspetta che la lista sia vuota perché i valori nulli non soddisfano i filtri
      expect(filtered.isEmpty, true);
    });

    // Nessun filtro applicato → ritorna la lista completa
    test('Nessun filtro attivo: ritorna tutti gli immobili', () {
      final filtered = ImmobileFilter.applyFilters(
        immobili: immobili,
        tipoContratto: 'Tutti',
        superficie: 'Tutti',
        stanze: 'Tutti',
        bagni: 'Tutti',
        piano: 'Tutti',
        classeEnergetica: 'Tutti',
        parcheggio: 'Tutti',
        climatizzatore: false,
        balcone: false,
        portineria: false,
        giardino: false,
        ascensore: false,
        arredato: false,
      );

      expect(filtered.length, immobili.length);
    });
  });
}