import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../data/models/proposta.dart';
import '../../data/repositories/proposta_repositories.dart';
import '../../provider/auth_provider.dart';
import '../../services/navigation_service.dart';
import 'user_home_page.dart';

class UserSendOfferPage extends StatefulWidget {
  final dynamic immobile;

  const UserSendOfferPage({super.key, required this.immobile});

  @override
  State<UserSendOfferPage> createState() => _UserSendOfferPageState();
}

class _UserSendOfferPageState extends State<UserSendOfferPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _prezzoController = TextEditingController();
  bool _isSubmitting = false;

  // Metodo per liberare le risorse quando il widget viene distrutto
  @override
  void dispose() {
    _prezzoController.dispose();
    super.dispose();
  }

  // Metodo per inviare l'offerta
  Future<void> _inviaOfferta() async {
    if (!_formKey.currentState!.validate()) return;

    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user == null) return;

    setState(() => _isSubmitting = true);

    final prezzoOfferto = double.parse(_prezzoController.text);
    final prezzoFormattato = NumberFormat('#,##0', 'it_IT').format(prezzoOfferto);

    // Mostra l'alert di conferma prima di inviare l'offerta
    _showCupertinoDialog(prezzoFormattato, prezzoOfferto);
  }

  // Metodo per mostrare l'alert di conferma prima di inviare l'offerta
  void _showCupertinoDialog(String prezzoFormattato, double prezzoOfferto) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Conferma Offerta'),
        content: Text('Confermi di inviare un\'offerta di €$prezzoFormattato?'),
        actions: [
          CupertinoDialogAction(
            textStyle: TextStyle(color: CupertinoColors.activeBlue),
            onPressed: () {
              if (mounted) {
                setState(() => _isSubmitting = false);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Annulla'),
          ),
          CupertinoDialogAction(
            textStyle: TextStyle(color: CupertinoColors.activeBlue),
            onPressed: () async {
              Navigator.of(context).pop();

              final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
              if (user == null) {
                if (mounted) setState(() => _isSubmitting = false);
                return;
              }

              final proposta = Proposta(
                idProposta: 0,
                idImmobileProposta: widget.immobile['id_immobile'],
                vecchioPrezzo: (widget.immobile['prezzo'] as num).toDouble(),
                nuovoPrezzo: prezzoOfferto,
                statoProposta: 'In attesa',
                dataProposta: DateTime.now(),
                oraProposta: DateTime.now(),
                usernameUtenteProposta: user.username,
                usernameAgenteControProposta: '',
                controProposta: 0.0,
                statoControProposta: 'Nessuna',
              );

              final repository = PropostaRepository();
              final result = await repository.inviaProposta(proposta);

              if (!mounted) return;
              setState(() => _isSubmitting = false);

              showCupertinoDialog(
                context: context,
                builder: (_) => CupertinoAlertDialog(
                  content: Text(result),
                  actions: [
                    CupertinoDialogAction(
                      textStyle: TextStyle(color: CupertinoColors.activeBlue),
                      onPressed: () {
                        if (mounted) Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Metodo per costruire una pagina di errore quando l'immobile non è valido
  Widget _buildErrorPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invia Offerta', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0079BB),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => NavigationService.navigateTo(const UserHomePage()),
        ),
      ),
      body: const Center(
        child: Text(
          'Nessun Offerta Fatta',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  // Costruisce la struttura del widget, comprese le informazioni sull'immobile e gli elementi del modulo
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery
        .of(context)
        .size
        .width;

    if (widget.immobile == null || widget.immobile is! Map<String, dynamic>) {
      return _buildErrorPage();
    }

    final immobileId = widget.immobile['id_immobile'];
    final prezzoAttuale = (widget.immobile['prezzo'] as num).toDouble();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Invia Offerta',
          style: TextStyle(
            color: Colors.white,
            fontSize: width * 0.045,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: const Color(0xFF0079BB),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => NavigationService.navigateTo(const UserHomePage()),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageAndText(width),
              const SizedBox(height: 15),
              _buildImmobileDetails(immobileId, prezzoAttuale),
              const SizedBox(height: 15),
              _buildPriceField(prezzoAttuale),
              const SizedBox(height: 15),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Costruisce l'immagine e il testo
  Widget _buildImageAndText(width) {
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
      ],
    );
  }

  // Costruisce i dettagli dell'immobile (titolo, prezzo, indirizzo)
  Widget _buildImmobileDetails(int immobileId, double prezzoAttuale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFoto(),
        const SizedBox(height: 10),
        _buildTitolo(),
        const SizedBox(height: 10),
        _buildPrezzoAttuale(prezzoAttuale),
        const SizedBox(height: 10),
        _buildIndirizzo(),
      ],
    );
  }

  // Widget per visualizzare le foto dell'immobile
  Widget _buildFoto() {
    final String? url = widget.immobile['percorso_file'];
    if (url != null && url.isNotEmpty) {
      return Center(
        child: Image.network(
          url,
          fit: BoxFit.cover,
          width: MediaQuery.of(context).size.width * 0.9,
          height: 150,
          errorBuilder: (context, error, stackTrace) => const Text('Immagine non disponibile'),
        ),
      );
    } else {
      return const Text('Nessuna foto disponibile');
    }
  }

  // Widget per visualizzare il titolo dell'immobile
  Widget _buildTitolo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Titolo:',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${widget.immobile['titolo']}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // Widget per visualizzare il prezzo dell'immobile
  Widget _buildPrezzoAttuale(double prezzoAttuale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prezzo attuale:',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold, // Grassetto per "Prezzo attuale"
          ),
        ),
        Text(
          '€${NumberFormat('#,##0', 'it_IT').format(prezzoAttuale)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400, // Stile normale per il prezzo
          ),
        ),
      ],
    );
  }

  // Widget per visualizzare l'indirizzo dell'immobile
  Widget _buildIndirizzo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Indirizzo:',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${widget.immobile['via']}, ${widget.immobile['città']}, (${widget.immobile['provincia']}), ${widget.immobile['cap']}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // Metodo per costruire il campo di input per il prezzo dell'offerta
  Widget _buildPriceField(double prezzoAttuale) {
    return TextFormField(
      controller: _prezzoController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: 'Inserisci l\'offerta',
        floatingLabelStyle: WidgetStateTextStyle.resolveWith((states) {
          if (states.contains(WidgetState.error)) {
            return TextStyle(color: Color(0xFFFF0000));
          }
          if (states.contains(WidgetState.focused)) {
            return TextStyle(color: Colors.blue);
          }
          return TextStyle(color: Colors.grey);
        }),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFF0000), width: 2.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFF0000), width: 2.0),
        ),
        errorStyle: TextStyle(
          color: Color(0xFFFF0000),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Inserisci un prezzo valido';
        }
        final prezzoOfferto = double.tryParse(value);
        if (prezzoOfferto == null || prezzoOfferto >= prezzoAttuale) {
          return 'L\'offerta deve essere inferiore al prezzo attuale (€${NumberFormat('#,##0', 'it_IT').format(prezzoAttuale)})';
        }
        return null;
      },
    );
  }

  // Metodo per costruire il bottone di invio dell'offerta
  Widget _buildSubmitButton() {
    return _isSubmitting
        ? const Center(child: CircularProgressIndicator())
        : ElevatedButton(
      onPressed: _inviaOfferta,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(double.infinity, 55),
        // Più grande
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      child: const Text('Invia Offerta'),
    );
  }

}