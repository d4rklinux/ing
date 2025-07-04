import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../agent/agent_home_page.dart';

import '../../services/http_service.dart';
import '../../services/navigation_service.dart';

import '../../provider/auth_provider.dart';

import '../../widgets/agent_bottom_bar_widget.dart';

import '../../data/repositories/visita_repositories.dart';


class AgentVisitsPage extends StatefulWidget {
  const AgentVisitsPage({super.key});

  @override
  State<AgentVisitsPage> createState() => _AgentVisitsPageState();
}

class _AgentVisitsPageState extends State<AgentVisitsPage> {
  int _selectedIndex = 1;
  late Future<List<dynamic>> _visiteFuture;
  final VisitaRepositories _visitaRepo = VisitaRepositories(HttpService());
  String selectedFilter = 'Tutte';

  // Funzione per inizializzare i dati
  @override
  void initState() {
    super.initState();
    _loadVisite();
  }

  // Funzione per caricare le visite
  void _loadVisite() {
    setState(() {
      _visiteFuture = _visitaRepo.getAllVisita();
    });
  }

  // Funzione per gestire il cambio di pagina
  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
    NavigationService.navigateToAgentBottomBarPage(index);
  }

  // Funzione per cambiare il filtro
  void _filterVisits(String filter) {
    setState(() {
      selectedFilter = filter;
    });
  }



  // Funzione per costruire la pagina
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gestione Visite',
          style: TextStyle(
            color: Colors.white,
            fontSize: width * 0.045,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: const Color(0xFF0079BB),
        leading: GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AgentHomePage()),
            );
          },
          child: Icon(
            Icons.home_filled,
            color: Colors.white,
            size: width * 0.06,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _visiteFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Errore: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nessuna visita trovata.'));
                } else {
                  final visite = snapshot.data!;
                  final accettate = visite.where((v) => v['stato_approvazione_agente'] == 'Accettata').toList();
                  final rifiutate = visite.where((v) => v['stato_approvazione_agente'] == 'Rifiutata').toList();
                  final inAttesa = visite.where((v) => v['stato_approvazione_agente'] == 'In attesa').toList();

                  List<Widget> sezioni = [];

                  if (selectedFilter == 'Tutte' || selectedFilter == 'In attesa') {
                    sezioni.addAll(_buildSection('Visite In attesa', inAttesa, width, height));
                  }
                  if (selectedFilter == 'Tutte' || selectedFilter == 'Accettata') {
                    sezioni.addAll(_buildSection('Visite Accettate', accettate, width, height));
                  }
                  if (selectedFilter == 'Tutte' || selectedFilter == 'Rifiutata') {
                    sezioni.addAll(_buildSection('Visite Rifiutate', rifiutate, width, height));
                  }

                  return ListView(children: sezioni);
                }
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: AgentBottomBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  // Funzione per costruire la barra di filtro
  Widget _buildFilterBar() {
    final bool isOrangeFilter = selectedFilter == 'In attesa' ||
        selectedFilter == 'Accettata' ||
        selectedFilter == 'Rifiutata';

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isOrangeFilter ? Colors.orange : Colors.blue,
            width: 2,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          children: [
            Theme(
              data: Theme.of(context).copyWith(

                dividerColor: Colors.transparent,
                expansionTileTheme: ExpansionTileThemeData(
                  backgroundColor: Colors.white,
                  collapsedBackgroundColor: Colors.white,
                ),
              ),
              child: ExpansionTile(
                title: Text(
                  'Filtra le visite',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isOrangeFilter ? Colors.orange : Colors.blue,
                  ),
                ),
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildFilterButton('Tutte'),
                      _buildFilterButton('In attesa'),
                      _buildFilterButton('Accettata'),
                      _buildFilterButton('Rifiutata'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String label) {
    final bool isSelected = selectedFilter == label;
    final width = MediaQuery.of(context).size.width;

    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [Colors.orange, Colors.red]
                : [Color(0xFF0079BB), Color(0xFF00AEEF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.blue,
            width: 2,
          ),
        ),
        child: ElevatedButton(
          onPressed: () => _filterVisits(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // Funzione per costruire le sezioni
  List<Widget> _buildSection(String titolo, List<dynamic> lista, double width, double height) {
    if (lista.isEmpty) return [];

    // Ordinamento della lista in base alla data di visita (dal più recente al più vecchio)
    lista.sort((a, b) {
      DateTime dateA = DateTime.parse(a['data_visita']);
      DateTime dateB = DateTime.parse(b['data_visita']);
      return dateB.compareTo(dateA);
    });

    Color getTitoloColor(String titolo) {
      if (titolo.toLowerCase().contains('in attesa')) return Colors.orange;
      if (titolo.toLowerCase().contains('accettate')) return Colors.green;
      if (titolo.toLowerCase().contains('rifiutate')) return Colors.red;
      return Colors.black87;
    }

    return [
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.05,
          vertical: height * 0.015,
        ),
        child: Text(
          titolo,
          style: TextStyle(
            fontSize: width * 0.05,
            fontWeight: FontWeight.w600,
            color: getTitoloColor(titolo),
          ),
        ),
      ),
      ...lista.map((visita) {
        return _buildCard(visita, width, height);
      }),
    ];
  }

  // Funzione per costruire la carta
  Widget _buildCard(dynamic visita, double width, double height) {
    final idVisita = visita['id_visita'];
    final statoApprovazione = visita['stato_approvazione_agente'];

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: _getCardBorderColor(statoApprovazione), width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.005),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(visita),
            const SizedBox(height: 10),
            _buildRow(Icons.info, 'Stato: $statoApprovazione', _getCardBorderColor(statoApprovazione), width),
            Row(
              children: [
                _buildRow(
                  Icons.calendar_today,
                  'Data: ${_formatDate(visita['data_visita'])}', Colors.brown, width,),
                const SizedBox(width: 10),
                _buildRow(
                  Icons.access_time,
                  'Ore: ${_formatTime(visita['ora_visita'] ?? '')}', Colors.brown, width,),
              ],
            ),
            _buildRow(Icons.person,
                'Nome: ${visita['nome'] ?? 'Nome non trovato'} ${visita['cognome'] ?? 'Cognome non trovato'}',
                Colors.blueGrey, width),
            _buildRow(Icons.title, 'Titolo: ${visita['titolo'] ?? 'Titolo non disponibile'}', Colors.black, width),
            _buildRow(Icons.home_work, 'Tipologia: ${visita['tipologia_immobile'] ?? 'Tipologia non disponibile'}', Colors.pink, width),
            _buildRow(Icons.monetization_on, 'Prezzo: € ${NumberFormat('#,##0', 'it_IT').format(visita['prezzo'] ?? 0)}', Colors.blue, width),
            const SizedBox(height: 10),
            if (statoApprovazione == 'In attesa') _buildApprovalButtons(idVisita, statoApprovazione),
          ],
        ),
      ),
    );
  }

  // Funzione per ottenere il colore del bordo della card in base allo stato
  Color _getCardBorderColor(String stato) {
    switch (stato) {
      case 'Accettata':
        return Colors.green;
      case 'Rifiutata':
        return Colors.red;
      case 'In attesa':
      default:
        return Colors.orange;
    }
  }

  // Funzione per costruire l'immagine
  Widget _buildImage(dynamic visita) {
    return visita['percorso_file'] != null && visita['percorso_file'].isNotEmpty
        ? Image.network(
      visita['percorso_file'],
      height: 160,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const Text('Immagine non disponibile'),
    )
        : const Text('Nessuna foto disponibile');
  }

  // Funzione per costruire una riga con icona e testo
  Widget _buildRow(IconData icon, String text, Color color, double width, {TextStyle? textStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: textStyle ??
                TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                ),
          ),
        ],
      ),
    );
  }

  // Funzione per gestire l'approvazione della visita
  Future<void> _gestisciApprovazione(int idVisita, String stato) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final usernameAgente = authProvider.currentUser?.username;

    if (usernameAgente == null) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Errore'),
          content: const Text('Username agente non trovato'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
      return;
    }

    // Mostra dialogo di conferma e attendi la risposta dell'utente
    final conferma = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Sei sicuro di voler confermare?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Annulla', style: TextStyle(color: CupertinoColors.activeBlue)),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Si Conferma', style: TextStyle(color: CupertinoColors.activeBlue)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (conferma != true) return;

    // Procedi con l'approvazione
    final result = await _visitaRepo.approvaVisita(
      idVisita: idVisita,
      statoApprovazioneAgente: stato,
      usernameAgenteApprovazione: usernameAgente,
    );

    if (!mounted) return;

    // Mostra il risultato
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Esito'),
        content: Text(result),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK', style: TextStyle(color: CupertinoColors.activeBlue)),
            onPressed: () {
              Navigator.of(context).pop();
              _loadVisite();
            },
          ),
        ],
      ),
    );
  }

  // Funzione per costruire i pulsanti di approvazione
  Widget _buildApprovalButtons(int idVisita, String statoApprovazione) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () => _gestisciApprovazione(idVisita, 'Accettata'),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.green, width: 2),
          ),
          child: const Text(
            'Conferma',
            style: TextStyle(color: Colors.green),
          ),
        ),
        const SizedBox(width: 10),
        OutlinedButton(
          onPressed: () => _gestisciApprovazione(idVisita, 'Rifiutata'),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.red, width: 2),
          ),
          child: const Text(
            'Rifiuta',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }

  String _formatTime(String timeString) {
    try {
      final time = DateFormat('HH:mm:ss').parse(timeString);
      return DateFormat('HH:mm').format(time);
    } catch (e) {
      return timeString;
    }
  }

  // Funzione per formattare la data
  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString).toLocal();
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }
}