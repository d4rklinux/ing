import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'user_home_page.dart';

import '../edit_password_page.dart';

import '../home_page.dart';

import '../../provider/auth_provider.dart';

import '../../widgets/user_bottom_bar_widget.dart';

import '../../services/navigation_service.dart';


class UserMenuPage extends StatefulWidget {
  final String query;

  const UserMenuPage({super.key, required this.query});

  @override
  _UserMenuPageState createState() => _UserMenuPageState();
}

class _UserMenuPageState extends State<UserMenuPage> {
  int _selectedIndex = 4;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
    NavigationService.navigateToBottomBarPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: _buildAppBar(width),
      body: _buildBody(width, height, user),
      backgroundColor: Colors.white,
      bottomNavigationBar: UserBottomBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  // Funzione che costruisce l'AppBar
  PreferredSizeWidget _buildAppBar(double width) {
    return AppBar(
      title: Text(
        'Menu',
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

  // Funzione per costruire il corpo della pagina
  Widget _buildBody(double width, double height, dynamic user) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.06, vertical: height * 0.03),
      child: SingleChildScrollView( // Aggiungi SingleChildScrollView per gestire schermi piccoli
        child: Column(
          children: [
            _buildImageAndText(width),
            const SizedBox(height: 20),
            if (user != null) _buildUserInfoCard(user),
            _buildModifyCredentialsCard(),
            const SizedBox(height: 20), // Spazio aggiuntivo tra i widget
            _buildLogoutCard(),
          ],
        ),
      ),
    );
  }

  // Costruisce l'immagine e il testo
  Widget _buildImageAndText(double width) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          child: Image.asset(
            'assets/images/home/DietiEstates2025NoBg.png',
            height: width * 0.60,
            width: width * 0.60, // Forza la larghezza in base alla dimensione dello schermo
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Le mie informazioni',
          style: TextStyle(
            color: Colors.black,
            fontSize: width * 0.045, // Adatta la dimensione del testo
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Costruisce la carta con le informazioni utente
  Widget _buildUserInfoCard(dynamic user) {
    return UserInfoCard(user: user);
  }

  // Costruisce la carta per la modifica credenziali
  Widget _buildModifyCredentialsCard() {
    return _buildActionCard(
      icon: Icons.lock,
      title: 'Modifica Credenziali',
      color: Colors.blue,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditPasswordPage()),
        );
      },
    );
  }

  // Costruisce la carta di logout
  Widget _buildLogoutCard() {
    return _buildActionCard(
      icon: Icons.logout,
      title: 'Logout',
      color: Colors.orange,
      isLogout: true,
      onTap: () async {
        final navigator = Navigator.of(context);
        final authProvider = context.read<AuthProvider>();
        await authProvider.logout();
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => HomePage()),
              (route) => false,
        );
      },
    );
  }

  // Classe per la carta di azione
  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isLogout ? Colors.orange : color,
          width: 1.5,
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: isLogout ? Colors.orange : color, size: 28),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isLogout ? Colors.orange : color,
        ),
        onTap: onTap,
      ),
    );
  }
}

class UserInfoCard extends StatelessWidget {
  final dynamic user;

  const UserInfoCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.blue, width: 1.5),
      ),
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow(Icons.person, 'Nome', user.nome),
            _buildInfoRow(Icons.group, 'Cognome', user.cognome),
            _buildInfoRow(Icons.account_box, 'Username', user.username),
            _buildInfoRow(Icons.email, 'Email', user.email),
          ],
        ),
      ),
    );
  }

  // Classe per la riga di informazioni
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 10),
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
