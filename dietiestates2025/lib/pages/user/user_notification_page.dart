import 'package:dietiestates2025/data/repositories/visita_repositories.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/proposta_repositories.dart';
import '../../provider/auth_provider.dart';
import '../../services/http_service.dart';
import '../../services/navigation_service.dart';

import '../../widgets/user_bottom_bar_widget.dart';

import 'user_home_page.dart';
class UserNotificationPage extends StatefulWidget {
  final String query;

  const UserNotificationPage({super.key, required this.query});

  @override
  _UserNotificationPageState createState() => _UserNotificationPageState();
}

class _UserNotificationPageState extends State<UserNotificationPage> {
  int _selectedIndex = 2;
  final PropostaRepository _propostaRepository = PropostaRepository();
  final VisitaRepositories _visitaRepository = VisitaRepositories(HttpService());

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    NavigationService.navigateToBottomBarPage(index);
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
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _loadNotifiche(usernameLoggato),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Errore: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nessuna notifica trovata.'));
                }

                final notifiche = snapshot.data!;

                return ListView.builder(
                  itemCount: notifiche.length,
                  itemBuilder: (context, index) {
                    final notifica = notifiche[index];
                    return _buildCard(notifica);
                  },
                );
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

  // Metodo per recuperare le notifiche
  Future<List<Map<String, dynamic>>> _loadNotifiche(String username) async {
    final proposteRaw = await _propostaRepository.getPropostePerUsername(username);
    final visiteRaw = await _visitaRepository.getVisiteByUsername(username);

    final proposteMapped = proposteRaw.map<Map<String, dynamic>>((p) => {
      ...p.cast<String, dynamic>(),
      'tipo': 'proposta',
      'data': p['data_proposta'],
    });

    final visiteMapped = visiteRaw.map<Map<String, dynamic>>((v) => {
      ...v.cast<String, dynamic>(),
      'tipo': 'visita',
      'data': v['data_visita'],
    });

    final tutteNotifiche = [...proposteMapped, ...visiteMapped];

    tutteNotifiche.sort((a, b) {
      final dateA = DateTime.tryParse(a['data']);
      final dateB = DateTime.tryParse(b['data']);
      return dateB?.compareTo(dateA ?? DateTime(2000)) ?? 0;
    });

    return tutteNotifiche;
  }

  AppBar _buildAppBar(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return AppBar(
      title: Text(
        'Notifiche',
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

  // Metodo per costruire la card
  Widget _buildCard(Map<String, dynamic> notifica) {
    final titolo = notifica['titolo'] ?? 'Titolo non disponibile';
    final tipo = notifica['tipo'];
    final data = notifica['data'];
    final formattedDate = _formatDate(data);
    final agente = notifica['username_agente'] ?? 'Agente non disponibile';

    if (tipo == 'proposta') {
      final stato = notifica['stato_proposta'] ?? 'N/A';
      final agente = notifica['username_agente'] ?? 'Agente non disponibile';

      TextSpan getMessage(String stato) {
        switch (stato.toLowerCase()) {
          case 'accettata':
            return TextSpan(
              children: [
                TextSpan(
                  text: 'Congratulazioni! 🎉\nLa tua offerta per "$titolo" è stata accettata. Un nostro agente ti contatterà a breve.\n',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: Colors.green),
                ),
                TextSpan(
                  text: '\n 📨Inviato da: $agente',
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.black),
                ),
              ],
            );
          case 'rifiutata':
            return TextSpan(
              children: [
                TextSpan(
                  text: 'Ci dispiace. 😞\nLa tua offerta per "$titolo" è stata rifiutata. Ti invitiamo a consultare altri immobili disponibili.\n',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: Colors.red),
                ),
                TextSpan(
                  text: '\n 📨Inviato da: $agente',
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.black),
                ),
              ],
            );
          case 'in attesa':
            return TextSpan(
              children: [
                TextSpan(
                  text: 'La tua offerta è in attesa di risposta ⏳\nLa tua offerta per "$titolo" è stata ricevuta ed è attualmente in fase di valutazione.\n',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: Colors.orange),
                ),
              ],
            );
          case 'controproposta':
            return TextSpan(
              children: [
                TextSpan(
                  text: 'Hai ricevuto una controproposta. 💰\nAttendiamo la tua risposta in merito alla controproposta per "$titolo".\nSiamo in attesa di un tuo riscontro per accettare o rifiutare la controproposta di $agente.',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: Colors.lightBlue),
                ),
              ],
            );
          default:
            return const TextSpan();
        }
      }

      return _buildNotificaCard(
        formattedDate: formattedDate,
        contenuto: getMessage(stato),
        infoFooter: 'Tipo: Proposta',
        borderColor: stato == 'Accettata'
            ? Colors.green
            : (stato == 'Rifiutata'
            ? Colors.red
            : (stato == 'In attesa'
            ? Colors.orange
            : (stato == 'Controproposta'
            ? Colors.blue
            : Colors.grey
            )
          )
        ),
      );
    }

    if (tipo == 'visita') {
      final stato = notifica['stato_visita'] ?? 'N/A';

      TextSpan getMessage(String stato) {
        switch (stato.toLowerCase()) {
          case 'completata':
            return TextSpan(
              children: [
                TextSpan(
                  text: 'Visita completata! ✅\nHai visitato con successo l\'immobile "$titolo". Speriamo sia stata un\'esperienza utile.\n',
                  style: TextStyle(fontWeight: FontWeight.w700, color: Colors.green),
                ),
                TextSpan(
                  text: '\n 📨Inviato da: $agente',
                  style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
                ),
              ],
            );
          case 'annullata':
            return TextSpan(
              children: [
                TextSpan(
                  text: 'Visita annullata. ❌ \nLa visita per "$titolo" è stata annullata. Ti consigliamo di contattare l\'agente per riprogrammarla.\n',
                  style: TextStyle(fontWeight: FontWeight.w700, color: Colors.red),
                ),
                TextSpan(
                  text: '\n 📨Inviato da: $agente',
                  style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
                ),
              ],
            );
          case 'in attesa':
            return TextSpan(
              children: [
                TextSpan(
                  text: 'Visita In attesa di risposta. ⏳\nLa tua offerta per "$titolo" è stata ricevuta ed è attualmente in fase di valutazione.\n',
                  style: TextStyle(fontWeight: FontWeight.w700, color: Colors.orange),
                ),
              ],
            );
          default:
            return const TextSpan();
        }
      }

      return _buildNotificaCard(
        formattedDate: formattedDate,
        contenuto: getMessage(stato),
        infoFooter: 'Tipo: Visita',
        borderColor: stato == 'In attesa'
            ? Colors.orange
            : stato == 'Completata'
            ? Colors.green
            : Colors.red,
      );
    }

    return const SizedBox.shrink();
  }

  // Metodo per costruire la card
  Widget _buildNotificaCard({
    required String formattedDate,
    required TextSpan contenuto,
    required String infoFooter,
    required Color borderColor,
  }) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 1.5),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('📆Data: $formattedDate', style: const TextStyle(fontSize: 14)),
                Text(infoFooter, style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            RichText(text: contenuto),
          ],
        ),
      ),
    );
  }

  // Metodo per formattare la data
  String _formatDate(String date) {
    try {
      final dateTime = DateTime.parse(date).toLocal();
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return date;
    }
  }

}