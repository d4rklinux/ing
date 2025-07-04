import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../provider/auth_provider.dart';

import '../services/navigation_service.dart';

import 'home_page.dart';

import 'administrator/administrator_home_page.dart';

import 'manager/manager_home_page.dart';

import 'agent/agent_home_page.dart';

import 'user/user_home_page.dart';
import 'user/user_registration_page.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;


  // Metodo per effettuare il login
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final String username = _usernameController.text;
    final String password = _passwordController.text;

    try {
      await context.read<AuthProvider>().login(username, password);

      if (!mounted) return;

      final idRuolo = context.read<AuthProvider>().currentUser?.idRuolo;

      if (idRuolo == 1) {
        NavigationService.navigateTo(AdministratorInfoPage());
      } else if (idRuolo == 2) {
        NavigationService.navigateTo(ManagerHomePage());
      } else if (idRuolo == 3) {
        NavigationService.navigateTo(AgentHomePage());
      } else if (idRuolo == 4) {
        NavigationService.navigateTo(UserHomePage());
      } else {
        _showErrorDialog('Ruolo non riconosciuto.');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Inserisci le credenziali corrette.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

// Metodo per mostrare un messaggio di errore
  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text(
            'Errore nel Login:',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Color(0xFF0079BB),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Funzione per costruire la pagina
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: _buildAppBar(context, width),
      body: _buildBody(context, width, height),
      backgroundColor: Colors.white,
    );
  }

  // Funzione per costruire l'AppBar
  AppBar _buildAppBar(BuildContext context, double width) {
    return AppBar(
      title: Text(
        'Login',
        style: TextStyle(
          color: Colors.white,
          fontSize: width * 0.045,
          fontWeight: FontWeight.w400,
        ),
      ),
      backgroundColor: const Color(0xFF0079BB),
      leading: IconButton(
        icon: const Icon(
          Icons.home_filled,
          color: Colors.white,
        ),
        onPressed: () => NavigationService.navigateTo(const HomePage()),
      ),
    );
  }

  // Funzione per costruire il corpo della pagina
  Widget _buildBody(BuildContext context, double width, double height) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: height * 0.02,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildImageAndText(width),
              const SizedBox(height: 16),
              _buildTextField(_usernameController, 'Username'),
              const SizedBox(height: 16),
              _buildTextField(_passwordController, 'Password',
                  isPassword: true),
              const SizedBox(height: 16),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                _buildLoginAndRegisterButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  // Funzione per costruire l'immagine e il testo
  Widget _buildImageAndText(double width) {
    return Column(
      children: [
        Image.asset(
          'assets/images/home/DietiEstates2025NoBg.png',
          // Percorso dell'immagine
          height: width * 0.60,
        ),
        const SizedBox(height: 8),
        const Text(
          'Inserisci le tue credenziali per accedere',
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w100,
          ),
        ),
      ],
    );
  }

  // Funzione per costruire i pulsanti di login e registrazione
  Widget _buildLoginAndRegisterButtons(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: _login,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0079BB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          child: const Text('Login'),
        ),
        const SizedBox(height: 190),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Text(
            'Se non sei registrato, fallo adesso!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const UserRegistrationPage()
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFf66707),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          child: const Text('Registrati'),
        ),
      ],
    );
  }

  // Funzione per costruire il TextField
  Widget _buildTextField(TextEditingController controller, String label,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF0079BB)),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: _isPasswordVisible
                      ? Color(0xFFFF6600)
                      : const Color(0xFF0079BB),
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
      ),
    );
  }
}
