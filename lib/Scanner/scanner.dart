import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Scanner extends StatefulWidget {
  const Scanner({super.key});

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _cartes = [];
  bool _isLoading = false;
  int _currentIndex = 2;

  final String _api = 'http://10.100.3.25:5000/api/carta/web';

  Future<void> _buscarCarta(String nombre) async {
    if (nombre.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(_api),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nom': nombre}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _cartes = jsonDecode(response.body);
        });
      } else {
        setState(() {
          _cartes = [];
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _cartes = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildCartaCard(dynamic carta) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Image.network(
          carta['imatge'],
          width: 60,
          height: 90,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image),
        ),
        title: Text(carta['nom'] ?? 'Sense nom'),
        subtitle: Text('Expansió: ${carta['expansio'] ?? 'N/A'}'),
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/foro');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/coleccio');
        break;
      case 2:
        break; // Ya estamos en Scanner
      case 3:
        Navigator.pushReplacementNamed(context, '/Xat');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/usuari');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanejar cartes Magic'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              onSubmitted: _buscarCarta,
              decoration: InputDecoration(
                hintText: 'Introdueix el nom de la carta',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _buscarCarta(_controller.text),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          Expanded(
            child: _cartes.isEmpty
                ? const Center(child: Text('No s\'han trobat cartes'))
                : ListView.builder(
                    itemCount: _cartes.length,
                    itemBuilder: (context, index) => _buildCartaCard(_cartes[index]),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: 'Fòrum',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.collections),
            label: 'Col·lecció',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Escàner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Xat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Usuari',
          ),
        ],
      ),
    );
  }
}
