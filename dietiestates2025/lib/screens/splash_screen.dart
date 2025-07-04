import 'package:dietiestates2025/pages/agent/agent_home_page.dart';
import 'package:dietiestates2025/pages/manager/manager_home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/administrator/administrator_home_page.dart';
import '../pages/user/user_home_page.dart';
import '../pages/home_page.dart';

import '../provider/auth_provider.dart';

import '../widgets/fade_transition_widget.dart';

import '../services/navigation_service.dart';


class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return FadeTransitionWidget(
              duration: const Duration(seconds: 1),
              onEnd: () {
                if (authProvider.isLoggedIn) {
                  final idRuolo = authProvider.currentUser?.idRuolo;

                  // Naviga in base al ruolo
                  if (idRuolo == 1) {
                    NavigationService.navigateTo(AdministratorInfoPage());
                  } else if (idRuolo == 2) {
                    NavigationService.navigateTo(ManagerHomePage());
                  } else if (idRuolo == 3) {
                    NavigationService.navigateTo(AgentHomePage());
                  } else if (idRuolo == 4) {
                    NavigationService.navigateTo(UserHomePage());
                  }
                } else {
                  // Se l'utente non è loggato, naviga alla pagina di login
                  NavigationService.navigateTo(HomePage());
                }
              },
              child: Image.asset('assets/images/home/DietiEstates2025NoBg.png'),
            );
          },
        ),
      ),
    );
  }
}
