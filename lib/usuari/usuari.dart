import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Usuari extends StatefulWidget {
  const Usuari({super.key});

  @override
  State<Usuari> createState() => _UsuariState();
}

class _UsuariState extends State<Usuari> {
  int _currentIndex = 4;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_username.isNotEmpty ? _username : 'Nil'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Gestiona els teus ajustos i preferències',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 32),

            // Sección: Privacitat i seguretat
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text(
                'Privacitat i seguretat',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingItem(
              title: 'Canvi de nom',
              subtitle: 'Modifica el teu nom d\'usuari',
              buttonText: 'Canviar',
              onPressed: () => _mostrarCanviNom(context),
            ),
            _buildSettingItem(
              title: 'Contrasenya i accés',
              subtitle: 'Canvia la teva contrasenya i mètodes d\'accés',
              buttonText: 'Modificar',
              onPressed: () => _mostrarCanviContrasenya(context),
            ),
            const SizedBox(height: 32),

            // Sección: Suport i ajuda
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text(
                'Suport i ajuda',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingItem(
              title: 'Contacta amb nosaltres',
              subtitle: 'Tens algun problema o suggeriment?',
              buttonText: 'Contactar',
              onPressed: () => _mostrarContacte(context),
            ),
            _buildSettingItem(
              title: 'Preguntes freqüents',
              subtitle: 'Troba respostes a les teves preguntes',
              buttonText: 'Veure',
              onPressed: () => _mostrarPreguntesFrequents(context),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;
          setState(() => _currentIndex = index);
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/foro');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/coleccio');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/Scanner');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/Xat');
              break;
            case 4:
              break;
            case 5:
              Navigator.pushReplacementNamed(context, '/Event');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Foro'),
          BottomNavigationBarItem(icon: Icon(Icons.collections), label: 'Col·lecció'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Escàner'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Xat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Usuari'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 90,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  minimumSize: const Size(0, 0),
                ),
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarContacte(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contacta amb nosaltres'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContactOption('608 23 69 69', Icons.phone),
            const SizedBox(height: 12),
            _buildContactOption('@LaTrobadaMTG', Icons.alternate_email),
            const SizedBox(height: 12),
            _buildContactOption('@LaTrobadaMTG', Icons.tag),
            const SizedBox(height: 16),
            const Text(
              'Horari d\'atenció:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('Dilluns a Divendres de 9:00 a 18:00'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tancar'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        SelectableText(text),
      ],
    );
  }

  void _mostrarPreguntesFrequents(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Preguntes Freqüents'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFAQItem(
                question: 'Com puc afegir cartes a la meva col·lecció?',
                answer: 'Pots escanejar les teves cartes escribint el nom de la carta desitjada. L\'aplicació les reconeixerà automàticament i les afegirà a la teva col·lecció personal.',
              ),
              const Divider(),
              _buildFAQItem(
                question: 'És possible vendre cartes directament a altres usuaris?',
                answer: 'Sí, pots posar cartes a la venda amb un preu en euros o oferir-les per a intercanvi. Altres usuaris poden contactar-te per acordar l\'operació.',
              ),
              const Divider(),
              _buildFAQItem(
                question: 'L\'aplicació cobra comissions per les vendes o intercanvis?',
                answer: 'No, l\'aplicació no cobra cap comissió. L\'únic cost és el de l\'enviament, que queda a càrrec dels usuaris.',
              ),
              const Divider(),
              _buildFAQItem(
                question: 'Com es gestionen els enviaments de les cartes?',
                answer: 'Els usuaris acorden entre ells l\'enviament. L\'aplicació pot recomanar mètodes d\'enviament segurs, però no actua com a intermediari logístic.',
              ),
              const Divider(),
              _buildFAQItem(
                question: 'És segur comprar o intercanviar cartes amb altres usuaris?',
                answer: 'Sí, cada usuari té un perfil amb valoracions i comentaris. Això ajuda a saber si és fiable abans de fer una transacció.',
              ),
              const Divider(),
              _buildFAQItem(
                question: 'Puc accedir a l\'aplicació des del meu ordinador?',
                answer: 'Sí, hi ha una versió web que et permet accedir a totes les funcions de la plataforma des del navegador.',
              ),
              const Divider(),
              _buildFAQItem(
                question: 'Quines cartes són compatibles amb el reconeixement per escàner?',
                answer: 'L\'aplicació utilitza l\'API oficial de Magic: The Gathering, per tant, pot reconèixer pràcticament totes les cartes oficials de la història del joc.',
              ),
              const Divider(),
              _buildFAQItem(
                question: 'Què faig si una carta no és reconeguda correctament?',
                answer: 'Pots editar manualment la informació de la carta o buscar-la pel nom i afegir-la a la col·lecció.',
              ),
              const Divider(),
              _buildFAQItem(
                question: 'Puc comunicar-me amb altres usuaris dins l\'aplicació?',
                answer: 'Sí, hi ha un sistema de missatgeria per negociar intercanvis o vendes, i també un fòrum per fer preguntes i compartir informació.',
              ),
              const Divider(),
              _buildFAQItem(
                question: 'He de crear un compte per poder utilitzar l\'app?',
                answer: 'Sí, per accedir a totes les funcionalitats (col·lecció, vendes, intercanvis, missatges...) és necessari crear un compte amb correu electrònic i contrasenya.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tancar'),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _mostrarCanviNom(BuildContext context) {
    final TextEditingController nomController = TextEditingController();
    final TextEditingController contrasenyaController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Canviar nom d\'usuari'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nomController,
                decoration: const InputDecoration(
                  labelText: 'Nou nom d\'usuari',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Si us plau, introdueix un nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: contrasenyaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contrasenya actual',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Si us plau, introdueix la contrasenya';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel·lar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final response = await _canviarNom(
                  nomController.text,
                  contrasenyaController.text,
                );
                
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(response['message'])),
                  );
                  
                  if (response['status'] == 'success') {
                    // Actualizar el nombre de usuario en SharedPreferences
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('username', nomController.text);
                    setState(() {
                      _username = nomController.text;
                    });
                  }
                }
              }
            },
            child: const Text('Guardar canvis'),
          ),
        ],
      ),
    );
  }

  void _mostrarCanviContrasenya(BuildContext context) {
    final TextEditingController contrasenyaActualController = TextEditingController();
    final TextEditingController novaContrasenyaController = TextEditingController();
    final TextEditingController confirmarContrasenyaController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Canviar contrasenya'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: contrasenyaActualController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contrasenya actual',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Si us plau, introdueix la contrasenya actual';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: novaContrasenyaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nova contrasenya',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Si us plau, introdueix la nova contrasenya';
                  }
                  if (value.length < 6) {
                    return 'La contrasenya ha de tenir almenys 6 caràcters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmarContrasenyaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirma la nova contrasenya',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != novaContrasenyaController.text) {
                    return 'Les contrasenyes no coincideixen';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel·lar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final response = await _canviarContrasenya(
                  contrasenyaActualController.text,
                  novaContrasenyaController.text,
                );
                
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(response['message'])),
                  );
                }
              }
            },
            child: const Text('Guardar canvis'),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _canviarNom(String nouNom, String contrasenya) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.100.3.25:5000/api/informacion/nom'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuari': _username,
          'contrasenya': contrasenya,
          'nou_nom': nouNom,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Error de connexió: $e'};
    }
  }

  Future<Map<String, dynamic>> _canviarContrasenya(String contrasenyaActual, String novaContrasenya) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.100.3.25:5000/api/informacion/contrasenya'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuari': _username,
          'contrasenya': contrasenyaActual,
          'nova_contrasenya': novaContrasenya,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Error de connexió: $e'};
    }
  }
}