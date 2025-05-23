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
  List<dynamic> _cartasColeccion = [];
  int? _coleccionSeleccionada;

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
      _coleccionSeleccionada = null;
      _cartasColeccion = [];
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

  Future<void> _obtenerCartasColeccion(int idColeccion) async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      final request = http.Request(
        'GET',
        Uri.parse('$_api/api/carta/coleccio/mostrar'),
      )
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode({'id_col': idColeccion});

      final response = await http.Client().send(request);
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        setState(() {
          _cartasColeccion = jsonDecode(responseBody);
          _coleccionSeleccionada = idColeccion;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = jsonDecode(responseBody)['error'] ?? 'Error al cargar cartas';
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
      final idStr = id.toString();
      print('Intentando eliminar colección ID: $idStr');

      final response = await http.post(
        Uri.parse('$_api/api/coleccio/eliminar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usr': _username,
          'id': idStr
        }),
      );

      print('Respuesta del servidor: ${response.statusCode}');
      print('Cuerpo de respuesta: ${response.body}');

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
      print('Error al eliminar: $e');
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

  void _volverAColecciones() {
    setState(() {
      _coleccionSeleccionada = null;
      _cartasColeccion = [];
    });
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
        // Estamos en Colecció, no hacemos nada
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
      case 5:
        Navigator.pushReplacementNamed(context, '/Event'); // Nueva pestaña Eventos
        break;
    }
  }

  Widget _buildColeccionesList() {
    return RefreshIndicator(
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
              child: ListView.builder(
                itemCount: _coleccions.length,
                itemBuilder: (context, index) {
                  final coleccio = _coleccions[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        coleccio['nombre'],
                        style: const TextStyle(fontSize: 18),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _eliminarColeccio(coleccio['id']);
                        },
                      ),
                      onTap: () => _obtenerCartasColeccion(coleccio['id']),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartasList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _volverAColecciones,
              ),
              const SizedBox(width: 10),
              Text(
                _coleccions.firstWhere((c) => c['id'] == _coleccionSeleccionada)['nombre'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _cartasColeccion.isEmpty
              ? const Center(child: Text('No hay cartas en esta colección'))
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: _cartasColeccion.length,
                  itemBuilder: (context, index) {
                    final carta = _cartasColeccion[index];
                    return Card(
                      elevation: 4,
                      child: Column(
                        children: [
                          Expanded(
                            child: carta['imatge'] != null
                                ? Image.network(
                                    carta['imatge'],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.broken_image, size: 50);
                                    },
                                  )
                                : const Icon(Icons.credit_card, size: 50),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              carta['nom'] ?? 'Sin nombre',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_coleccionSeleccionada == null 
            ? 'La Meva Col·lecció' 
            : 'Cartes de la Col·lecció'),
        centerTitle: true,
        actions: [
          if (_coleccionSeleccionada == null && _username.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _mostrarDialogCrearColeccio,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : (_coleccionSeleccionada == null ? _buildColeccionesList() : _buildCartasList()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: 'Foro',
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
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
        ],
      ),
    );
  }
}
