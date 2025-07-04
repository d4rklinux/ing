import 'package:dietiestates2025/pages/home_page.dart';
import 'package:dietiestates2025/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../data/models/utente.dart';
import '../../data/repositories/utente_repositories.dart';
import '../../services/http_service.dart';

class UserRegistrationPage extends StatefulWidget {
  const UserRegistrationPage({super.key});

  @override
  _UserRegistrationPageState createState() => _UserRegistrationPageState();
}

class _UserRegistrationPageState extends State<UserRegistrationPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cognomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final UtenteRepositories _utenteRepository =
      UtenteRepositories(HttpService());
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  // Funzioni di validazione
  bool _validateEmail(String email) {
    return RegExp(r"^[\w.-]+@([\w-]+\.)+[a-zA-Z]{2,}$").hasMatch(email);
  }

  bool _validatePassword(String password) {
    return RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{6,}$')
        .hasMatch(password);
  }

  bool containsSpaces(String text) {
    return text.contains(' ');
  }

  bool containsSpacesExceptName(String text) {
    return text.trim().contains(RegExp(r'\s{2,}'));
  }

  // Funzione per registrare l'utente
  Future<void> _registerUser() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final nome = _nomeController.text.trim();
    final cognome = _cognomeController.text.trim();
    final email = _emailController.text.trim();

    if (username.isEmpty ||
        password.isEmpty ||
        nome.isEmpty ||
        cognome.isEmpty ||
        email.isEmpty) {
      _showErrorDialog("Tutti i campi sono obbligatori.");
      return;
    }

    if (containsSpaces(username) ||
        containsSpaces(password) ||
        containsSpaces(email)) {
      _showErrorDialog(
          'Username, password ed email non possono contenere spazi.');
      return;
    }

    if (!_validatePassword(password)) {
      _showErrorDialog(
          "La password deve contenere almeno una lettera maiuscola, un numero e un carattere speciale.");
      return;
    }

    if (containsSpacesExceptName(nome) || containsSpacesExceptName(cognome)) {
      _showErrorDialog(
          'Il nome e il cognome non possono contenere spazi multipli consecutivi.');
      return;
    }

    if (!_validateEmail(email)) {
      _showErrorDialog(
          "L'email deve essere valida e contenere un dominio corretto.");
      return;
    }

    setState(() => _isLoading = true);

    final utenti = await _utenteRepository.getAllUtenti();
    final emailEsiste = utenti
        .any((utente) => utente.email.toLowerCase() == email.toLowerCase());

    if (emailEsiste) {
      _showErrorDialog('Questa email risulta già registrata.');
      setState(() => _isLoading = false);
      return;
    }

    String nomeCapitalized =
        nome.isNotEmpty ? nome[0].toUpperCase() + nome.substring(1) : nome;
    String cognomeCapitalized = cognome.isNotEmpty
        ? cognome[0].toUpperCase() + cognome.substring(1)
        : cognome;

    Utente newUser = Utente(
      username: username,
      password: password,
      nome: nomeCapitalized,
      cognome: cognomeCapitalized,
      email: email,
      idRuolo: 4,
    );

    try {
      await _utenteRepository.createUtente(newUser);
      _showSuccessDialog('Iscrizione avvenuta con successo!');
      _clearFields();
    } catch (e) {
      _showErrorDialog(
          'Errore durante la registrazione: L\'utente è già registrato');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Funzione per svuotare i campi
  void _clearFields() {
    _usernameController.clear();
    _passwordController.clear();
    _nomeController.clear();
    _cognomeController.clear();
    _emailController.clear();
  }

  // Funzione per mostrare il dialogo di errore
  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text(
            'Attenzione',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Text(message, style: const TextStyle(fontSize: 16)),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(),
              child:
                  const Text('OK', style: TextStyle(color: Color(0xFF0079BB))),
            ),
          ],
        );
      },
    );
  }

  // Funzione per mostrare il dialogo di successo
  void _showSuccessDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text(
            'Registrazione completata',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Text(message, style: const TextStyle(fontSize: 16)),
          ),
          actions: [
          CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.of(context).pop(); // Chiude il dialogo
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
          child: const Text('OK', style: TextStyle(color: Color(0xFF0079BB))),
          )],
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
      appBar: _buildAppBar(width),
      body: _buildBody(width, height),
      backgroundColor: Colors.white,
    );
  }

  // Funzione per costruire la barra dell'app
  AppBar _buildAppBar(double width) {
    return AppBar(
      backgroundColor: const Color(0xFF0079BB),
      title: Text(
        'Registrazione',
        style: TextStyle(
          color: Colors.white,
          fontSize: width * 0.045,
          fontWeight: FontWeight.w400,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          }
        },
      ),
    );
  }

  // Funzione per costruire il corpo della pagina
  Widget _buildBody(double width, double height) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: width * 0.05, vertical: height * 0.02),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogoAndInfo(width),
              const SizedBox(height: 16),
              _buildTextField(_usernameController, 'Username'),
              const SizedBox(height: 16),
              _buildPasswordField(),
              const SizedBox(height: 16),
              _buildTextField(_nomeController, 'Nome'),
              const SizedBox(height: 16),
              _buildTextField(_cognomeController, 'Cognome'),
              const SizedBox(height: 16),
              _buildTextField(_emailController, 'Email'),
              const SizedBox(height: 24),
              _buildRegisterButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Funzione per costruire il logo e le informazioni
  Widget _buildLogoAndInfo(double width) {
    return Column(
      children: [
        Image.asset(
          'assets/images/home/DietiEstates2025NoBg.png',
          height: width * 0.60,
        ),
        const SizedBox(height: 8),
        const Text(
          'Inserisci tutti i dati richiesti per registrarti',
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w100,
          ),
        ),
      ],
    );
  }

  // Funzione per costruire il campo password
  Widget _buildPasswordField() {
    return _buildTextField(
      _passwordController,
      'Password',
      isPassword: true,
      helperText:
          'Min 6 caratteri, 1 maiuscola, 1 numero, 1 carattere speciale',
    );
  }

  // Funzione per costruire il TextField
  Widget _buildTextField(TextEditingController controller, String label,
      {bool isPassword = false, String? helperText}) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      // Imposta se la password deve essere visibile o meno
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        labelStyle: const TextStyle(color: Colors.black),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF0079BB)),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: _isPasswordVisible
                      ? const Color(0xFFFF6600)
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

// Funzione per costruire il pulsante di registrazione
  Widget _buildRegisterButton() {
    return _isLoading
        ? const CircularProgressIndicator()
        : ElevatedButton(
            onPressed: _registerUser,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0079BB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Registrati'),
          );
  }
}
