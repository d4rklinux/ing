import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'user_home_page.dart';
import '../../data/repositories/proposta_repositories.dart';
import '../../services/navigation_service.dart';
import '../../provider/auth_provider.dart';
import '../../widgets/user_bottom_bar_widget.dart';

class UserOfferPage extends StatefulWidget {
  final String query;

  const UserOfferPage({super.key, required this.query});

  @override
  _UserOfferPageState createState() => _UserOfferPageState();
}

class _UserOfferPageState extends State<UserOfferPage> {
  int _selectedIndex = 3;
  final PropostaRepository _propostaRepository = PropostaRepository();
  String selectedFilter = 'Tutte';

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    NavigationService.navigateToBottomBarPage(index);
  }

  void _filterOffers(String filter) {
    setState(() {
      selectedFilter = filter;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final usernameLoggato = authProvider.currentUser?.username;

    if (usernameLoggato == null) {
      return const Scaffold(
        body: Center(child: Text('Utente non loggato')),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _propostaRepository.getPropostePerUsername(
                  usernameLoggato),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Errore: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nessuna offerta trovata.'));
                }

                final proposte = snapshot.data!;
                List<Map<String, dynamic>> proposteFiltrate = [];

                if (selectedFilter == 'Tutte') {
                  proposteFiltrate = proposte;
                } else {
                  proposteFiltrate =
                      proposte.where((p) =>
                      p['stato_proposta'] ==
                          selectedFilter).toList();
                }

                proposteFiltrate.sort((a, b) {
                  final dateA = DateTime.tryParse(a['data_proposta']);
                  final dateB = DateTime.tryParse(b['data_proposta']);
                  if (dateA != null && dateB != null) {
                    return dateB.compareTo(dateA);
                  }
                  return 0;
                });

                final width = MediaQuery
                    .of(context)
                    .size
                    .width;
                final height = MediaQuery
                    .of(context)
                    .size
                    .height;

                if (selectedFilter == 'Tutte') {
                  final inAttesa = proposteFiltrate.where((
                      p) => p['stato_proposta'] == 'In attesa').toList();
                  final controproposte = proposteFiltrate.where((
                      p) => p['stato_proposta'] == 'Controproposta').toList();
                  final accettate = proposteFiltrate.where((
                      p) => p['stato_proposta'] == 'Accettata').toList();
                  final rifiutate = proposteFiltrate.where((
                      p) => p['stato_proposta'] == 'Rifiutata').toList();

                  return ListView(
                    children: [
                      ..._buildSection('Offerte In attesa', inAttesa, width, height),
                      ..._buildSection('Controproposte Ricevute', controproposte, width, height),
                      ..._buildSection('Offerte Accettate', accettate, width, height),
                      ..._buildSection('Offerte Rifiutate', rifiutate, width, height),
                    ],
                  );
                } else {
                  return ListView.builder(
                    itemCount: proposteFiltrate.length,
                    itemBuilder: (context, index) {
                      final offerta = proposteFiltrate[index];
                      return _buildOfferCard(offerta);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: UserBottomBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  // Funzione per costruire le sezioni
  List<Widget> _buildSection(String titolo, List<dynamic> lista, double width,
      double height) {
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
      ...lista.map((offerta) {
        return _buildOfferCard(offerta);
      }
      )
    ];
  }

  // Gestisce la barra dei filtri avanzati
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildFilterButton('Tutte'),
                        _buildFilterButton('Controproposta'),
                        _buildFilterButton('In attesa'),
                        _buildFilterButton('Accettata'),
                        _buildFilterButton('Rifiutata'),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ]
        )
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

  // Funzione per costruire l'AppBar
  AppBar _buildAppBar(BuildContext context) {
    final width = MediaQuery
        .of(context)
        .size
        .width;
    return AppBar(
      title: Text(
        'Storico delle tue offerte',
        style: TextStyle(
          color: Colors.white,
          fontSize: width * 0.045,
          fontWeight: FontWeight.w400,
        ),
      ),
      backgroundColor: const Color(0xFF0079BB),
      leading: IconButton(
        icon: const Icon(Icons.home_filled, color: Colors.white),
        onPressed: () => NavigationService.navigateTo(const UserHomePage()),
      ),
    );
  }

  // Funzione per costruire la card dell'offerta
  Widget _buildOfferCard(Map<String, dynamic> offerta) {
    final titolo = offerta['titolo'] ?? 'Titolo non disponibile';
    final tipologia = offerta['tipologia_immobile'] ??
        'Tipologia non disponibile';
    final vecchioPrezzo = _parsePrice(offerta['vecchio_prezzo']);
    final nuovoPrezzo = _parsePrice(offerta['nuovo_prezzo']);
    final prezzoControproposta = _parsePrice(offerta['controproposta']);
    final stato = offerta['stato_proposta'] ?? 'N/A';
    final data = offerta['data_proposta'] ?? 'N/A';
    final ora = offerta['ora_proposta'] ?? 'N/A';
    final idProposta = offerta['id_proposta'];

    final formattedDate = _formatDate(data);
    final formattedTime = _formatTime(ora);
    final formattedVecchioPrezzo = _formatPrice(vecchioPrezzo);
    final formattedNuovoPrezzo = _formatPrice(nuovoPrezzo);
    final formattedControproposta = _formatPrice(prezzoControproposta);

    Color getBorderColor(String stato) {
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
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: getBorderColor(stato), width: 1.5),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(offerta),
            const SizedBox(height: 8),
            _buildRow(Icons.info, 'Stato: $stato', getBorderColor(stato)),
            Row(
              children: [
                _buildRow(Icons.calendar_today, 'Data: $formattedDate', Colors.brown),
                const SizedBox(width: 10),
                _buildRow(Icons.access_time, 'Ore: $formattedTime', Colors.brown),
              ],
            ),
            _buildRow(Icons.title, 'Titolo: $titolo', Colors.black),
            _buildRow(Icons.home_work, 'Tipologia: $tipologia', Colors.pink),
            _buildRow(Icons.monetization_on, 'Prezzo Originario: €$formattedVecchioPrezzo', Colors.red),
            _buildRow(Icons.monetization_on, 'Offerta: €$formattedNuovoPrezzo', Colors.blue),
            if(stato == 'Controproposta')
              _buildRow(Icons.monetization_on, 'Controproposta: €$formattedControproposta', Colors.purple),
            const SizedBox(height: 8),

            if (stato == 'Controproposta') Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () =>
                      _aggiornaStatoControproposta(idProposta, 'Accettata'),
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
                  onPressed: () =>
                      _aggiornaStatoControproposta(idProposta, 'Rifiutata'),
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
  void _aggiornaStatoControproposta(int idProposta, String nuovoStato) async {
    final risultato = await _propostaRepository.aggiornaStatoControproposta(
      idProposta: idProposta,
      statoControproposta: nuovoStato,
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
  }

  // Funzione per costruire le righe della card
  Widget _buildRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
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
      errorBuilder: (context, error, stackTrace) =>
      const Text('Immagine non disponibile'),
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

  // Funzione per formattare il prezzo
  String _formatPrice(double price) {
    try {
      final formatter = NumberFormat('#,##0', 'it_IT');
      return formatter.format(price);
    } catch (e) {
      return price.toString();
    }
  }

  // Funzione per convertire il prezzo in double
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