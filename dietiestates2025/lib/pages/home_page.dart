import 'package:flutter/material.dart';

import '../services/navigation_service.dart';

import 'login_page.dart';

import 'search_page.dart';
import 'user/user_registration_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {

  //Costruisce l'header della pagina
  Widget _buildHeader(double width, double height) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: height * 0.05),
          _buildLogo(width),
          _buildLoginButton(),
          SizedBox(height: height * 0.02),
          _buildSearchBar(),
        ],
      ),
    );
  }

  // Costruisce il logo e il titolo
  Widget _buildLogo(width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/home/DietiEstates2025NoBg.png',
          height: width * 0.50,
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  //Costruisce il pulsante di login
  Widget _buildLoginButton() {
    return Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              NavigationService.navigateTo(const LoginPage());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // Bordo arrotondato
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            ),
            icon: const Icon(
              Icons.login,
              color: Colors.blue,
              size: 20,
            ),
            label: const Text(
              'Accedi',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Registrati o accedi al tuo account',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

// Costruisce la barra di ricerca con navigazione diretta a SearchPage
  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        NavigationService.navigateTo(const SearchPage());
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,  // Centra l'icona e il testo
          children: [
            Icon(Icons.search, color: Colors.blue),
            SizedBox(width: 5),
            Text(
              'Inizia nuova ricerca',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w200,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Funzione per costruire il pulsante di prenotazione di visita
  Widget _buildRegistratiButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Color(0xFF0079BB), Color(0xFF00AEEF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.app_registration_sharp,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              const Text(
                'Non perdere l’occasione\nPrenota una visita o fai la tua proposta!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  NavigationService.navigateTo(const UserRegistrationPage());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 15,
                ),
                child: const Text(
                  'ISCRIVITI ORA',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox(double width, double height) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.05,
        vertical: height * 0.01,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.3,
              letterSpacing: 0.5,
            ),
            children: [
              TextSpan(
                text: 'DietiEstates 2025\n',
                style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue),
              ),
              TextSpan(
                text: 'La tua casa, il tuo futuro',
                style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.orange),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Costruisce la pagina principale
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(width, height),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: _buildRegistratiButton(context),
          ),
          Expanded(
            child: _buildInfoBox(width, height)
              ),
        ],
      ),
    );
  }

}