import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'home_page.dart';

import 'user/user_home_page.dart';

import 'agent/agent_home_page.dart';

import '../provider/auth_provider.dart';

class ImmobileDetailPage extends StatelessWidget {
  final Map<String, dynamic> immobile;

  const ImmobileDetailPage({super.key, required this.immobile});

  // Crea la lista dei servizi aggiuntivi disponibili per l'immobile
  List<String> _buildServizi() {
    List<String> servizi = [];
    if (immobile['climatizzatore'] == true) servizi.add('Climatizzatore');
    if (immobile['balcone'] == true) servizi.add('Balcone');
    if (immobile['portineria'] == true) servizi.add('Portineria');
    if (immobile['giardino'] == true) servizi.add('Giardino');
    if (immobile['ascensore'] == true) servizi.add('Ascensore');
    if (immobile['arredato'] == true) servizi.add('Arredato');
    return servizi;
  }

  // Widget per visualizzare il titolo dell'immobile
  Widget _buildTitolo() {
    return Center(
      child: Text(
        immobile['titolo'] ?? 'Titolo non disponibile',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF333333),
          fontFamily: 'Roboto',
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // Widget per visualizzare le foto dell'immobile
  Widget _buildFoto(BuildContext context) {
    if (immobile['percorso_file'] != null) {
      return Center(
        child: Image.network(
          immobile['percorso_file'],
          fit: BoxFit.cover,
          width: MediaQuery.of(context).size.width * 0.9,
          height: 200,
          errorBuilder: (context, error, stackTrace) =>
          const Text('Immagine non disponibile'),
        ),
      );
    } else {
      return const Text('Nessuna foto disponibile');
    }
  }

  // Widget per visualizzare il contratto e la tipologia dell'immobile
  Widget _buildContrattoTipologia() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.assignment, color: Colors.blueAccent),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black),
                  children: [
                    const TextSpan(
                        text: 'Contratto: ',
                        style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    TextSpan(
                        text: immobile['tipo_contratto'] ?? 'N/A',
                        style: const TextStyle(fontWeight: FontWeight.w300)
                    ),
                  ],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.home_work, color: Colors.teal),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black),
                  children: [
                    const TextSpan(
                        text: 'Tipologia: ',
                        style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    TextSpan(
                        text: immobile['tipologia_immobile'] ?? 'N/A',
                        style: const TextStyle(fontWeight: FontWeight.w300)
                    ),
                  ],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget per visualizzare l'indirizzo dell'immobile
  Widget _buildIndirizzo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.location_on, color: Colors.redAccent),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black),
              children: [
                const TextSpan(
                  text: 'Indirizzo: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: '${immobile['via']}, ${immobile['città']}, ${immobile['provincia']}, ${immobile['cap']}',
                  style: const TextStyle(fontWeight: FontWeight.w300),
                ),
              ],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  // Widget per visualizzare la descrizione dell'immobile
  Widget _buildDescrizione() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.description, color: Colors.brown),
            SizedBox(width: 8),
            Text(
              'Descrizione:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            immobile['descrizione'] ?? immobile['testo'] ?? 'Descrizione non disponibile',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w300),
          ),
        ),
      ],
    );
  }

// Widget per visualizzare la superficie e il prezzo dell'immobile
  Widget _buildPrezzoSuperficie() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.square_foot, color: Colors.amber),
            const SizedBox(width: 8),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black),
                children: [
                  const TextSpan(
                      text: 'Superficie: ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold
                      )
                  ),
                  TextSpan(
                      text: '${immobile['superficie'] ?? 'N/A'} m²',
                      style: const TextStyle(fontWeight: FontWeight.w300)
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.euro, color: Colors.green),
            const SizedBox(width: 8),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black),
                children: [
                  const TextSpan(
                      text: 'Prezzo: ',
                      style: TextStyle(fontWeight: FontWeight.bold)
                  ),
                  TextSpan(
                      text: '€ ${NumberFormat('#,##0', 'it_IT').format(immobile['prezzo'] ?? 0)}',
                      style: const TextStyle(fontWeight: FontWeight.w300)
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget per visualizzare i filtri avanzati dell'immobile
  Widget _buildFiltroAvanzato() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.hotel, color: Colors.purple),
            const SizedBox(width: 8),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black),
                children: [
                  const TextSpan(
                      text: 'Stanze: ',
                      style: TextStyle(fontWeight: FontWeight.bold)
                  ),
                  TextSpan(
                      text: '${immobile['stanza'] ?? 'N/A'}',
                      style: const TextStyle(fontWeight: FontWeight.w300)
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.bathtub, color: Colors.pink),
            const SizedBox(width: 8),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black),
                children: [
                  const TextSpan(
                      text: 'Bagni: ',
                      style: TextStyle(fontWeight: FontWeight.bold)
                  ),
                  TextSpan(
                      text: '${immobile['bagno'] ?? 'N/A'}',
                      style: const TextStyle(fontWeight: FontWeight.w300)
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.stairs, color: Colors.indigo),
            const SizedBox(width: 8),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black),
                children: [
                  const TextSpan(
                      text: 'Piano: ',
                      style: TextStyle(fontWeight: FontWeight.bold)
                  ),
                  TextSpan(
                      text: '${immobile['piano'] ?? 'N/A'}',
                      style: const TextStyle(fontWeight: FontWeight.w300)
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.local_parking, color: Colors.blueAccent),
            const SizedBox(width: 8),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black),
                children: [
                  const TextSpan(
                      text: 'Parcheggio: ',
                      style: TextStyle(fontWeight: FontWeight.bold)
                  ),
                  TextSpan(
                      text: '${immobile['parcheggio'] ?? 'N/A'}',
                      style: const TextStyle(fontWeight: FontWeight.w300)
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.energy_savings_leaf_outlined, color: Colors.green),
            const SizedBox(width: 8),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black),
                children: [
                  const TextSpan(
                      text: 'Classe Energetica: ',
                      style: TextStyle(fontWeight: FontWeight.bold)
                  ),
                  TextSpan(
                      text: '${immobile['classe_energetica'] ?? 'N/A'}',
                      style: const TextStyle(fontWeight: FontWeight.w300)
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget per visualizzare i servizi aggiuntivi dell'immobile
  Widget _buildServiziUlteriori() {
    final servizi = _buildServizi();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.star, color: Colors.orange),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black),
              children: [
                const TextSpan(
                    text: 'Servizi Ulteriori: ',
                    style: TextStyle(fontWeight: FontWeight.bold)
                ),
                TextSpan(
                    text: servizi.isNotEmpty ? servizi.join(', ') : 'Nessuno',
                    style: const TextStyle(fontWeight: FontWeight.w300)
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget per visualizzare il nome dell'agente che ha pubblicato l'immobile
  Widget _buildAgente() {
    if (immobile['username_agente'] != null) {
      return Row(
        children: [
          const Icon(Icons.person, color: Colors.black),
          const SizedBox(width: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black),
              children: [
                const TextSpan(
                    text: 'Pubblicato e gestito da: ',
                    style: TextStyle(fontWeight: FontWeight.bold)
                ),
                TextSpan(
                    text: immobile['username_agente'],
                    style: const TextStyle(fontWeight: FontWeight.w300)
                ),
              ],
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  // Gestisce il cambio di pagina
  void _navigateBackBasedOnRole(BuildContext context) {
    final idRuolo = Provider.of<AuthProvider>(context, listen: false).currentUser?.idRuolo;
    Widget destination;

    if (idRuolo == 3) {
      destination = const AgentHomePage();
    } else if (idRuolo == 4) {
      destination = const UserHomePage();
    } else {
      destination = const HomePage();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  // Costruisce la pagina con i dettagli dell'immobile
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Dettagli Immobile',
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: const Color(0xFF0079BB),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Verifica se è la prima pagina della stack
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
              // Verifica il ruolo dell'utente
            } else {
              _navigateBackBasedOnRole(context);
            }
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
                maxWidth: 800,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFoto(context),
                  const SizedBox(height: 16),
                  _buildTitolo(),
                  const SizedBox(height: 16),
                  _buildIndirizzo(),
                  const SizedBox(height: 16),
                  _buildContrattoTipologia(),
                  const SizedBox(height: 16),
                  _buildPrezzoSuperficie(),
                  const SizedBox(height: 16),
                  _buildDescrizione(),
                  const SizedBox(height: 16),
                  _buildFiltroAvanzato(),
                  const SizedBox(height: 16),
                  _buildServiziUlteriori(),
                  const SizedBox(height: 16),
                  _buildAgente(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}