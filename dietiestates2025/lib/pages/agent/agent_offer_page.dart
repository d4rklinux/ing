import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../data/repositories/proposta_repositories.dart';
import '../../services/navigation_service.dart';
import '../../provider/auth_provider.dart';
import '../../widgets/agent_bottom_bar_widget.dart';

import '../agent/agent_home_page.dart';
import 'agent_send_offer_page.dart';

class AgentOfferPage extends StatefulWidget {
  const AgentOfferPage({super.key});

  @override
  State<AgentOfferPage> createState() => _AgentOfferPageState();
}

class _AgentOfferPageState extends State<AgentOfferPage> {
  int _selectedIndex = 3;
  final PropostaRepository _propostaRepository = PropostaRepository();
  String selectedFilter = 'Tutte';

  // Funzione per gestire il cambio di pagina
  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
    NavigationService.navigateToAgentBottomBarPage(index);
  }

  // Funzione per inizializzare i dati
  void _filterOffers(String filter) {
    setState(() {
      selectedFilter = filter;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ottieni l'istanza dell'utente loggato
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final usernameLoggato = authProvider.currentUser?.username;

    if (usernameLoggato == null) {
      return const Scaffold(
        body: Center(child: Text('Utente non loggato')),
      );
    }

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _propostaRepository.getTutteLeProposte(),
              builder: (context, snapshot) {
                //Se la richiesta è in corso, mostra un circular progress indicator
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Errore: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nessuna offerta trovata.'));
                }

                final proposte = snapshot.data!;
                // Filtra le proposte in base al filtro selezionato
                List<Map<String, dynamic>> proposteFiltrate = [];
                if (selectedFilter == 'Tutte') {
                  proposteFiltrate = proposte;
                } else {
                  proposteFiltrate = proposte.where((p) => p['stato_proposta'] == selectedFilter).toList();
                }
                // Ordina le proposte in base alla data e all'ora
                proposteFiltrate.sort((a, b) {
                  final dateTimeA = _parseDateTime(a['data_proposta'], a['ora_proposta']);
                  final dateTimeB = _parseDateTime(b['data_proposta'], b['ora_proposta']);
                  if (dateTimeA != null && dateTimeB != null) {
                    return dateTimeB.compareTo(dateTimeA);
                  } else if (dateTimeA == null && dateTimeB != null) {
                    return 1;
                  } else if (dateTimeA != null && dateTimeB == null) {
                    return -1;
                  }
                  return 0;
                });
                // Divide le proposte in tre categorie: in attesa, accettate e rifiutate
                final inAttesa = proposteFiltrate.where((p) => p['stato_proposta'] == 'In attesa').toList();
                final controproposte = proposteFiltrate.where((p) => p['stato_proposta'] == 'Controproposta').toList();
                final accettate = proposteFiltrate.where((p) => p['stato_proposta'] == 'Accettata').toList();
                final rifiutate = proposteFiltrate.where((p) => p['stato_proposta'] == 'Rifiutata').toList();

                return ListView(
                  children: [
                    ..._buildSection('Offerte In attesa', inAttesa, width, height),
                    ..._buildSection('Controproposte Inviate', controproposte, width, height),
                    ..._buildSection('Offerte Accettate', accettate, width, height),
                    ..._buildSection('Offerte Rifiutate', rifiutate, width, height),
                  ],
                );
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

  // Funzione per costruire le sezioni
  List<Widget> _buildSection(String titolo, List<dynamic> lista, double width, double height) {
    if (lista.isEmpty) return [];

    lista.sort((a, b) {
      DateTime dateA = DateTime.parse(a['data_proposta']);
      DateTime dateB = DateTime.parse(b['data_proposta']);
      return dateB.compareTo(dateA);
    });

    Color getTitoloColor(String titolo) {
      if (titolo.toLowerCase().contains('in attesa')) return Colors.orange;
      if (titolo.toLowerCase().contains('controproposte')) return Colors.lightBlue;
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
      ...lista.map((offerta){
        return _buildOfferCard(offerta, width, height);}
      )];
  }

  // Funzione per convertire una data e un orario in un oggetto DateTime
  DateTime? _parseDateTime(String date, String time) {
    try {
      final parsedDate = DateTime.parse(date);
      final parsedTime = _parseTime(time);
      if (parsedTime != null) {
        return DateTime(parsedDate.year, parsedDate.month, parsedDate.day, parsedTime.hour, parsedTime.minute);
      }
      return parsedDate;
    } catch (_) {
      return null;
    }
  }

  // Funzione per convertire un orario in un oggetto DateTime
  DateTime? _parseTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return DateTime(0, 1, 1, hour, minute);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  // Funzione per costruire l'AppBar
  AppBar _buildAppBar(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return AppBar(
      title: Text(
        'Storico delle proposte',
        style: TextStyle(
          color: Colors.white,
          fontSize: width * 0.045,
          fontWeight: FontWeight.w400,
        ),
      ),
      backgroundColor: const Color(0xFF0079BB),
      leading: IconButton(
        icon: const Icon(Icons.home_filled, color: Colors.white),
        onPressed: () => NavigationService.navigateTo(const AgentHomePage()),
      ),
    );
  }

  // Funzione per costruire la barra di filtro
  Widget _buildFilterBar() {
    final bool isAnyFilterUsed = selectedFilter != 'Tutte';

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isAnyFilterUsed ? Colors.orange : Colors.blue,
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
                  'Filtra le offerte',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isAnyFilterUsed ? Colors.orange : Colors.blue,
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
                      _buildFilterButton('Controproposta'),
                      _buildFilterButton('Accettata'),
                      _buildFilterButton('Rifiutata'),
                      ],
                    ),
                ],
        ),
      ),
    ]
    ),
      ),
    );
  }

  // Funzione per costruire il pulsante dei filtri
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
          onPressed: () => _filterOffers(label),
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

  // Funzione per costruire la card della offerta
  Widget _buildOfferCard(Map<String, dynamic> offerta, double width, double height) {
    final titolo = offerta['titolo'] ?? 'Titolo non disponibile';
    final tipologia = offerta['tipologia_immobile'] ?? 'Tipologia non disponibile';
    final vecchioPrezzo = _parsePrice(offerta['vecchio_prezzo']);
    final nuovoPrezzo = _parsePrice(offerta['nuovo_prezzo']);
    final prezzoControproposta = _parsePrice(offerta['controproposta']);
    final stato = offerta['stato_proposta'] ?? 'N/A';
    final data = offerta['data_proposta'] ?? 'N/A';
    final ora = offerta['ora_proposta'] ?? 'N/A';
    final nome = offerta['nome_utente'] ?? 'N/A';
    final cognome = offerta['cognome_utente'] ?? 'N/A';
    final idProposta = offerta['id_proposta'];

    final formattedDate = _formatDate(data);
    final formattedTime = _formatTime(ora);
    final formattedVecchioPrezzo = _formatPrice(vecchioPrezzo);
    final formattedNuovoPrezzo = _formatPrice(nuovoPrezzo);
    final formattedControproposta = _formatPrice(prezzoControproposta);

    Color getCardBorderColor(String stato) {
      switch (stato.toLowerCase()) {
        case 'in attesa':
          return Colors.orange;
        case 'controproposta':
          return Colors.lightBlue;
        case 'accettata':
          return Colors.green;
        case 'rifiutata':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: getCardBorderColor(stato), width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.005),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(offerta),
            const SizedBox(height: 10),
            _buildRow(Icons.info, 'Stato: $stato', getCardBorderColor(stato), width),
            Row(
              children: [
                _buildRow(Icons.calendar_today, 'Data: $formattedDate', Colors.brown, width),
                const SizedBox(width: 10),
                _buildRow(Icons.access_time, 'Ore: $formattedTime', Colors.brown, width),
              ],
            ),
            _buildRow(Icons.person, 'Nome: $nome $cognome', Colors.blueGrey, width),
            _buildRow(Icons.title, 'Titolo: $titolo', Colors.black, width),
            _buildRow(Icons.home_work, 'Tipologia: $tipologia', Colors.pink, width),
            _buildRow(Icons.monetization_on, 'Prezzo Originario: €$formattedVecchioPrezzo', Colors.red, width),
            _buildRow(Icons.monetization_on, 'Offerta: €$formattedNuovoPrezzo', Colors.blue, width),
            if(stato == 'Controproposta')
              _buildRow(Icons.monetization_on, 'Controproposta: €$formattedControproposta', Colors.purple, width),
            const SizedBox(height: 8),

          if (stato == 'In attesa') Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () => NavigationService.navigateTo(AgentSendOfferPage(immobile: offerta, proposta: offerta)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.orange, width: 2),
          ),
          child: const Text(
            'Proponi',
            style: TextStyle(color: Colors.orange),
          ),
        ),
        const SizedBox(width: 10),
        OutlinedButton(
          onPressed: () => _gestisciAggiornamentoProposta(idProposta, 'Accettata'),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.green, width: 2),
          ),
          child: const Text(
            'Conferma',
            style: TextStyle(color: Colors.green),
          ),
        ),
        const SizedBox(width: 10),
        OutlinedButton(
          onPressed: () => _gestisciAggiornamentoProposta(idProposta, 'Rifiutata'),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red, width: 2),
          ),
          child: const Text(
            'Rifiuta',
            style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Funzione per gestire l'aggiornamento della proposta
  void _gestisciAggiornamentoProposta(int idProposta, String nuovoStato) async {
    final risultato = await _propostaRepository.aggiornaProposta(
      idProposta: idProposta,
      statoProposta: nuovoStato,
    );

    if (!mounted) return;

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Aggiornamento"),
          content: Text(risultato),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    setState(() {});
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

  // Funzione per costruire l'immagine
  Widget _buildImage(Map<String, dynamic> visita) {
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

  // Converte la data nel formato dd/MM/yyyy
  String _formatDate(String date) {
    try {
      final dateTime = DateTime.parse(date).toLocal();
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return date;
    }
  }

  // Converte l'orario nel formato HH:mm
  String _formatTime(String time) {
    try {
      final dateTime = DateTime.parse('1970-01-01 $time').toLocal();
      final timeFormat = DateFormat('HH:mm');
      return timeFormat.format(dateTime);
    } catch (e) {
      return time;
    }
  }

  // Converte il prezzo in un formato leggibile
  String _formatPrice(double price) {
    try {
      final formatter = NumberFormat('#,##0', 'it_IT');
      return formatter.format(price);
    } catch (e) {
      return price.toString();
    }
  }

  // Converte il prezzo in un double
  double _parsePrice(dynamic price) {
    if (price is int) {
      return price.toDouble();
    } else if (price is double) {
      return price;
    } else {
      return 0.0;
    }
  }
}
