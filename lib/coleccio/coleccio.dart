import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Coleccio extends StatefulWidget {
  const Coleccio({super.key});

  @override
  State<Coleccio> createState() => _ColeccioState();
}

class _ColeccioState extends State<Coleccio> {
  final String _api = 'http://10.100.3.25:5000';
  int _currentIndex = 1;
  List<dynamic> _coleccions = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUserAndCollections();
  }

  Future<void> _loadUserAndCollections() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? '';
    });

    if (_username.isEmpty) {
      setState(() {
        _errorMessage = 'Usuario no identificado';
        _isLoading = false;
      });
      return;
    }

    await _carregarColeccions();
  }

  Future<void> _carregarColeccions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final response = await http.post(
        Uri.parse('$_api/api/coleccio/mostrar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'usr': _username}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _coleccions = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = jsonDecode(response.body)['error'] ?? 'Error al cargar colecciones';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de conexión: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _crearColeccio(String nomCol) async {
    try {
      final response = await http.post(
        Uri.parse('$_api/api/coleccio'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usr': _username,
          'nom_col': nomCol
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Colección creada correctamente'))
        );
        await _carregarColeccions();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonDecode(response.body)['error'] ?? 'Error desconocido'))
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'))
      );
    }
  }

  Future<void> _eliminarColeccio(dynamic id) async {
    try {
      // Verificación y conversión del ID
      final idStr = id.toString();
      print('Intentando eliminar colección ID: $idStr'); // Debug

      final response = await http.post(
        Uri.parse('$_api/api/coleccio/eliminar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usr': _username,
          'id': idStr
        }),
      );

      print('Respuesta del servidor: ${response.statusCode}'); // Debug
      print('Cuerpo de respuesta: ${response.body}'); // Debug

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Colección eliminada correctamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          )
        );
        await _carregarColeccions();
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${errorData['error'] ?? 'Error desconocido'}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          )
        );
      }
    } catch (e) {
      print('Error al eliminar: $e'); // Debug
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        )
      );
    }
  }

  void _mostrarDialogCrearColeccio() {
    TextEditingController nomController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Colección'),
        content: TextField(
          controller: nomController,
          decoration: const InputDecoration(
            labelText: 'Nombre de la colección',
            hintText: 'Ej: Mis cartas favoritas'
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (nomController.text.isNotEmpty) {
                _crearColeccio(nomController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Crear'),
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('La Meva Col·lecció'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _username.isNotEmpty ? _mostrarDialogCrearColeccio : null,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _coleccions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('No tienes colecciones creadas'),
                          if (_username.isEmpty)
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, '/login');
                              },
                              child: const Text('Iniciar sesión'),
                            )
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _carregarColeccions,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'Colección de $_username',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 0.8,
                                ),
                                itemCount: _coleccions.length,
                                itemBuilder: (context, index) {
                                  final coleccio = _coleccions[index];
                                  return Card(
                                    elevation: 4,
                                    child: Stack(
                                      children: [
                                        Column(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                color: Colors.grey[200],
                                                child: Icon(
                                                  Icons.collections,
                                                  size: 50,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    coleccio['nombre'],
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Positioned(
                                          top: 5,
                                          right: 5,
                                          child: IconButton(
                                            icon: const Icon(Icons.delete),
                                            color: Colors.red,
                                            onPressed: () async {
                                              await _eliminarColeccio(coleccio['id']);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
      floatingActionButton: _username.isNotEmpty
          ? FloatingActionButton(
              onPressed: _mostrarDialogCrearColeccio,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
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
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}