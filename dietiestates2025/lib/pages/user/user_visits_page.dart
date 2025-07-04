import 'package:dietiestates2025/pages/user/user_home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../services/http_service.dart';
import '../../services/navigation_service.dart';
import '../../provider/auth_provider.dart';
import '../../widgets/user_bottom_bar_widget.dart';
import '../../data/repositories/visita_repositories.dart';

class UserVisitsPage extends StatefulWidget {
  const UserVisitsPage({super.key});

  @override
  State<UserVisitsPage> createState() => _UserVisitsPageState();
}

class _UserVisitsPageState extends State<UserVisitsPage> {
  int _selectedIndex = 1;
  final VisitaRepositories _visitaRepository = VisitaRepositories(HttpService());
  String selectedFilter = 'Tutte';

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    NavigationService.navigateToBottomBarPage(index);
  }

  // Funzione per cambiare il filtro
  void _filterVisits(String filter) {
    setState(() {
      selectedFilter = filter;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final username = authProvider.currentUser?.username;

    if (username == null) {
      return const Scaffold(
        body: Center(child: Text('Utente non loggato')),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(context),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _visitaRepository.getAllVisita(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Errore: ${snapshot.error}'));
                }

                final visiteUtente = (snapshot.data ?? [])
                    .where((v) => v['username_utente'] == username)
                    .toList();

                final visiteFiltrate = selectedFilter == 'Tutte'
                    ? visiteUtente
                    : selectedFilter == 'In attesa'
                    ? visiteUtente.where((v) =>
                v['stato_visita'] != 'Completata' &&
                    v['stato_visita'] != 'Annullata').toList()
                    : selectedFilter == 'Accettata'
                    ? visiteUtente.where((v) => v['stato_visita'] == 'Completata').toList()
                    : selectedFilter == 'Rifiutata'
                    ? visiteUtente.where((v) => v['stato_visita'] == 'Annullata').toList()
                    : visiteUtente;

                if (visiteFiltrate.isEmpty) {
                  return const Center(child: Text('Nessuna visita trovata.'));
                }

                visiteFiltrate.sort((a, b) {
                  final dateA = DateTime.tryParse(a['data_visita']);
                  final dateB = DateTime.tryParse(b['data_visita']);
                  if (dateA != null && dateB != null) {
                    return dateB.compareTo(dateA);
                  }
                  return 0;
                });

                List<Widget> sections = [];
                sections.addAll(_buildSection(
                    'Visite In attesa',
                    visiteFiltrate.where((v) =>
                    v['stato_visita'] != 'Completata' &&
                        v['stato_visita'] != 'Annullata').toList(),
                    MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height));
                sections.addAll(_buildSection(
                    'Visite Accettate',
                    visiteFiltrate.where((v) =>
                    v['stato_visita'] == 'Completata').toList(),
                    MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height));
                sections.addAll(_buildSection(
                    'Visite Rifiutate',
                    visiteFiltrate.where((v) =>
                    v['stato_visita'] == 'Annullata').toList(),
                    MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height));

                return ListView(children: sections);
              },
            ),
          )
        ],
      ),
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
        return _buildVisitCard(visita);
      }
      )
    ];
  }

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
                expansionTileTheme: const ExpansionTileThemeData(
                  backgroundColor: Colors.white,
                  collapsedBackgroundColor: Colors.white,
                ),
              ),
              child: ExpansionTile(
                title: Text(
                  'Filtra le visite',
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
                        _buildFilterButton('In attesa'),
                        _buildFilterButton('Accettata'),
                        _buildFilterButton('Rifiutata'),
                      ],
                    ),
                  )
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

  // Funzione per costruire l'AppBar
  AppBar _buildAppBar(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return AppBar(
      title: Text(
        'Storico delle tue visite',
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

  // Funzione per costruire la card della visita
  Widget _buildVisitCard(Map<String, dynamic> visita) {
    final titolo = visita['titolo'] ?? 'Titolo immobile non disponibile';
    final tipologia = visita['tipologia_immobile'] ?? 'Tipologia non disponibile';
    final prezzo = visita['prezzo'] ?? 0;
    final stato = visita['stato_visita'] ?? 'N/A';
    final data = visita['data_visita'] ?? 'N/A';
    final ora = visita['ora_visita'] ?? 'N/A';

    // Funzione per determinare il colore del bordo in base allo stato
    Color getBorderColor(String stato) {
      switch (stato.toLowerCase()) {
        case 'in attesa':
          return Colors.orange;
        case 'completata':
          return Colors.green;
        case 'annullata':
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
            _buildImage(visita),
            const SizedBox(height: 10),
            _buildRow(Icons.info, 'Stato: $stato', getBorderColor(stato), context),
            Row(
              children: [
                _buildRow(Icons.calendar_today, 'Data: ${_formatDate(data)}', Colors.brown, context),
                const SizedBox(width: 10),
                _buildRow(Icons.access_time, 'Ore: ${_formatTime(ora)}', Colors.brown, context),
              ],
            ),
            _buildRow(Icons.title, 'Titolo: $titolo', Colors.black, context),
            _buildRow(Icons.home_work, 'Tipologia: $tipologia', Colors.pink, context),
            _buildRow(Icons.monetization_on, 'Prezzo: €${NumberFormat('#,##0', 'it_IT').format(prezzo)}', Colors.blue, context),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // Funzione per costruire le righe della card
  Widget _buildRow(IconData icon, String text, Color color, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style:
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

}