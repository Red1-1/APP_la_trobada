import 'package:flutter/material.dart';

class Coleccio extends StatefulWidget {
  const Coleccio({super.key});

  @override
  State<Coleccio> createState() => _ColeccioState();
}

class _ColeccioState extends State<Coleccio> {
  int _currentIndex = 1; // Índice para Colección

  // Función para manejar el cambio de pestaña
  void _onItemTapped(int index) {
    if (index == _currentIndex) return; // Evitar navegar a la misma pantalla
    
    setState(() {
      _currentIndex = index;
    });

    // Navegar a la pantalla correspondiente
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/foro');
        break;
      case 1:
        // Ya estamos en colección
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
    // Datos de ejemplo para la colección
    final List<Map<String, dynamic>> coleccionItems = [
      {
        'nombre': 'Moneda Antigua',
        'imagen': 'assets/coleccion/moneda.jpg',
        'año': '1890',
        'valor': '€150'
      },
      {
        'nombre': 'Sello Postal',
        'imagen': 'assets/coleccion/sello.jpg',
        'año': '1925',
        'valor': '€75'
      },
      {
        'nombre': 'Figura de Porcelana',
        'imagen': 'assets/coleccion/porcelana.jpg',
        'año': '1850',
        'valor': '€320'
      },
      {
        'nombre': 'Libro Antiguo',
        'imagen': 'assets/coleccion/libro.jpg',
        'año': '1789',
        'valor': '€500'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Colección'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Acción para añadir nuevo ítem
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Mi Colección Personal',
              style: TextStyle(
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
                itemCount: coleccionItems.length,
                itemBuilder: (context, index) {
                  final item = coleccionItems[index];
                  return Card(
                    elevation: 4,
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.asset(
                            item['imagen'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['nombre'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('Año: ${item['año']}'),
                              Text('Valor estimado: ${item['valor']}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Acción para ver estadísticas
              },
              icon: const Icon(Icons.analytics),
              label: const Text('Ver Estadísticas'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Acción para añadir nuevo ítem
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: 'Foro',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.collections),
            label: 'Colección',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Scanner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Usuario',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}