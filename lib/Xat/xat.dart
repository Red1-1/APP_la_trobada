import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'chatpage.dart'; // Asegúrate de que este es el nombre correcto del archivo de la pantalla de chat

class Xat extends StatefulWidget {
  const Xat({super.key});

  @override
  State<Xat> createState() => _XatState();
}

class _XatState extends State<Xat> {
  final TextEditingController searchController = TextEditingController();

  List<dynamic> searchResults = [];
  bool isSearching = false;
  String _username = '';
  List<dynamic> conversaciones = [];
  int _currentIndex = 3;
  final String _apiBase = 'http://10.100.3.25:5000/api';

  @override
  void initState() {
    super.initState();
    _loadUsernameAndFetchConversations();
  }

  Future<void> _loadUsernameAndFetchConversations() async {
    final prefs = await SharedPreferences.getInstance();
    String? usuario = prefs.getString('username');
    if (usuario == null || usuario.isEmpty) {
      usuario = '';
    }
    setState(() {
      _username = usuario!;
    });
    await _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    if (_username.isEmpty) return;

    final response = await http.get(
      Uri.parse('$_apiBase/chat/conversaciones/$_username'),
    );

    if (response.statusCode == 200) {
      List<dynamic> allConversations = jsonDecode(response.body);
      final filtered = allConversations
          .where((conv) =>
              conv['nombre_contacto'] != null &&
              conv['nombre_contacto']?.toLowerCase() != _username.toLowerCase())
          .toList();

      setState(() {
        conversaciones = filtered;
      });
    } else {
      setState(() {
        conversaciones = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar conversaciones')),
      );
    }
  }

  Future<void> buscarUsuarios(String query) async {
    if (query.isEmpty) {
      setState(() => searchResults = []);
      return;
    }

    final response = await http.get(
      Uri.parse('$_apiBase/usuarios/buscar?q=$query'),
    );

    if (response.statusCode == 200) {
      setState(() => searchResults = jsonDecode(response.body));
    } else {
      setState(() => searchResults = []);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al buscar usuarios')),
      );
    }
  }

  Future<void> crearConversacion(dynamic usuario) async {
    final response = await http.post(
      Uri.parse('$_apiBase/chat/nuevo'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_usuario1': _username,
        'id_usuario2': usuario['id'],
      }),
    );

    if (response.statusCode == 201) {
      await _fetchConversations();
      setState(() {
        searchResults = [];
        searchController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chat con ${usuario['nom_usuari']} creado')),
      );
    } else if (response.statusCode == 409) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ya existe una conversación con este usuario')),
      );
    } else {
      final error = jsonDecode(response.body)['error'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
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
        Navigator.pushReplacementNamed(context, '/Scanner');
        break;
      case 3:
        // Estamos en Xat, no hacemos nada
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/usuari');
        break;
      case 5:
        Navigator.pushReplacementNamed(context, '/Event'); // Navegación a Eventos
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Buscar usuarios...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          setState(() => searchResults = []);
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                buscarUsuarios(value);
              },
            ),
          ),
        ),
      ),
      body: searchResults.isNotEmpty
          ? ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final usuario = searchResults[index];
                if (usuario['nom_usuari']?.toLowerCase() == _username.toLowerCase()) {
                  return const SizedBox.shrink();
                }
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(usuario['nom_usuari']),
                  subtitle: Text(usuario['correu']),
                  onTap: () => crearConversacion(usuario),
                );
              },
            )
          : conversaciones.isNotEmpty
              ? ListView.builder(
                  itemCount: conversaciones.length,
                  itemBuilder: (context, index) {
                    final conv = conversaciones[index];
                    return ListTile(
                      leading: const Icon(Icons.chat_bubble),
                      title: Text(conv['nombre_contacto']),
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final idUsuarioActual = prefs.getString('id') ?? '';

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatPage(
                              idConversacion: conv['id_conversacion'].toString(),
                              usuarioActual: _username,
                              contacto: conv['nombre_contacto'],
                              idUsuarioActual: idUsuarioActual,
                            ),
                          ),
                        );
                      },
                    );
                  },
                )
              : const Center(child: Text('No tienes conversaciones aún')),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Foro'),
          BottomNavigationBarItem(icon: Icon(Icons.collections), label: 'Col·lecció'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Escàner'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Xat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Usuari'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'), // Nueva pestaña
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
