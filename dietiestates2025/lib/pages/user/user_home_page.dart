import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../immobile_detail_page.dart';

import '../search_page.dart';

import '../../provider/auth_provider.dart';

import '../../services/navigation_service.dart';
import '../../services/recent_search_service.dart';

import '../../widgets/user_bottom_bar_widget.dart';

class UserHomePage extends StatefulWidget {
  final dynamic immobile;

  const UserHomePage({super.key, this.immobile});

  @override
  UserHomePageState createState() => UserHomePageState();
}

class UserHomePageState extends State<UserHomePage> {
  int _selectedIndex = 0;
  final RecentSearchesService _recentSearchesService = RecentSearchesService();
  List<Map<String, dynamic>> _recentSearches = [];
  String? _currentUsername;

  @override
  void initState() {
    super.initState();

    // Uso dell'immobile passato
    if (widget.immobile != null) {
    }
  }

  // Funzione per gestire il cambio di pagina
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context);
    final newUsername = authProvider.currentUser?.username;

    if (newUsername != _currentUsername) {
      _currentUsername = newUsername;
      _loadRecentSearches();
    }
  }

  // Funzione per caricare le ricerche recenti
  Future<void> _loadRecentSearches() async {
    final recent = await _recentSearchesService.getSearches();

    if (widget.immobile != null) {
      final immobileMap = widget.immobile as Map<String, dynamic>;

      // Controlla se esiste già un immobile con stesso ID
      final alreadyExists = recent.any((item) => item['id'] == immobileMap['id']);

      if (!alreadyExists) {
        await _recentSearchesService.saveSearch(immobileMap);
        recent.insert(0, immobileMap);
      }
    }

    setState(() {
      _recentSearches = recent;
    });
  }

  // Funzione per eliminare tutte le ricerche recenti
  Future<void> _deleteAllRecentSearches() async {
    await _recentSearchesService.clearAllSearches();
    setState(() {
      _recentSearches.clear();
    });
  }

  // Funzione per costruire l'header
  Widget _buildHeader(double width, double height) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: height * 0.02,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF0079BB),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: height * 0.05),
              _buildLogo(width),
              if (authProvider.currentUser != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    '${_getBenvenuto(authProvider.currentUser!.nome)}, ${authProvider.currentUser!.nome}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              SizedBox(height: height * 0.03),
              _buildSearchBar(),
            ],
          ),
        );
      },
    );
  }

  // Funzione per ottenere il benvenuto in base alla ultima lettera del nome
  String _getBenvenuto(String nome) {
    if (nome.isEmpty) return 'Benvenuto';
    final ultimaLettera = nome.trim().toLowerCase().characters.last;
    if (ultimaLettera == 'a') return 'Benvenuta';
    if (ultimaLettera == 'e' || ultimaLettera == 'o') return 'Benvenuto';
    return 'Benvenuto/a';
  }

  // Funzione per costruire il logo
  Widget _buildLogo(double width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/home/DietiEstates2025NoBg.png',
          height: width * 0.50,
        ),
      ],
    );
  }

  // Funzione per costruire la barra di ricerca
  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () => NavigationService.navigateTo(const SearchPage()),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: const Row(
          children: [
            Icon(Icons.search, color: Colors.blue),
            SizedBox(width: 5),
            Text(
              'Inizia nuova ricerca',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Funzione per costruire le ricerche recenti
  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ultime Ricerche Recenti',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: _deleteAllRecentSearches,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                ),
                child: const Text('Cancella tutto',
                  style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              final search = _recentSearches[index];
              final title = search['città'] ?? 'Immobile';
              final imageUrl = search['percorso_file'];

              return Container(
                width: 200,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  onTap: () {
                    NavigationService.navigateTo(
                      ImmobileDetailPage(immobile: search),
                    );
                  },
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (imageUrl != null && imageUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                            child: Image.network(
                              imageUrl,
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
                            ),
                          )
                        else
                          const SizedBox(
                            height: 100,
                            child: Icon(Icons.home, size: 80, color: Colors.grey),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Bottone per gestire la prenotazione della visita
  Widget _buildPrenotaVisitaButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          gradient: const LinearGradient(
            colors: [Color(0xFF0079BB), Color(0xFF00AEEF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Icon(Icons.calendar_month, size: 22, color: Colors.white),
                  SizedBox(width: 10),
                ],
              ),
              const Text(
                'Prenota la tua visita in un click!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  NavigationService.navigateTo(const SearchPage());
                },
                icon: const Icon(Icons.maps_home_work, size: 18),
                label: const Text(
                  'Prenota Visita',
                  style: TextStyle(fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Funzione per gestire il cambio di pagina
  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    NavigationService.navigateToBottomBarPage(index);
  }

  // Funzione per costruire l'interfaccia dell'utente
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(width, height),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: _buildPrenotaVisitaButton(context),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: SingleChildScrollView(
              child:_buildRecentSearches(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: UserBottomBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}