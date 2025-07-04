import 'package:dietiestates2025/pages/agent/agent_home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/foto_repositories.dart';
import '../../data/repositories/immobile_repositories.dart';

import '../../provider/auth_provider.dart';

import '../../services/cloudinary_service.dart';
import '../../services/navigation_service.dart';
import '../../services/http_service.dart';

import '../../widgets/agent_bottom_bar_widget.dart';

class AgentInsertAddPage extends StatefulWidget {
  const AgentInsertAddPage({super.key});

  @override
  State<AgentInsertAddPage> createState() => _AgentInsertAddPageState();
}

class _AgentInsertAddPageState extends State<AgentInsertAddPage> {
  int _selectedIndex = 2;
  final _formKey = GlobalKey<FormState>();
  List<String> imageUrls = [];

  final FotoRepositories fotoRepo = FotoRepositories(
    HttpService(),
    ImageUploadService(),
  );

  //Funzione per selezionare e caricare l'immagine
  Future<void> _pickAndUploadImage() async {
    try {
      // Scegli da galleria (puoi aggiungere anche da fotocamera)
      final pickedFile = await fotoRepo.pickImage(ImageSource.gallery);
      if (pickedFile != null) {
        // Carica l'immagine su Cloudinary
        final imageUrl = await fotoRepo.uploadImage(pickedFile);
        if (imageUrl != null) {
          setState(() {
            // Aggiungi l'URL dell'immagine alla lista
            imageUrls.add(imageUrl);
          });
        }
      }
    } catch (e) {
      if (!mounted) return;

      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text("Errore"),
            content: Text("Errore durante il caricamento dell'immagine"),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  // Funzione per rimuovere l'immagine dalla lista
  void _removeImage(int index) {
    setState(() {
      imageUrls.removeAt(index);
    });
  }

  // Variabili per i campi del form di inserimento immobile
  String tipoContratto = '';
  String tipologiaImmobile = '';
  String titolo = '';
  String testo = '';
  double superficie = 0.0;
  double prezzo = 0.0;
  int idIndirizzoImmobile = 0;
  int idFiltroAvanzato = 0;
  int idServizioUlteriore = 0;

  String citta = '';
  String provincia = '';
  String via = '';
  String cap = '';

  int stanza = 0;
  int piano = 0;
  int bagno = 0;
  String parcheggio = '';
  String classeEnergetica = '';

  bool climatizzatore = false;
  bool balcone = false;
  bool portineria = false;
  bool giardino = false;
  bool ascensore = false;
  bool arredato = false;

  // Funzione per reimpostare i valori dei campi del form di inserimento immobile
  void _resetFormFields() {
    setState(() {
      tipoContratto = '';
      tipologiaImmobile = '';
      titolo = '';
      testo = '';
      superficie = 0.0;
      prezzo = 0.0;
      idIndirizzoImmobile = 0;
      idFiltroAvanzato = 0;
      idServizioUlteriore = 0;


      citta = '';
      provincia = '';
      via = '';
      cap = '';

      stanza = 0;
      piano = 0;
      bagno = 0;
      parcheggio = '';
      classeEnergetica = '';

      climatizzatore = false;
      balcone = false;
      portineria = false;
      giardino = false;
      ascensore = false;
      arredato = false;
      imageUrls.clear();

      _formKey.currentState?.reset();
    });
  }

  // Funzione per inviare il form
  Future<void> _submitForm() async {
    if (tipoContratto.isEmpty) {
      _showDialog('Attenzione', 'Seleziona il tipo di contratto');
      return;
    }

    if (imageUrls.isEmpty) {
      _showDialog('Attenzione', 'Carica almeno una foto');
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      DateTime currentDate = DateTime.now();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final usernameAgente = authProvider.currentUser?.username ?? '';

      final immobileData = {
        'percorso_file': imageUrls,
        'ordine': 0,
        'data_creazione': currentDate.toIso8601String().split('T')[0],
        'ora_creazione': currentDate.toIso8601String().split('T')[1],
        'tipo_contratto': tipoContratto,
        'tipologia_immobile': tipologiaImmobile,
        'username_agente': usernameAgente,
        'titolo': titolo,
        'testo': testo,
        'superficie': superficie,
        'prezzo': prezzo,
        'provincia': provincia,
        'via': via,
        'cap': cap,
        'città': citta,
        'stanza': stanza,
        'piano': piano,
        'bagno': bagno,
        'parcheggio': parcheggio,
        'classe_energetica': classeEnergetica,
        'climatizzatore': climatizzatore,
        'balcone': balcone,
        'portineria': portineria,
        'giardino': giardino,
        'ascensore': ascensore,
        'arredato': arredato,
      };

      try {
        final immobileRepositories = ImmobileRepositories(HttpService());
        await immobileRepositories.insertImmobile(immobileData);

        if (mounted) {
              _showDialog('Conferma', 'Immobile inserito con successo');
          _resetFormFields();
        }
      } catch (e) {
        if (mounted) {
              _showDialog('Attenzione', 'Errore durante l\'inserimento dell\'immobile');
        }
      }
    }
  }

  //Metodo per costruire l'alert
  void _showDialog(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Text(message, style: const TextStyle(fontSize: 16)),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFF0079BB)),
              ),
            ),
          ],
        );
      },
    );
  }

  // Metodo per costruire l'immagine
  Widget _buildImage(double width) {
    return Column(
      children: [
        Image.asset(
          'assets/images/home/DietiEstates2025NoBg.png',
          // Percorso dell'immagine
          height: width * 0.60,
        ),
      ],
    );
  }

  // Metodo per costruire il tipo di contratto
  Widget _buildTipoContratto() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Tipo Contratto',
            style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.038),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    tipoContratto = 'Vendita';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  decoration: BoxDecoration(
                    color: tipoContratto == 'Vendita' ? Colors.orange : Colors.white,
                    border: Border.all(color: Colors.orange, width: 1.4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Vendita',
                    style: TextStyle(
                      fontSize: 15,
                      color: tipoContratto == 'Vendita' ? Colors.white : Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    tipoContratto = 'Affitto';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  decoration: BoxDecoration(
                    color: tipoContratto == 'Affitto' ? Colors.orange : Colors.white,
                    border: Border.all(color: Colors.orange, width: 1.4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Affitto',
                    style: TextStyle(
                      fontSize: 15,
                      color: tipoContratto == 'Affitto' ? Colors.white : Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Metodo per costruire il pulsante di caricamento dell'immagine
  Widget _buildImageUploadButton() {
    return GestureDetector(
      onTap: _pickAndUploadImage,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.orange, width: 1.4),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'Carica Foto',
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Metodo per costruire i campi del form
  Widget _buildTextFormField({
    required String label,
    required String? Function(String?) validator,
    required ValueChanged<String> onChanged,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(color: Colors.black),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
        cursorColor: Colors.black,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
      ),
    );
  }

  //Metodo per costruire i campi del form specifico per Testo
  Widget _buildMultilineTextField({
    required String label,
    required String? Function(String?) validator,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        maxLines: 6,
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: true,
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(color: Colors.black),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
        cursorColor: Colors.black,
        validator: validator,
        onChanged: onChanged,
      ),
    );
  }

  // Metodo per costruire i campi del form specifici per l'inserimento immobile
  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTipoContratto(),

        SizedBox(height: 20),

        // Sezione: Foto
        Center(
          child: Column(
            children: [
              Icon(
                Icons.camera_alt,
                size: MediaQuery.of(context).size.width * 0.07,
              ),
              SizedBox(height: 10),
              _buildImageUploadButton(),
              SizedBox(height: 10),
              _buildImagePreview(),
            ],
          ),
        ),

        SizedBox(height: 20),

        // Sezione: Dati Generali
        Text("Dati generali", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Tipologia Immobile',
              filled: true,
              fillColor: Colors.white,
              labelStyle: TextStyle(color: Colors.black),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
            value: tipologiaImmobile.isEmpty ? null : tipologiaImmobile,
            items: [
              'Appartamento',
              'Villa',
              'Villetta a schiera',
              'Casa indipendente',
              'Loft',
              'Attico',
              'Monolocale',
              'Bilocale',
              'Trilocale',
              'Rustico',
              'Casale',
              'Mansarda',
            ]
                .map((String tipologia) {
              return DropdownMenuItem<String>(
                value: tipologia,
                child: Text(tipologia),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                tipologiaImmobile = newValue ?? '';
              });
            },
            validator: (value) => value == null || value.isEmpty ? 'Seleziona la tipologia immobile' : null,
            dropdownColor: Colors.white,
          ),
        ),
        _buildTextFormField(
          label: 'Titolo',
          validator: (value) => value!.isEmpty ? 'Inserisci il titolo' : null,
          onChanged: (value) => titolo = value,
        ),
        _buildMultilineTextField(
          label: 'Testo',
          validator: (value) => value!.isEmpty ? 'Inserisci il testo' : null,
          onChanged: (value) => testo = value,
        ),
        _buildTextFormField(
          label: 'Superficie (m²)',
          keyboardType: TextInputType.number,
          validator: (value) => value!.isEmpty ? 'Inserisci la superficie' : null,
          onChanged: (value) => superficie = double.tryParse(value) ?? 0.0,
        ),
        _buildTextFormField(
          label: 'Prezzo (€)',
          keyboardType: TextInputType.number,
          validator: (value) => value!.isEmpty ? 'Inserisci il prezzo' : null,
          onChanged: (value) => prezzo = double.tryParse(value) ?? 0.0,
        ),


        SizedBox(height: 20),

        // Sezione: Indirizzo
        Text("Indirizzo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        _buildTextFormField(
          label: 'Provincia',
          validator: (value) => value!.isEmpty ? 'Inserisci la provincia' : null,
          onChanged: (value) => provincia = value,
        ),
        _buildTextFormField(
          label: 'Via',
          validator: (value) => value!.isEmpty ? 'Inserisci la via' : null,
          onChanged: (value) => via = value,
        ),
        _buildTextFormField(
          label: 'CAP',
          keyboardType: TextInputType.number,
          validator: (value) => value!.isEmpty ? 'Inserisci il CAP' : null,
          onChanged: (value) => cap = value,
        ),
        _buildTextFormField(
          label: 'Città',
          validator: (value) => value!.isEmpty ? 'Inserisci la città' : null,
          onChanged: (value) => citta = value,
        ),

        SizedBox(height: 20),

        // Sezione: Filtro Avanzato
        Text("Caratteristiche", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        _buildTextFormField(
          label: 'Numero Stanze',
          keyboardType: TextInputType.number,
          validator: (value) => value!.isEmpty ? 'Inserisci il numero di stanze' : null,
          onChanged: (value) => stanza = int.tryParse(value) ?? 0,
        ),
        _buildTextFormField(
          label: 'Piano',
          keyboardType: TextInputType.number,
          validator: (value) => value!.isEmpty ? 'Inserisci il piano' : null,
          onChanged: (value) => piano = int.tryParse(value) ?? 0,
        ),
        _buildTextFormField(
          label: 'Numero Bagni',
          keyboardType: TextInputType.number,
          validator: (value) => value!.isEmpty ? 'Inserisci il numero di bagni' : null,
          onChanged: (value) => bagno = int.tryParse(value) ?? 0,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Parcheggio',
              filled: true,
              fillColor: Colors.white,
              labelStyle: TextStyle(color: Colors.black),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
            value: parcheggio.isEmpty ? null : parcheggio,
            items: [
              'Box privato',
              'Posto auto riservato',
              'Posto auto libero',
              'Posto bici',
              'Posto moto',
            ]
                .map((String tipoParcheggio) {
              return DropdownMenuItem<String>(
                value: tipoParcheggio,
                child: Text(tipoParcheggio),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                parcheggio = newValue ?? '';
              });
            },
            validator: (value) => value == null || value.isEmpty ? 'Seleziona il tipo di parcheggio' : null,
              dropdownColor: Colors.white
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Classe Energetica',
              filled: true,
              fillColor: Colors.white,
              labelStyle: TextStyle(color: Colors.black),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
            value: classeEnergetica.isEmpty ? null : classeEnergetica,
            items: [
              'A',
              'B',
              'C',
              'D',
              'E',
              'F',
              'G',
            ]
                .map((String classe) {
              return DropdownMenuItem<String>(
                value: classe,
                child: Text(classe),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                classeEnergetica = newValue ?? '';
              });
            },
            validator: (value) => value == null || value.isEmpty ? 'Seleziona la classe energetica' : null,
              dropdownColor: Colors.white
          ),
        ),

        SizedBox(height: 20),

        // Sezione: Servizioulteriore
        Text("Servizi Ulteriori", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        CheckboxListTile(
          title: Text("Climatizzatore"),
          value: climatizzatore,
          onChanged: (value) => setState(() => climatizzatore = value!),
          activeColor: Colors.blue,
        ),
        CheckboxListTile(
          title: Text("Balcone"),
          value: balcone,
          onChanged: (value) => setState(() => balcone = value!),
          activeColor: Colors.blue,
        ),
        CheckboxListTile(
          title: Text("Portineria"),
          value: portineria,
          onChanged: (value) => setState(() => portineria = value!),
          activeColor: Colors.blue,
        ),
        CheckboxListTile(
          title: Text("Giardino"),
          value: giardino,
          onChanged: (value) => setState(() => giardino = value!),
          activeColor: Colors.blue,
        ),
        CheckboxListTile(
          title: Text("Ascensore"),
          value: ascensore,
          onChanged: (value) => setState(() => ascensore = value!),
          activeColor: Colors.blue,
        ),
        CheckboxListTile(
          title: Text("Arredato"),
          value: arredato,
          onChanged: (value) => setState(() => arredato = value!),
          activeColor: Colors.blue,
        ),
      ],
    );
  }

  // Metodo per costruire la vista delle immagini
  Widget _buildImagePreview() {
    return imageUrls.isEmpty
        ? Container()
        : Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: List.generate(imageUrls.length, (index) {
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrls[index],
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // Metodo per costruire il pulsante di invio
  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xffff0000),
      ),
      child: Text(
        'Inserisci Immobile',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  // Metodo per gestire il cambio di pagina
  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
    NavigationService.navigateToAgentBottomBarPage(index);
  }

  // Metodo per costruire la pagina
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Inserisci Immobile',
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
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: width * 0.05,
                vertical: height * 0.02),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildImage(width),
                  _buildFormFields(),
                  SizedBox(height: height * 0.02),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: AgentBottomBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

