import 'package:dietiestates2025/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'administrator_registration_page.dart';

import '../edit_password_page.dart';

import '../../provider/auth_provider.dart';

class AdministratorInfoPage extends StatefulWidget {
  const AdministratorInfoPage({super.key});

  @override
  _AdministratorInfoPageState createState() => _AdministratorInfoPageState();
}

class _AdministratorInfoPageState extends State<AdministratorInfoPage> {
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
    );
  }

  // Funzione per costruire la barra dell'app
  PreferredSizeWidget _buildAppBar(double width) {
    return AppBar(
      title: Text(
        'Amministratore',
        style: TextStyle(
          color: Colors.white,
          fontSize: width * 0.045,
          fontWeight: FontWeight.w400,
        ),
      ),
      backgroundColor: const Color(0xFF0079BB),
    );
  }

  // Funzione per costruire il corpo della pagina
  Widget _buildBody(double width, double height, user) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.06, vertical: height * 0.03),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildImageAndText(width),
            const SizedBox(height: 20),
            if (user != null) _buildWelcomeMessage(user),
            const SizedBox(height: 20),
            _buildModifyCredentialsCard(),
            const SizedBox(height: 20),
            _buildCreateSupportAccountCard(),
            const SizedBox(height: 20),
            _buildLogoutCard(),
          ],
        ),
      ),
    );
  }

  // Funzione per costruire l'immagine e il testo
  Widget _buildImageAndText(double width) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          child: Image.asset(
            'assets/images/home/DietiEstates2025NoBg.png',
            height: width * 0.60,
            width: width * 0.60,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Amministratore - Gestione Account',
          style: TextStyle(
            color: Colors.black,
            fontSize: width * 0.045,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Funzione per costruire il messaggio di benvenuto
  Widget _buildWelcomeMessage(user) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        '${_getBenvenuto(user.nome)} ${user.nome}',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }

  // Funzione per ottenere il messaggio di benvenuto
  String _getBenvenuto(String nome) {
    if (nome.isEmpty) return 'Benvenuto';

    final ultimaLettera = nome.trim().toLowerCase().characters.last;

    if (ultimaLettera == 'a') {
      return 'Benvenuta';
    } else if (ultimaLettera == 'e' || ultimaLettera == 'o') {
      return 'Benvenuto';
    }

    return 'Benvenuto/a'; // fallback neutro
  }

  // Funzione per costruire le card di azione
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

  // Funzione per costruire la card di logout
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

  // Funzione per costruire la card di creazione di account di supporto
  Widget _buildCreateSupportAccountCard() {
    return _buildActionCard(
      icon: Icons.account_circle,
      title: 'Crea Account di Supporto',
      color: Colors.green,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdministratorRegistrationPage()),
        );
      },
    );
  }

  // Funzione per costruire le card di azione
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
