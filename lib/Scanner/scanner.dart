import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Scanner extends StatefulWidget {
  const Scanner({super.key});

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _cartes = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentIndex = 2;  // Scanner is index 2
  String? _selectedColeccion;
  String _username = '';
  List<dynamic> _coleccions = [];
  bool _loadingColeccions = true;

  final String _api = 'http://10.100.3.25:5000/api/carta/web';

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

    if (_username.isNotEmpty) {
      await _carregarColeccions();
    }
  }

  Future<void> _carregarColeccions() async {
    setState(() {
      _loadingColeccions = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.100.3.25:5000/api/coleccio/mostrar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'usr': _username}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _coleccions = jsonDecode(response.body);
          _loadingColeccions = false;
        });
      } else {
        setState(() {
          _errorMessage = jsonDecode(response.body)['error'] ?? 'Error al cargar colecciones';
          _loadingColeccions = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de conexión: $e';
        _loadingColeccions = false;
      });
    }
  }

  Future<void> _buscarCarta(String nombre) async {
    if (nombre.trim().isEmpty) {
      setState(() {
        _errorMessage = "Si us plau, introduïu un nom de carta";
        _cartes = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final Map<String, dynamic> body = {'nom': nombre};
      if (_selectedColeccion != null) {
        body['coleccio'] = _selectedColeccion;
      }

      final response = await http.post(
        Uri.parse(_api),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          final cartesAmbImatge =
              data.where((carta) => carta['imatge'] != null).toList();

          if (cartesAmbImatge.isEmpty) {
            setState(() {
              _errorMessage =
                  "S'han trobat cartes però cap amb imatge disponible";
              _cartes = [];
            });
          } else {
            setState(() {
              _cartes = cartesAmbImatge;
            });
          }
        } else {
          setState(() {
            _errorMessage = "Error inesperat: la resposta no és una llista";
            _cartes = [];
          });
        }
      } else {
        final errorMsg =
            jsonDecode(response.body)['error'] ?? 'Error desconegut de l\'API';
        setState(() {
          _errorMessage = errorMsg;
          _cartes = [];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error de connexió amb el servidor: $e";
        _cartes = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _afegirCartaAColeccio(String idCarta, String idCol) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.100.3.25:5000/api/carta/coleccio'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_carta': idCarta,
          'id_col': idCol,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Carta añadida correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Error desconocido';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _mostrarDialogColecciones(dynamic carta) {
    if (_username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para añadir cartas a colecciones'),
        ),
      );
      return;
    }

    if (_coleccions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tienes colecciones creadas'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir a colección'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _coleccions.length,
            itemBuilder: (context, index) {
              final coleccio = _coleccions[index];
              return ListTile(
                title: Text(coleccio['nombre']),
                onTap: () {
                  Navigator.pop(context);
                  _afegirCartaAColeccio(carta['id'].toString(), coleccio['id'].toString());
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartaImage(dynamic carta) {
    return GestureDetector(
      onTap: () => _mostrarDialogColecciones(carta),
      child: Container(
        margin: const EdgeInsets.all(4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            carta['imatge'],
            width: 100,
            height: 140,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 100,
              height: 140,
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, size: 40),
            ),
          ),
        ),
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
        // Estamos en Scanner
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/Xat');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/usuari');
        break;
      case 5:
        Navigator.pushReplacementNamed(context, '/Event'); // pestaña Eventos
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
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: _buscarCarta,
                    decoration: InputDecoration(
                      hintText: 'Introdueix el nom de la carta',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _buscarCarta(_controller.text),
                ),
                const SizedBox(width: 8),
                _username.isEmpty
                    ? IconButton(
                        icon: const Icon(Icons.warning),
                        tooltip: 'Inicia sesión para ver tus colecciones',
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                      )
                    : _loadingColeccions
                        ? const Padding(
                            padding: EdgeInsets.all(8),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : PopupMenuButton<String>(
                            icon: const Icon(Icons.filter_list),
                            onSelected: (String value) {
                              setState(() {
                                _selectedColeccion = value;
                              });
                              _buscarCarta(_controller.text);
                            },
                            itemBuilder: (BuildContext context) {
                              return [
                                const PopupMenuItem<String>(
                                  value: null,
                                  child: Text('Todas las colecciones'),
                                ),
                                ..._coleccions.map((coleccion) {
                                  return PopupMenuItem<String>(
                                    value: coleccion['nombre'],
                                    child: Text(coleccion['nombre']),
                                  );
                                }),
                              ];
                            },
                          ),
              ],
            ),
          ),
          if (_selectedColeccion != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Chip(
                    label: Text(
                      _selectedColeccion!,
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                    backgroundColor: Colors.blue[50],
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() {
                        _selectedColeccion = null;
                      });
                      _buscarCarta(_controller.text);
                    },
                  ),
                ],
              ),
            ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            )
          else if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            )
          else if (_cartes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('No s\'han trobat cartes'),
            )
          else
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  childAspectRatio: 0.7,
                ),
                itemCount: _cartes.length,
                itemBuilder: (context, index) => _buildCartaImage(_cartes[index]),
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
