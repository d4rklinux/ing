import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/splash_screen.dart';

import '../provider/auth_provider.dart';

import '../services/aut_service.dart';
import '../services/http_service.dart';
import '../services/navigation_service.dart';

import 'data/repositories/utente_repositories.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider(AuthService(), UtenteRepositories(HttpService()));

  await authProvider.initialize(); // Carica lo stato iniziale

  runApp(
    ChangeNotifierProvider(
      create: (_) => authProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigatorKey,
      home: const SplashScreen(),
      // Imposta la localizzazione e i delegati necessari
      locale: Locale('it', 'IT'),
      supportedLocales: [
        Locale('en', 'US'),
        Locale('it', 'IT'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
