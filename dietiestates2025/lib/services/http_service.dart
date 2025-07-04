import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cookie_jar/cookie_jar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HttpService {
  static final HttpService _instance = HttpService._internal();
  final CookieJar _cookieJar = CookieJar();
  late String _authToken;

  factory HttpService() => _instance;

  // Costruttore privato
  HttpService._internal() {
    _loadAuthToken();
  }

  // Metodo per caricare il token JWT
  Future<void> _loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token') ?? '';
  }

  // Metodo per ottenere l'URL base
  String getApiBaseUrl() {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    } else if (Platform.isIOS) {
      return 'http://127.0.0.1:3000';
    } else {
      return 'http://localhost:3000';
    }
  }

  // Metodo per ottenere l'endpoint completo
  String getApiEndpoint(String path) => '${getApiBaseUrl()}/$path';

  // Metodo per inviare richieste HTTP
  Future<http.Response> sendRequest(
      String path,
      String method, {
        Map<String, String>? headers,
        dynamic body,
        bool withAuth = true,
      }) async {
    final url = Uri.parse(getApiEndpoint(path));
    final requestHeaders = Map<String, String>.from(headers ?? {});

    // Aggiungi Content-Type se non presente
    requestHeaders.putIfAbsent(
      'Content-Type',
          () => 'application/json',
    );

    // Gestione cookie e token
    if (withAuth) {
      // 1. Carica cookie esistenti
      final cookies = await _cookieJar.loadForRequest(url);
      if (cookies.isNotEmpty) {
        requestHeaders['Cookie'] = cookies
            .map((cookie) => '${cookie.name}=${cookie.value}')
            .join('; ');
      }

      // 2. Aggiungi token JWT se presente
      if (_authToken.isNotEmpty) {
        requestHeaders['Authorization'] = 'Bearer $_authToken';
      }
    }

    // Converti il body in JSON se è una Map/List
    final encodedBody = body is Map || body is List
        ? json.encode(body)
        : body?.toString();

    http.Response response;
    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: requestHeaders);
          break;
        case 'POST':
          response = await http.post(
            url,
            headers: requestHeaders,
            body: encodedBody,
          );
          break;
        case 'PUT':
          response = await http.put(
            url,
            headers: requestHeaders,
            body: encodedBody,
          );
          break;
        case 'DELETE':
          response = await http.delete(
            url,
            headers: requestHeaders,
          );
          break;
        default:
          throw Exception('Metodo HTTP non supportato: $method');
      }

      // Salva i nuovi cookie dalla risposta
      await _processResponseCookies(url, response);

      return response;
    } on SocketException {
      throw Exception('Errore di connessione al server');
    } on http.ClientException catch (e) {
      throw Exception('Errore nella richiesta HTTP: ${e.message}');
    }
  }

  // Metodo per gestire i cookie della risposta
  Future<void> _processResponseCookies(Uri url, http.Response response) async {
    try {
      if (response.headers.containsKey('set-cookie')) {
        final cookiesHeader = response.headers['set-cookie']!;

        final cookies = _parseCookies(cookiesHeader);

        if (cookies.isNotEmpty) {
          await _cookieJar.saveFromResponse(url, cookies);

          // Trova e salva il token JWT
          final authCookie = cookies.firstWhere(
                (c) => c.name == 'auth_token',
            orElse: () => Cookie('', ''),
          );

          if (authCookie.value.isNotEmpty) {
            _authToken = authCookie.value;
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('auth_token', _authToken);
          }
        }
      }
    } catch (e) {
      throw Exception('Errore nella gestione dei cookie: $e');
    }
  }

  // Metodo per estrarre i cookie da una stringa
  List<Cookie> _parseCookies(String cookieHeader) {
    try {
      // Prima pulisci la stringa da spazi e newline
      final cleanedHeader = cookieHeader.replaceAll('\n', '').trim();

      // Dividi i cookie multipli (separati da virgola)
      final individualCookies = cleanedHeader.split(',');

      return individualCookies.map((cookieStr) {
        // Estrai la parte prima del ";" (ignora attributi come path, domain, etc.)
        final cookiePart = cookieStr.split(';').first.trim();
        final separatorIndex = cookiePart.indexOf('=');

        if (separatorIndex > 0) {
          final name = cookiePart.substring(0, separatorIndex).trim();
          final value = cookiePart.substring(separatorIndex + 1).trim();
          return Cookie(name, value);
        }
        return null;
      }).where((cookie) => cookie != null).cast<Cookie>().toList();
    } catch (e) {
      throw Exception('Errore nel parsing dei cookie: $e');
    }
  }

  // Metodo per ottenere il token JWT
  Future<void> clearAuthData() async {
    _authToken = '';
    await _cookieJar.deleteAll(); // Pulisce i cookie
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token'); // Pulisce il token salvato
  }
}