import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Foro extends StatefulWidget {
  const Foro({super.key});

  @override
  State<Foro> createState() => _ForoState();
}

class _ForoState extends State<Foro> {
  final String _api = 'http://10.100.3.25:5000/api';
  List<dynamic> _missatges = [];
  String _username = '';
  final TextEditingController _controller = TextEditingController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserAndMessages();
  }

  Future<void> _loadUserAndMessages() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? '';
    });
    await _carregarMissatges();
  }

  Future<void> _carregarMissatges() async {
    try {
      final response = await http.get(Uri.parse('$_api/foro/mostrar_missatges'));
      if (response.statusCode == 200) {
        setState(() {
          _missatges = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print('Error carregant missatges: $e');
    }
  }

  Future<void> _enviarMissatge() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('$_api/foro/nou_missatge'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_user': _username,
          'mensaje': text,
        }),
      );

      if (response.statusCode == 201) {
        _controller.clear();
        await _carregarMissatges();
      } else {
        print('Error al enviar missatge');
      }
    } catch (e) {
      print('Error al enviar: $e');
    }
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
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
        Navigator.pushReplacementNamed(context, '/usuari');
        break;
    }
  }

  Widget _buildMissatgeCard(dynamic missatge) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.person)),
                const SizedBox(width: 10),
                Text('@${missatge['nom_usuari']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            Text(missatge['mensaje'] ?? ''),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Text('Respondre', style: TextStyle(color: Colors.purple)),
                Text("M'agrada", style: TextStyle(color: Colors.purple)),
                Text('Compartir', style: TextStyle(color: Colors.purple)),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fòrum'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _missatges.isEmpty
                ? const Center(child: Text('No hi ha missatges encara'))
                : RefreshIndicator(
                    onRefresh: _carregarMissatges,
                    child: ListView.builder(
                      itemCount: _missatges.length,
                      itemBuilder: (context, index) {
                        return _buildMissatgeCard(_missatges[index]);
                      },
                    ),
                  ),
          ),
          if (_username.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Escriu un missatge...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _enviarMissatge,
                  ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Fòrum'),
          BottomNavigationBarItem(icon: Icon(Icons.collections), label: 'Col·lecció'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Escàner'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Xat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Usuari'),
        ],
      ),
    );
  }
}
