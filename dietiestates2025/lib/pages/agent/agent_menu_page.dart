import 'package:dietiestates2025/pages/agent/agent_home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../edit_password_page.dart';

import '../home_page.dart';

import '../../provider/auth_provider.dart';

import '../../widgets/agent_bottom_bar_widget.dart';

import '../../services/navigation_service.dart';

class AgentMenuPage extends StatefulWidget {
  final String query;

  const AgentMenuPage({super.key, required this.query});

  @override
  _AgentMenuPageState createState() => _AgentMenuPageState();
}

class _AgentMenuPageState extends State<AgentMenuPage> {
  int _selectedIndex = 4;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
    NavigationService.navigateToAgentBottomBarPage(index);
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
      bottomNavigationBar: AgentBottomBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

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
      centerTitle: true,
      backgroundColor: const Color(0xFF0079BB),
      leading: GestureDetector(
        onTap: () {
          // Navigate to AgentHomePage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AgentHomePage()),
          );
        },
        child: Icon(
          Icons.home_filled,
          color: Colors.white,
          size: width * 0.06,
        ),
      ),
    );
  }

  Widget _buildBody(double width, double height, dynamic user) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.06, vertical: height * 0.03),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildImageAndText(width),
            const SizedBox(height: 20),
            if (user != null) _buildUserInfoCard(user),
            _buildModifyCredentialsCard(),
            const SizedBox(height: 20),
            _buildLogoutCard(),
          ],
        ),
      ),
    );
  }

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
          'Le mie informazioni',
          style: TextStyle(
            color: Colors.black,
            fontSize: width * 0.045,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  //Metodo per costruire la card con le info dell'utente
  Widget _buildUserInfoCard(dynamic user) {
    return UserInfoCard(user: user);
  }

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



