import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/proposta_repositories.dart';

import '../../provider/auth_provider.dart';

import '../../services/navigation_service.dart';

import 'agent_home_page.dart';

class AgentNotificationPage extends StatefulWidget {

  const AgentNotificationPage({super.key});

  @override
  _AgentNotificationPage createState() => _AgentNotificationPage();
}

class _AgentNotificationPage extends State<AgentNotificationPage> {
  final PropostaRepository _propostaRepository = PropostaRepository();

  // Metodo per costruire la pagina
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
    );
  }

  // Metodo per recuperare le notifiche
  Future<List<Map<String, dynamic>>> _loadNotifiche(String username) async {
    final proposteRaw = await _propostaRepository.getPropostePerAgenteControproposta(username);

    final proposteMapped = proposteRaw.map<Map<String, dynamic>>((p) => {
      ...p.cast<String, dynamic>(),
      'tipo': 'proposta',
      'data': p['data_proposta'],
    });

    final tutteNotifiche = [...proposteMapped];

    tutteNotifiche.sort((a, b) {
      final dateA = DateTime.tryParse(a['data']);
      final dateB = DateTime.tryParse(b['data']);
      return dateB?.compareTo(dateA ?? DateTime(2000)) ?? 0;
    });

    return tutteNotifiche;
  }

  // Metodo per costruire l'app bar
  AppBar _buildAppBar(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return AppBar(
      title: Text(
        'Notifiche Agente',
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

  // Metodo per costruire la card
  Widget _buildCard(Map<String, dynamic> notifica) {
    final data = notifica['data'];
    final formattedDate = _formatDate(data);
    final utente = notifica['username_utente_proposta'] ?? 'Agente non disponibile';
    final stato = notifica['stato_proposta'] ?? 'N/A';

    if (stato != null) {
      final stato = notifica['stato_proposta'] ?? 'N/A';

      TextSpan getMessage(String stato) {
        switch (stato.toLowerCase()) {
          case 'in attesa':
            return TextSpan(
              children: [
                TextSpan(
                  text: '”$utente ha inviato un’offerta 💼\nTi invitiamo a valutarla e a scegliere se accettarla o rifiutarla.”',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: Colors.orange),
                ),
              ],
            );
          case 'controproposta':
            return TextSpan(
              children: [
                TextSpan(
                  text: 'Hai effettuato una controproposta 💰\nAttendi che $utente la valuti e decida se accettarla o rifiutarla.',
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
        borderColor: stato == 'In attesa'
            ? Colors.orange
            : (stato == 'Controproposta'
            ? Colors.blue
            : Colors.grey
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // Metodo per costruire la card di notifica
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

