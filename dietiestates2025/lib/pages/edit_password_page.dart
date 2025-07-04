import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/repositories/utente_repositories.dart';
import '../provider/auth_provider.dart';
import '../services/http_service.dart';

class EditPasswordPage extends StatefulWidget {
  const EditPasswordPage({super.key});

  @override
  _EditPasswordPageState createState() => _EditPasswordPageState();
}

class _EditPasswordPageState extends State<EditPasswordPage> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final UtenteRepositories _utenteRepository = UtenteRepositories(HttpService());

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Modifica Password',
          style: TextStyle(
            color: Colors.white,
            fontSize: width * 0.045,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: const Color(0xFF0079BB),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: _buildBody(context, width, height),
      backgroundColor: Colors.white,
    );
  }

  // Costruisce il corpo della pagina
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
              _buildTextField(_currentPasswordController, 'Password Attuale', isPassword: true, field: 'current'),
              const SizedBox(height: 16),
              _buildTextField(_newPasswordController, 'Nuova Password', isPassword: true, field: 'new'),
              const SizedBox(height: 16),
              _buildTextField(_confirmPasswordController, 'Conferma Nuova Password', isPassword: true, field: 'confirm'),
              const SizedBox(height: 16),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _onSavePasswordChange,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0079BB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Salva'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Mostra l'immagine e il testo di introduzione
  Widget _buildImageAndText(double width) {
    return Column(
      children: [
        Image.asset(
          'assets/images/home/DietiEstates2025NoBg.png',
          height: width * 0.60,
        ),
        const SizedBox(height: 8),
        const Text(
          'Modifica la tua password',
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w100,
          ),
        ),
      ],
    );
  }

  // Costruisce un campo di testo con la logica per la visibilità delle password
  Widget _buildTextField(TextEditingController controller, String label, {bool isPassword = false, required String field}) {
    bool isPasswordVisible;
    IconData visibilityIcon;

    if (field == 'current') {
      isPasswordVisible = _isCurrentPasswordVisible;
      visibilityIcon = _isCurrentPasswordVisible ? Icons.visibility : Icons.visibility_off;
    } else if (field == 'new') {
      isPasswordVisible = _isNewPasswordVisible;
      visibilityIcon = _isNewPasswordVisible ? Icons.visibility : Icons.visibility_off;
    } else {
      isPasswordVisible = _isConfirmPasswordVisible;
      visibilityIcon = _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off;
    }

    return TextField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
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
            visibilityIcon,
            color: isPasswordVisible ? const Color(0xFFFF6600) : const Color(0xFF0079BB),
          ),
          onPressed: () {
            setState(() {
              if (field == 'current') {
                _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
              } else if (field == 'new') {
                _isNewPasswordVisible = !_isNewPasswordVisible;
              } else {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              }
            });
          },
        )
            : null,
      ),
    );
  }

  // Gestisce il cambiamento della password
  void _onSavePasswordChange() async {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~.,;:^§ç°§€]).{6,}$');
    if (!passwordRegex.hasMatch(newPassword)) {
      _showErrorDialog(
          "La password deve contenere almeno una lettera maiuscola, un numero e un carattere speciale."
      );
      return;
    }

    if (newPassword != confirmPassword) {
      _showErrorDialog('Le password non corrispondono!');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final username = authProvider.currentUser?.username;

    if (username == null) {
      _showErrorDialog('Utente non autenticato');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _utenteRepository.changePassword(
        username: username,
        oldPassword: _currentPasswordController.text,
        newPassword: newPassword,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showErrorDialog(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Mostra il dialogo di successo per il cambio password
  void _showSuccessDialog() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Cambio Password Effettuato'),
          content: const Text('Password cambiata con successo!'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Mostra un dialogo di errore
  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text(
            'Attenzione',
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
}
