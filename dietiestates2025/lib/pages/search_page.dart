import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'map_page.dart';

import 'immobile_detail_page.dart';

import '../pages/home_page.dart';
import '../pages/user/user_home_page.dart';
import '../pages/user/user_send_offer_page.dart';
import '../pages/user/user_send_visits_page.dart';
import '../pages/agent/agent_home_page.dart';

import '../data/repositories/immobile_repositories.dart';

import '../services/recent_search_service.dart';
import '../services/http_service.dart';
import '../services/geoapify_service.dart';

import '../provider/auth_provider.dart';

class SearchPage extends StatefulWidget {
   const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  List<dynamic> _results = [];
  List<dynamic> _originalResults = [];
  final RecentSearchesService _recentSearchesService = RecentSearchesService();
  bool _isLoading = false;
  late final ImmobileRepositories _immobileRepositories;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // Variabili per il filtro avanzato
  String _sortOrder = 'none';
  String _selectedTipologiaContratto = 'Tutti';
  String _selectedSuperficie = 'Tutti';
  String _selectedParcheggio = 'Tutti';
  String _selectedStanze = 'Tutti';
  String _selectedClasseEnergetica = 'Tutti';
  String _selectedBagno = "Tutti";
  String _selectedPiano = "Tutti";

  //Variabili per Servizio Ulteriore
  bool _selectedClimatizzatore = false;
  bool _selectedBalcone = false;
  bool _selectPortineria = false;
  bool _selectGiardino = false;
  bool _selectAscensore = false;
  bool _selectArredato = false;


  @override
  void initState() {
    super.initState();
    final httpService = HttpService();
    _immobileRepositories = ImmobileRepositories(httpService);
  }

  // Gestisce la ricerca
  Future<void> _searchImmobili(String query) async {
    if (query.isEmpty) {
      _showErrorDialog('Per favore, inserisci una città, provincia o CAP.');
      return;
    }

    setState(() {
      _isLoading = true;
      _results = [];
      _sortResults();
    });

    try {
      // Concatenare città e provincia per una ricerca più precisa
      final queryParts = query.split(","); // supponiamo che l'utente possa inserire città, provincia separati da una virgola
      String finalQuery = queryParts.length == 2
          ? '${queryParts[0].trim()} ${queryParts[1].trim()}' // Concatenare città e provincia
          : query.trim(); // Se solo una città o provincia è inserita, non concatenare

      final results = await _immobileRepositories.searchImmobili(finalQuery);

      if (!mounted) return;

      setState(() {
        _originalResults = List.from(results);
        _results = results;
        _isLoading = false;
      });

      if (_results.isEmpty) {
        _showErrorDialog('Nessun risultato trovato per "$query".');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Errore nella ricerca: $e');
    }
  }

  // Gestisce l'apertura della mappa
  Future<void> _openMap(String address) async {
    final geoapifyService = GeoapifyService();
    try {
      final coordinates = await geoapifyService.getCoordinatesFromAddress(address);

      if (!mounted) return;

      if (coordinates != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapPage(
              lat: coordinates['lat']!,
              lon: coordinates['lon']!,
              locationName: address,
            ),
          ),
        );
      } else {
        _showErrorDialog('Indirizzo non trovato sulla mappa');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Errore nel recuperare le coordinate: $e');
    }
  }

  // Gestisce il cambio di pagina
  void _navigateToHomePage(int? idRuolo) {
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
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  // Gestisce l'ordinamento dei risultati
  void _sortResults() {
    if (_sortOrder == 'asc') {
      _results.sort((a, b) => (a['prezzo'] ?? 0).compareTo(b['prezzo'] ?? 0));
    } else if (_sortOrder == 'desc') {
      _results.sort((a, b) => (b['prezzo'] ?? 0).compareTo(a['prezzo'] ?? 0));
    } else if (_sortOrder == 'none') {
      _results = List.from(_originalResults); // resetta all’ordine originale
    }
  }

  // Gestisce il filtro avanzato
  //(contratto, superficie, parcheggio, stanze, bagni, piano, classe energetica, clima, balcone, portineria, giardino, ascensore, arredato)
  void _applyFilters() {
    List<dynamic> filteredResults = List.from(_originalResults);

    filteredResults = filteredResults.where((result) {
      bool matchesTipologiaContratto = true;
      bool matchesSuperficie = true;
      bool matchesParcheggio = true;
      bool matchesStanze = true;
      bool matchesClasseEnergetica = true;
      bool matchesBagno = true;
      bool matchesPiano = true;
      bool matchesClimatizzatore = true;
      bool matchesBalcone = true;
      bool matchesPortineria = true;
      bool matchesGiardino = true;
      bool matchesAscensore = true;
      bool matchesArredato = true;


      // Filtro Contratto
      if (_selectedTipologiaContratto != 'Tutti') {
        matchesTipologiaContratto = result['tipo_contratto'] == _selectedTipologiaContratto;
      }

      // Filtro Superficie
      if (_selectedSuperficie != 'Tutti') {
        int superficie = result['superficie'] ?? 0;
        switch (_selectedSuperficie) {
          case 'Da 0 a 50 m²':
            matchesSuperficie = superficie >= 0 && superficie <= 50;
            break;
          case 'Da 51 a 100 m²':
            matchesSuperficie = superficie > 50 && superficie <= 100;
            break;
          case 'Da 101 a 200 m²':
            matchesSuperficie = superficie > 100 && superficie <= 200;
            break;
          case 'Da 201 a 300 m²':
            matchesSuperficie = superficie > 200 && superficie <= 300;
            break;
          case 'Da 301 a 400 m²':
            matchesSuperficie = superficie > 300 && superficie <= 400;
            break;
          case 'Da 401 a 500 m²':
            matchesSuperficie = superficie > 400 && superficie <= 500;
            break;
          case 'Da 501 a 1000 m²':
            matchesSuperficie = superficie > 500 && superficie <= 1000;
            break;
          default:
            matchesSuperficie = true;
        }
      }

      // Filtro Stanze
      if (_selectedStanze != 'Tutti') {
        int stanze = result['stanza'] ?? 0;
        switch (_selectedStanze) {
          case '0-5':
            matchesStanze = stanze >= 0 && stanze <= 5;
            break;
          case '6-10':
            matchesStanze = stanze > 5 && stanze <= 10;
            break;
          case '11-15':
            matchesStanze = stanze > 10 && stanze <= 15;
            break;
          case '16-20':
            matchesStanze = stanze > 15 && stanze <= 20;
            break;
          case '21-25':
            matchesStanze = stanze > 20 && stanze <= 25;
            break;
          case '26-30':
            matchesStanze = stanze > 25 && stanze <= 30;
            break;
          case '30+':
            matchesStanze = stanze > 30;
            break;
          default:
            matchesStanze = true;
        }
      }

      // Filtro Bagno
      if (_selectedBagno != 'Tutti') {
        int bagni = result['bagno'] ?? 0;
        switch (_selectedBagno) {
          case '1':
            matchesBagno = bagni == 1;
            break;
          case '2':
            matchesBagno = bagni == 2;
            break;
          case '3':
            matchesBagno = bagni == 3;
            break;
          case '4+':
            matchesBagno = bagni > 3;
            break;
          default:
            matchesBagno = true;
        }
      }

      // Filtro Piano
      if (_selectedPiano != 'Tutti') {
        int piano = result['piano'] ?? 0;
        switch (_selectedPiano) {
          case '1':
            matchesPiano = piano == 1;
            break;
          case '2':
            matchesPiano = piano == 2;
            break;
          case '3':
            matchesPiano = piano == 3;
            break;
          case '4+':
            matchesPiano = piano > 3;
            break;
          default:
            matchesPiano = true;
        }
      }

      if(_selectedClasseEnergetica != 'Tutti') {
        matchesClasseEnergetica = result['classe_energetica'] == _selectedClasseEnergetica;
      }

      if (_selectedParcheggio != 'Tutti') {
        matchesParcheggio = result['parcheggio'] == _selectedParcheggio;
      }

      //Servizio Ulteriore
     if (_selectedClimatizzatore) {
       matchesClimatizzatore = result['climatizzatore'] == _selectedClimatizzatore;
     }

     if(_selectedBalcone) {
       matchesBalcone = result['balcone'] == _selectedBalcone;
     }

     if(_selectPortineria) {
       matchesPortineria = result['portineria'] == _selectPortineria;
     }

     if(_selectGiardino) {
       matchesGiardino = result['giardino'] == _selectGiardino;
     }

     if(_selectAscensore) {
       matchesAscensore = result['ascensore'] == _selectAscensore;
     }

     if(_selectArredato) {
       matchesArredato = result['arredato'] == _selectArredato;
     }

      return
          matchesTipologiaContratto &&
          matchesSuperficie &&
          matchesStanze &&
          matchesBagno &&
          matchesPiano &&
          matchesClasseEnergetica &&
          matchesParcheggio &&
          matchesClimatizzatore &&
          matchesBalcone &&
          matchesPortineria &&
          matchesGiardino &&
          matchesAscensore &&
          matchesArredato;
    }).toList();

    if (filteredResults.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Nessun risultato trovato'),
          content: const Text('Nessun immobile trovato con i filtri selezionati. I filtri sono stati resettati.'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text(
                'OK',
                style: TextStyle(color: CupertinoColors.activeBlue),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );

      setState(() {
        _selectedTipologiaContratto  = 'Tutti';
        _selectedSuperficie = 'Tutti';
        _selectedStanze = 'Tutti';
        _selectedBagno = "Tutti";
        _selectedPiano = "Tutti";
        _selectedClasseEnergetica = 'Tutti';
        _selectedParcheggio = 'Tutti';
        _selectedClimatizzatore = false;
        _selectedBalcone = false;
        _selectPortineria = false;
        _selectGiardino = false;
        _selectAscensore = false;
        _selectArredato = false;
        _results = List.from(_originalResults);
      });
    } else {
      setState(() {
        _results = filteredResults;
      });
    }
  }

  // Gestisce il logo e il titolo
  Widget _buildLogoAndTitle(double width, int? idRuolo) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _navigateToHomePage(idRuolo),
          child: Image.asset(
            'assets/images/home/logo.png',
            height: width * 0.35,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Ricerca',
          style: TextStyle(
            color: Colors.white,
            fontSize: width * 0.045,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // Gestisce la barra di ricerca
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.blue),
          const SizedBox(width: 5),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              decoration: const InputDecoration(
                hintText: 'Città, provincia o Cap',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 16),
              onSubmitted: (query) => _searchImmobili(query),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _searchImmobili(_searchController.text),
          ),
        ],
      ),
    );
  }

  // Gestisce la visualizzazione del messaggio di errore
  Widget _buildNoResultsMessage() {
    return Center(
      child: Text(
        _searchController.text.isEmpty
            ? 'Inserisci una città, provincia o CAP'
            : 'Nessun risultato trovato per "${_searchController.text}"',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w100),
      ),
    );
  }

  // Gestisce l'header
  Widget _buildHeader(double width, double height, int? idRuolo) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.02),
      decoration: const BoxDecoration(
        color: Color(0xFF0079BB),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: height * 0.06),
          _buildLogoAndTitle(width, idRuolo),
          SizedBox(height: height * 0.02),
          _buildSearchBar(),
        ],
      ),
    );
  }

  // Gestisce il filtro avanzato Contratto
  Widget _buildContractFilter() {
    final bool isContractFilterUsed = _selectedTipologiaContratto != 'Tutti';

    return _results.isNotEmpty
        ? Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isContractFilterUsed ? Colors.orange : Colors.blue,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.house,
            color: isContractFilterUsed ? Colors.orange : Colors.blue,
            size: 20,
          ),
          const SizedBox(width: 8),
          const Text(
            "Tipologia Contratto:",
            style: TextStyle(color: Colors.black, fontSize: 14),
          ),
          const SizedBox(width: 5),
          PopupMenuButton<String>(
            color: Colors.white,
            onSelected: (value) {
              setState(() {
                _selectedTipologiaContratto = value;
                _applyFilters();
              });
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'Tutti', child: Text('Tutti')),
              PopupMenuItem(value: 'Vendita', child: Text('Vendita')),
              PopupMenuItem(value: 'Affitto', child: Text('Affitto')),
            ],
            child: Row(
              children: [
                Text(
                  _selectedTipologiaContratto,
                  style: const TextStyle(color: Colors.black, fontSize: 13),
                ),
                const Icon(Icons.arrow_drop_down, size: 18, color: Colors.black),
              ],
            ),
          ),
        ],
      ),
    )
        : const SizedBox.shrink();
  }

  // Gestisce il filtro avanzato Superficie
  Widget _buildSuperficieFilter() {
    final bool isSuperficieFilterUsed = _selectedSuperficie != 'Tutti';

    return _results.isNotEmpty
        ? Align(
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSuperficieFilterUsed ? Colors.orange : Colors.blue,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.square_foot,
              color: isSuperficieFilterUsed ? Colors.orange : Colors.blue,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              "Superficie:",
              style: TextStyle(color: Colors.black, fontSize: 14),
            ),
            const SizedBox(width: 5),
            PopupMenuButton<String>(
              color: Colors.white,
              onSelected: (value) {
                setState(() {
                  _selectedSuperficie = value;
                  _applyFilters();
                });
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'Tutti', child: Text('Tutti')),
                PopupMenuItem(value: 'Da 0 a 50 m²', child: Text('Da 0 a 50 m²')),
                PopupMenuItem(value: 'Da 51 a 100 m²', child: Text('Da 51 a 100 m²')),
                PopupMenuItem(value: 'Da 101 a 200 m²', child: Text('Da 101 a 200 m²')),
                PopupMenuItem(value: 'Da 201 a 300 m²', child: Text('Da 201 a 300 m²')),
                PopupMenuItem(value: 'Da 301 a 400 m²', child: Text('Da 301 a 400 m²')),
                PopupMenuItem(value: 'Da 401 a 500 m²', child: Text('Da 401 a 500 m²')),
                PopupMenuItem(value: 'Da 501 a 1000 m²', child: Text('Da 501 a 1000 m²')),
              ],
              child: Row(
                children: [
                  Text(
                    _selectedSuperficie,
                    style: const TextStyle(color: Colors.black, fontSize: 13),
                  ),
                  const Icon(Icons.arrow_drop_down, size: 18, color: Colors.black),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        : const SizedBox.shrink();
  }

  // Gestisce il filtro avanzato Stanze
  Widget _buildStanzeFilter() {
    final bool isStanzeFilterUsed = _selectedStanze != 'Tutti';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isStanzeFilterUsed ? Colors.orange : Colors.blue,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.meeting_room,
            color: isStanzeFilterUsed ? Colors.orange : Colors.blue,
            size: 20,
          ),
          const SizedBox(width: 8),
          const Text(
            "Stanze:",
            style: TextStyle(color: Colors.black, fontSize: 14),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: PopupMenuButton<String>(
              color: Colors.white,
              onSelected: (value) {
                setState(() {
                  _selectedStanze = value;
                  _applyFilters();
                });
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'Tutti', child: Text('Tutti')),
                PopupMenuItem(value: '0-5', child: Text('0-5')),
                PopupMenuItem(value: '6-10', child: Text('6-10')),
                PopupMenuItem(value: '11-15', child: Text('11-15')),
                PopupMenuItem(value: '16-20', child: Text('16-20')),
                PopupMenuItem(value: '21-25', child: Text('21-25')),
                PopupMenuItem(value: '26-30', child: Text('26-30')),
                PopupMenuItem(value: '30+', child: Text('30+')),
              ],
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedStanze,
                    style: const TextStyle(color: Colors.black, fontSize: 13),
                  ),
                  const Icon(Icons.arrow_drop_down, size: 18, color: Colors.black),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Gestisce il filtro avanzato Bagni
  Widget _buildBagniFilter() {
    final bool isBagniFilterUsed = _selectedBagno != 'Tutti';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isBagniFilterUsed ? Colors.orange : Colors.blue,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bathtub, color: isBagniFilterUsed ? Colors.orange : Colors.blue, size: 20),
          const SizedBox(width: 8),
          const Text("Bagni:", style: TextStyle(color: Colors.black, fontSize: 14)),
          PopupMenuButton<String>(
            color: Colors.white,
            onSelected: (value) {
              setState(() {
                _selectedBagno = value;
                _applyFilters();
              });
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'Tutti', child: Text('Tutti')),
              PopupMenuItem(value: '1', child: Text('1')),
              PopupMenuItem(value: '2', child: Text('2')),
              PopupMenuItem(value: '3', child: Text('3')),
              PopupMenuItem(value: '4+', child: Text('4 o più')),
            ],
            child: Row(
              children: [
                Text(_selectedBagno, style: const TextStyle(color: Colors.black, fontSize: 13)),
                const Icon(Icons.arrow_drop_down, size: 18, color: Colors.black),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Gestisce il filtro avanzato Piano
  Widget _buildPianoFilter() {
    final bool isPianoFilterUsed = _selectedPiano != 'Tutti';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isPianoFilterUsed ? Colors.orange : Colors.blue,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.stairs, color: isPianoFilterUsed ? Colors.orange : Colors.blue, size: 20),
          const SizedBox(width: 8),
          const Text("Piano:", style: TextStyle(color: Colors.black, fontSize: 14)),
          PopupMenuButton<String>(
            color: Colors.white,
            onSelected: (value) {
              setState(() {
                _selectedPiano = value;
                _applyFilters();
              });
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'Tutti', child: Text('Tutti')),
              PopupMenuItem(value: '1', child: Text('1')),
              PopupMenuItem(value: '2', child: Text('2')),
              PopupMenuItem(value: '3', child: Text('3')),
              PopupMenuItem(value: '4+', child: Text('4 o più')),
            ],
            child: Row(
              children: [
                Text(_selectedPiano, style: const TextStyle(color: Colors.black, fontSize: 13)),
                const Icon(Icons.arrow_drop_down, size: 18, color: Colors.black),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Gestisce il filtro avanzato Classe Energetica
  Widget _buildClasseEnergeticaFilter() {
    final bool isClasseUsed = _selectedClasseEnergetica != 'Tutti';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isClasseUsed ? Colors.orange : Colors.blue,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.eco, color: isClasseUsed ? Colors.orange : Colors.blue, size: 20),
          const SizedBox(width: 8),
          const Text("Classe:", style: TextStyle(color: Colors.black, fontSize: 14)),
          PopupMenuButton<String>(
            color: Colors.white,
            onSelected: (value) {
              setState(() {
                _selectedClasseEnergetica = value;
                _applyFilters();
              });
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'Tutti', child: Text('Tutti')),
              PopupMenuItem(value: 'A', child: Text('A')),
              PopupMenuItem(value: 'B', child: Text('B')),
              PopupMenuItem(value: 'C', child: Text('C')),
              PopupMenuItem(value: 'D', child: Text('D')),
              PopupMenuItem(value: 'E', child: Text('E')),
              PopupMenuItem(value: 'F', child: Text('F')),
              PopupMenuItem(value: 'G', child: Text('G')),
            ],
            child: Row(
              children: [
                Text(_selectedClasseEnergetica, style: const TextStyle(color: Colors.black, fontSize: 13)),
                const Icon(Icons.arrow_drop_down, size: 18, color: Colors.black),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Gestisce il filtro avanzato Parcheggio
  Widget _buildParkingFilter() {
    final bool isParkingFilterUsed = _selectedParcheggio != 'Tutti';

    return _results.isNotEmpty
        ? Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isParkingFilterUsed ? Colors.orange : Colors.blue,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_parking_sharp,
            color: isParkingFilterUsed ? Colors.orange : Colors.blue,
            size: 20,
          ),
          const SizedBox(width: 8),
          const Text(
            "Garage e posto auto:",
            style: TextStyle(color: Colors.black, fontSize: 14),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: PopupMenuButton<String>(
              color: Colors.white,
              onSelected: (value) {
                setState(() {
                  _selectedParcheggio = value;
                  _applyFilters(); // oppure crea un metodo tipo _applyParkingFilter()
                });
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'Tutti', child: Text('Tutti')),
                PopupMenuItem(value: 'Box privato', child: Text('Box privato')),
                PopupMenuItem(value: 'Posto auto riservato', child: Text('Posto auto riservato')),
                PopupMenuItem(value: 'Posto auto libero', child: Text('Posto auto libero')),
                PopupMenuItem(value: 'Posto bici', child: Text('Posto bici')),
              ],
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedParcheggio,
                    style: const TextStyle(color: Colors.black, fontSize: 13),
                  ),
                  const Icon(Icons.arrow_drop_down, size: 18, color: Colors.black),
                ],
              ),
            ),
          ),
        ],
      ),
    )
        : const SizedBox.shrink();
  }

  // Gestisce il filtro avanzato Servizi
  Widget _buildServiziFilter() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.miscellaneous_services,
                size: 18,
                color: (
                    _selectedClimatizzatore ||
                    _selectedBalcone ||
                    _selectPortineria ||
                    _selectGiardino ||
                    _selectAscensore ||
                    _selectArredato) ? Colors.orange : Colors.black,
              ),
              const SizedBox(width: 4),
              const Text(
                "Servizi ulteriori:",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Prima riga: Climatizzatore + Balcone
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: const Text('Climatizzatore', style: TextStyle(fontSize: 13)),
                  value: _selectedClimatizzatore,
                  onChanged: (bool? value) {
                    setState(() {
                      _selectedClimatizzatore = value ?? false;
                      _applyFilters();
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  activeColor: Colors.blue,
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  title: const Text('Balcone', style: TextStyle(fontSize: 13)),
                  value: _selectedBalcone,
                  onChanged: (bool? value) {
                    setState(() {
                      _selectedBalcone = value ?? false;
                      _applyFilters();
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  activeColor: Colors.blue,
                ),
              ),
            ],
          ),

          // Seconda riga: Portineria + Giardino
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: const Text('Portineria', style: TextStyle(fontSize: 13)),
                  value: _selectPortineria,
                  onChanged: (bool? value) {
                    setState(() {
                      _selectPortineria = value ?? false;
                      _applyFilters();
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  activeColor: Colors.blue,
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  title: const Text('Giardino', style: TextStyle(fontSize: 13)),
                  value: _selectGiardino,
                  onChanged: (bool? value) {
                    setState(() {
                      _selectGiardino = value ?? false;
                      _applyFilters();
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  activeColor: Colors.blue,
                ),
              ),
            ],
          ),

          // Terza riga: Ascensore + Arredato
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: const Text('Ascensore', style: TextStyle(fontSize: 13)),
                  value: _selectAscensore,
                  onChanged: (bool? value) {
                    setState(() {
                      _selectAscensore = value ?? false;
                      _applyFilters();
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  activeColor: Colors.blue,
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  title: const Text('Arredato', style: TextStyle(fontSize: 13)),
                  value: _selectArredato,
                  onChanged: (bool? value) {
                    setState(() {
                      _selectArredato = value ?? false;
                      _applyFilters();
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  activeColor: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Gestisce la barra dei filtri avanzati
  Widget _buildFilterBar() {
    final bool isAnyFilterUsed =
        _selectedTipologiaContratto != 'Tutti' ||
            _selectedSuperficie != 'Tutti' ||
            _selectedStanze != 'Tutti' ||
            _selectedBagno != 'Tutti' ||
            _selectedPiano != 'Tutti' ||
            _selectedClasseEnergetica != 'Tutti' ||
            _selectedParcheggio != 'Tutti' ||
            _selectedClimatizzatore ||
            _selectedBalcone ||
            _selectPortineria ||
            _selectGiardino ||
            _selectAscensore ||
            _selectArredato;

    return _results.isNotEmpty
        ? Container(
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
              title: const Text(
                "Filtri Avanzati",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                Center(child: _buildContractFilter()),
                const SizedBox(height: 10),
                Center(child: _buildSuperficieFilter()),
                const SizedBox(height: 10),
                Center(child: _buildStanzeFilter()),
                const SizedBox(height: 10),
                Center(child: _buildBagniFilter()),
                const SizedBox(height: 10),
                Center(child: _buildPianoFilter()),
                const SizedBox(height: 10),
                Center(child: _buildClasseEnergeticaFilter()),
                const SizedBox(height: 10),
                Center(child: _buildParkingFilter()),
                const SizedBox(height: 10),
                Center(child: _buildServiziFilter()),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    )
        : const SizedBox.shrink();
  }

  // Gestisce l'ordine del prezzo
  Widget _buildOrderPriceFilter() {
    final bool isFilterUsed = _sortOrder != 'none';

    return _results.isNotEmpty
        ? Align(
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isFilterUsed ? Colors.orange : Colors.blue,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.price_change_outlined,
              color: isFilterUsed ? Colors.orange : Colors.blue,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              "Ordina:",
              style: TextStyle(color: Colors.black, fontSize: 14),
            ),
            const SizedBox(width: 5),
            PopupMenuButton<String>(
              color: Colors.white,
              onSelected: (value) {
                setState(() {
                  _sortOrder = value;
                  _sortResults();
                });
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'none', child: Text('Nessuno')),
                PopupMenuItem(value: 'asc', child: Text('Crescente')),
                PopupMenuItem(value: 'desc', child: Text('Decrescente')),
              ],
              child: Row(
                children: [
                  Text(
                    _sortOrder == 'none'
                        ? 'Nessuno'
                        : _sortOrder == 'asc'
                        ? 'Crescente'
                        : 'Decrescente',
                    style: const TextStyle(color: Colors.black, fontSize: 13),
                  ),
                  const Icon(Icons.arrow_drop_down, size: 18, color: Colors.black),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        : const SizedBox.shrink();
  }

  // Gestisce la lista dei risultati
  Widget _buildResultsList(int? idRuolo) {
    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        var result = _results[index];
        String address =
            '${result['via']}, ${result['città']}, ${result['provincia']}, ${result['cap']}';
        // Gestione del percorso file immagine
        Widget imageWidget;
        if (result['percorso_file'] != null && result['percorso_file'].isNotEmpty) {
          imageWidget = Image.network(
            result['percorso_file'],
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width * 0.9,
            height: 165,
            errorBuilder: (context, error, stackTrace) => const Text('Immagine non disponibile'),
          );
        } else {
          imageWidget = const Text('Nessuna foto disponibile');
        }

        return Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 7),
          elevation: 5,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result['titolo'] ?? 'Titolo non disponibile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  address,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      result['tipologia_immobile'] ?? 'Non specificata',
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(width: 5),
                    const Text('in', style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 5),
                    Text(
                      result['tipo_contratto'] ?? '',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                imageWidget,
                const SizedBox(height: 5),
                Text(
                  '€ ${NumberFormat('#,##0', 'it_IT').format(result['prezzo'] ?? 0)}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            subtitle: _buildResultSubtitle(result, address, idRuolo),
          ),
        );
      },
    );
  }

  // Gestisce il sottotitolo del risultato
  Widget _buildResultSubtitle(dynamic result, String address, int? idRuolo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.square_foot, color: Colors.blue),
            const SizedBox(width: 5),
            Text('${result['superficie'] ?? 'N/A'} m²'),
            const SizedBox(width: 20),
            Icon(Icons.king_bed, color: Colors.blue),
            const SizedBox(width: 5),
            Text('${result ['stanza'] ?? 'N/A'}'),
            const SizedBox(width: 20),
            Icon(Icons.bathtub, color: Colors.blue),
            const SizedBox(width: 5),
            Text(result['bagno']?.toString() ?? 'N/A'),
            const SizedBox(width: 20),
            Icon(Icons.local_parking, color: Colors.blue),
            const SizedBox(width: 5),
            Text(result['parcheggio'] ?? 'N/A'),

          ],
        ),
        const SizedBox(height: 10),
        _buildResultActions(result, address, idRuolo),
      ],
    );
  }

  // Gestisce le azioni del risultato
  Widget _buildResultActions(dynamic result, String address, int? idRuolo) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionButton(
          icon: Icons.map,
          label: 'Mappa',
          onPressed: () => _openMap(address),
          color: Colors.green,
        ),
        const SizedBox(width: 10),
        _buildActionButton(
          icon: Icons.info,
          label: 'Info',
          onPressed: () => _navigateToImmobilePage(result),
          color: Colors.blue,
        ),
        if (idRuolo == 4) ...[
          const SizedBox(width: 10),
          _buildActionButton(
            icon: Icons.local_offer,
            label: 'Offerta',
            onPressed: () => _handleOfferButton(result, idRuolo),
            color: Colors.orange,
          ),
          const SizedBox(width: 10),
          _buildActionButton(
            icon: Icons.date_range,
            label: 'Visita',
            onPressed: () => _handleVisitButton(result, idRuolo),
            color: Colors.pinkAccent,
          ),
        ],
      ],
    );
  }

  // Gestisce i bottoni di azione
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  // Gestisce il dispose
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final idRuolo = Provider.of<AuthProvider>(context).currentUser?.idRuolo;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(width, height, idRuolo),
          SizedBox(height: height * 0.01),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: _buildFilterBar(),
          ),
          SizedBox(height: height * 0.01),
          _buildOrderPriceFilter(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                ? _buildNoResultsMessage()
                : _buildResultsList(idRuolo),
          ),
        ],
      ),
    );
  }

  // Gestisce il dispose dell immobileDetailPage
  Future<void> _navigateToImmobilePage(dynamic immobile) async {
    _recentSearchesService.saveSearch(immobile);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImmobileDetailPage(immobile: immobile),
      ),
    );
  }

  // Gestisce l'azione di Offerta
  void _handleOfferButton(dynamic result, int? idRuolo) {
    if (idRuolo == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserSendOfferPage(immobile: result),
        ),
      );
    }
  }

  // Gestisce l'azione di Visita
  void _handleVisitButton(dynamic result, int? idRuolo) {
    if (idRuolo == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserSendVisitsPage(immobile: result, usernameAgente: ''),
        ),
      );
    }
  }

  // Gestisce l'errore
  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Errore'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: const Text(
                'OK',
                style: TextStyle(color: CupertinoColors.activeBlue),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

}