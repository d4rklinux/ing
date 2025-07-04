import 'package:flutter_test/flutter_test.dart';

String? validateAndSubmitVisita({
  required String? username,
  required DateTime? selectedDay,
  required DateTime? selectedTime,
  required List<Map<String, dynamic>> visiteInAttesa,
  required List<DateTime> occupiedSlots,
  required int idImmobile,
}) {
  if (username == null || selectedDay == null || selectedTime == null) {
    return 'Seleziona data e ora per la visita';
  }

  final visitaInAttesa = visiteInAttesa.cast<Map<String, dynamic>?>().firstWhere(
        (v) => v != null && v['id_immobile'] == idImmobile && v['stato_visita'] == 'In attesa',
    orElse: () => null,
  );

  if (visitaInAttesa != null) {
    return 'Hai già una visita in attesa per questo immobile Attendi che l\'agente accetti o rifiuti la tua visita';
  }

  final visitaDateTime = DateTime(
    selectedDay.year,
    selectedDay.month,
    selectedDay.day,
    selectedTime.hour,
    selectedTime.minute,
  );

  if (occupiedSlots.contains(visitaDateTime)) {
    return 'Orario già occupato. Scegli un altro.';
  }

  return 'Visita creata con successo';
}

void main() {
  group('validateAndSubmitVisita (replica logica Flutter UserSendVisitsPage)', () {
    final idImmobile = 123;
    final selectedDay = DateTime(2025, 5, 20);
    final selectedTime = DateTime(0, 0, 0, 10, 0); // 10:00

    test('Errore se uno tra username, giorno o ora è null', () {
      expect(
        validateAndSubmitVisita(
          username: null,
          selectedDay: selectedDay,
          selectedTime: selectedTime,
          visiteInAttesa: [],
          occupiedSlots: [],
          idImmobile: idImmobile,
        ),
        'Seleziona data e ora per la visita',
      );

      expect(
        validateAndSubmitVisita(
          username: 'user',
          selectedDay: null,
          selectedTime: selectedTime,
          visiteInAttesa: [],
          occupiedSlots: [],
          idImmobile: idImmobile,
        ),
        'Seleziona data e ora per la visita',
      );

      expect(
        validateAndSubmitVisita(
          username: 'user',
          selectedDay: selectedDay,
          selectedTime: null,
          visiteInAttesa: [],
          occupiedSlots: [],
          idImmobile: idImmobile,
        ),
        'Seleziona data e ora per la visita',
      );
    });

    test('Errore se visita in attesa già esistente per stesso immobile', () {
      final visiteInAttesa = [
        {'id_immobile': idImmobile, 'stato_visita': 'In attesa'},
      ];

      expect(
        validateAndSubmitVisita(
          username: 'user',
          selectedDay: selectedDay,
          selectedTime: selectedTime,
          visiteInAttesa: visiteInAttesa,
          occupiedSlots: [],
          idImmobile: idImmobile,
        ),
        'Hai già una visita in attesa per questo immobile Attendi che l\'agente accetti o rifiuti la tua visita',
      );
    });

    test('Errore se orario selezionato è già occupato', () {
      final visitaDateTime = DateTime(
        selectedDay.year,
        selectedDay.month,
        selectedDay.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      expect(
        validateAndSubmitVisita(
          username: 'user',
          selectedDay: selectedDay,
          selectedTime: selectedTime,
          visiteInAttesa: [],
          occupiedSlots: [visitaDateTime],
          idImmobile: idImmobile,
        ),
        'Orario già occupato. Scegli un altro.',
      );
    });

    test('Successo se nessun conflitto', () {
      expect(
        validateAndSubmitVisita(
          username: 'user',
          selectedDay: selectedDay,
          selectedTime: selectedTime,
          visiteInAttesa: [],
          occupiedSlots: [],
          idImmobile: idImmobile,
        ),
        'Visita creata con successo',
      );
    });

    test('Successo se visita in attesa per altro immobile', () {
      final visiteInAttesa = [
        {'id_immobile': 999, 'stato_visita': 'In attesa'},
      ];

      expect(
        validateAndSubmitVisita(
          username: 'user',
          selectedDay: selectedDay,
          selectedTime: selectedTime,
          visiteInAttesa: visiteInAttesa,
          occupiedSlots: [],
          idImmobile: idImmobile,
        ),
        'Visita creata con successo',
      );
    });

    test('Successo se visita esistente ma stato != "In attesa"', () {
      final visiteInAttesa = [
        {'id_immobile': idImmobile, 'stato_visita': 'Accettata'},
      ];

      expect(
        validateAndSubmitVisita(
          username: 'user',
          selectedDay: selectedDay,
          selectedTime: selectedTime,
          visiteInAttesa: visiteInAttesa,
          occupiedSlots: [],
          idImmobile: idImmobile,
        ),
        'Visita creata con successo',
      );
    });

    test('Successo se orario simile ma non identico (es. 10:00 vs 10:01)', () {
      final occupiedSlots = [
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day, 10, 1),
      ];

      expect(
        validateAndSubmitVisita(
          username: 'user',
          selectedDay: selectedDay,
          selectedTime: selectedTime,
          visiteInAttesa: [],
          occupiedSlots: occupiedSlots,
          idImmobile: idImmobile,
        ),
        'Visita creata con successo',
      );
    });

    test('Errore se più visite in attesa per stesso immobile', () {
      final visiteInAttesa = [
        {'id_immobile': idImmobile, 'stato_visita': 'In attesa'},
        {'id_immobile': idImmobile, 'stato_visita': 'In attesa'},
      ];

      expect(
        validateAndSubmitVisita(
          username: 'user',
          selectedDay: selectedDay,
          selectedTime: selectedTime,
          visiteInAttesa: visiteInAttesa,
          occupiedSlots: [],
          idImmobile: idImmobile,
        ),
        'Hai già una visita in attesa per questo immobile Attendi che l\'agente accetti o rifiuti la tua visita',
      );
    });

    test('Successo se altre visite per stesso immobile ma stato diverso', () {
      final visiteInAttesa = [
        {'id_immobile': idImmobile, 'stato_visita': 'Rifiutata'},
        {'id_immobile': idImmobile, 'stato_visita': 'Completata'},
      ];

      expect(
        validateAndSubmitVisita(
          username: 'user',
          selectedDay: selectedDay,
          selectedTime: selectedTime,
          visiteInAttesa: visiteInAttesa,
          occupiedSlots: [],
          idImmobile: idImmobile,
        ),
        'Visita creata con successo',
      );
    });
  });
}