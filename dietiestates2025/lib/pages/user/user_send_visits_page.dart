import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

import '../../data/models/visita.dart';
import '../../data/repositories/visita_repositories.dart';
import '../../provider/auth_provider.dart';
import '../../services/http_service.dart';

class UserSendVisitsPage extends StatefulWidget {
  final Map<String, dynamic> immobile;
  final String usernameAgente;

  const UserSendVisitsPage({
    super.key,
    required this.immobile,
    required this.usernameAgente,
  });

  @override
  State<UserSendVisitsPage> createState() => _UserSendVisitsPageState();
}

// Classe per lo stato della pagina
class _UserSendVisitsPageState extends State<UserSendVisitsPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _selectedTime;
  final VisitaRepositories _visitaRepository = VisitaRepositories(HttpService());

  // Data limite per la prenotazione
  final DateTime _firstAvailableDay = DateTime.now();
  late final DateTime _lastAvailableDay = _firstAvailableDay.add(const Duration(days: 13));

  // Lista di orari disponibili
  final List<String> _availableTimes = [
    '10:00', '11:00', '12:00',
    '13:00', '14:00', '15:00',
    '16:00', '17:00', '18:00',
  ];

  List<DateTime> _occupiedSlots = [];

  // Funzione di inizializzazione
  @override
  void initState() {
    super.initState();
    _loadVisiteApprovate();

    if (widget.immobile['id_immobile'] == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCupertinoDialog('Errore', 'ID Immobile non trovato.');
        Navigator.pop(context);
      });
    }
  }

  // Funzione per formattare la data
  String formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString).toLocal();
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return 'Data non valida';
    }
  }

  Future<void> _loadVisiteApprovate() async {
    try {
      // Ottieni tutte le visite completate
      final visiteCompletate = await _visitaRepository.getVisiteCompletate();

      // Filtro per ottenere solo le visite dell'immobile corrente
      List<DateTime> completedSlots = visiteCompletate.where((v) {
        return v['id_immobile'] == widget.immobile['id_immobile'];
      }).map((v) {
        final dataStr = v['data_visita'].toString();
        final oraStr = v['ora_visita'].toString();
        final dataParsed = DateTime.parse(dataStr).toLocal();
        final parts = oraStr.split(':');
        return DateTime(dataParsed.year, dataParsed.month, dataParsed.day, int.parse(parts[0]), int.parse(parts[1]));
      }).toList();

      setState(() {
        _occupiedSlots = [...completedSlots];
      });
    } catch (e) {
      if (!mounted) return;
      _showCupertinoDialog('Errore', 'Errore nel recupero delle visite: $e');
    }
  }

  Future<void> _submitVisita() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final username = authProvider.currentUser?.username;

    if (username == null || _selectedDay == null || _selectedTime == null) {
      // Mostra un alert di errore se non è selezionata la data o l'ora
      _showCupertinoDialog('Errore', 'Seleziona data e ora per la visita');
      return;
    }

    // Verifica se l'utente ha già una visita in attesa per lo stesso immobile
    try {
      final visiteInAttesa = await _visitaRepository.getVisiteByUsername(username);
      final visitaInAttesa = visiteInAttesa.firstWhere(
            (v) =>
        v['id_immobile'] == widget.immobile['id_immobile'] &&
            v['stato_visita'] == 'In attesa',
        orElse: () => null,
      );

      if (visitaInAttesa != null) {
        // Se esiste una visita in attesa per lo stesso immobile, mostra un alert
        _showCupertinoDialog(
            'Attenzione', 'Hai già una visita in attesa per questo immobile Attendi che l\'agente accetti o rifiuti la tua visita');
        return;
      }
    } catch (e) {
      if (!mounted) return;
      _showCupertinoDialog('Errore', 'Errore nel recupero delle visite: $e');
      return;
    }

    // Crea l'oggetto DateTime con la data e l'ora selezionate
    final visitaDateTime = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    if (_occupiedSlots.contains(visitaDateTime)) {
      // Mostra un alert di errore se l'orario è già occupato
      _showCupertinoDialog('Errore', 'Orario già occupato. Scegli un altro.');
      return;
    }

    try {
      final visita = Visita(
        idVisita: 0,
        idImmobile: widget.immobile['id_immobile'],
        usernameUtente: username,
        oraVisita: visitaDateTime,
        dataVisita: _selectedDay!,
        statoVisita: 'In attesa',
        statoApprovazioneAgente: 'In attesa',
        usernameAgenteApprovazione: widget.immobile['username_agente'],
      );

      final result = await _visitaRepository.createVisita(visita);

      if (!mounted) return;

      // Mostra un alert di successo
      _showCupertinoDialog('Successo', result);

      setState(() {
        _selectedDay = null;
        _selectedTime = null;
        _occupiedSlots.add(visitaDateTime);
      });
    } catch (e) {
      // Mostra un alert di errore in caso di eccezione
      _showCupertinoDialog('Errore', 'Errore durante l\'inserimento: $e');
    }
  }

  // Funzione per la creazione della pagina
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Prenota una visita',
          style: TextStyle(
            color: Colors.white,
            fontSize: width * 0.045,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: const Color(0xFF0079BB),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 30),
            _buildCalendar(),
            const SizedBox(height: 100),
            _buildAvailableTimes(width),
            const SizedBox(height: 30),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  // Funzione per la creazione del calendario
  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: _firstAvailableDay,
      lastDay: _lastAvailableDay,
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      calendarFormat: CalendarFormat.month,
      locale: 'it_IT',
      startingDayOfWeek: StartingDayOfWeek.monday,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextFormatter: (date, locale) {
          String formatted = DateFormat.yMMMM(locale).format(date);
          return formatted[0].toUpperCase() + formatted.substring(1);
        },
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      calendarStyle: CalendarStyle(
        defaultTextStyle: TextStyle(color: Colors.black),
        weekendTextStyle: TextStyle(color: Colors.black),
        selectedDecoration: BoxDecoration(),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: Colors.black),
        weekendStyle: TextStyle(color: Colors.black),
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          return _buildDayCell(day);
        },
        selectedBuilder: (context, day, focusedDay) {
          return _buildDayCell(day, isSelected: true);
        },
        todayBuilder: (context, day, focusedDay) {
          return _buildDayCell(day);
        },
      ),
    );
  }

  // Funzione per la creazione del giorno
  Widget _buildDayCell(DateTime day, {bool isSelected = false, bool isDisabled = false}) {
    final textColor = isSelected ? Colors.white : Colors.black;

    // Modifica qui per non renderizzare il giorno come "disabilitato"
    return Center(
      child: Container(
        width: 40,
        height: 40,
        decoration: isSelected
            ? BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        )
            : BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: isDisabled ? Colors.transparent : textColor,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

// Funzione per la creazione dei orari disponibili
  Widget _buildAvailableTimes(double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Orario disponibile:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: _availableTimes.map((time) {
            final hour = int.parse(time.split(':')[0]);
            final minute = int.parse(time.split(':')[1]);
            final timeForComparison = DateTime(
              _selectedDay?.year ?? 0,
              _selectedDay?.month ?? 0,
              _selectedDay?.day ?? 0,
              hour,
              minute,
            );

            final isOccupied = _occupiedSlots.contains(timeForComparison);

            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      // Modifica per evitare che gli orari occupati siano distinti visivamente
                      color: isOccupied
                          ? Colors.black
                          : (_selectedTime == timeForComparison
                          ? Colors.white
                          : Colors.black),
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
              ),
              selected: _selectedTime == timeForComparison,
              onSelected: isOccupied
                  ? null
                  : (_) {
                setState(() {
                  _selectedTime = timeForComparison;
                });
              },
              selectedColor: Colors.blue,
              disabledColor: Colors.transparent,
              backgroundColor: Colors.white,
            );
          }).toList(),
        ),
      ],
    );
  }

  // Funzione per la creazione del pulsante di conferma
  Widget _buildConfirmButton() {
    return ElevatedButton(
      onPressed: _submitVisita,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.blue, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      ),
      child: const Text(
        'Conferma Visita',
        style: TextStyle(fontSize: 16, color: Colors.blue),
      ),
    );
  }

  // Funzione per mostrare il Cupertino Alert Dialog
  void _showCupertinoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(
                'OK',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}