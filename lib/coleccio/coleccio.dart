import 'package:flutter/material.dart';

class Coleccio extends StatefulWidget {
  const Coleccio({super.key});

  @override
  State<Coleccio> createState() => _ColeccioState();
}

class _ColeccioState extends State<Coleccio> {
  int _currentIndex = 1; // Índex per a Colecció

  // Funció per canviar de pàgina
  void _onItemTapped(int index) {
    if (index == _currentIndex) return; // Evitar navegar a la mateixa pàgina
    
    setState(() {
      _currentIndex = index;
    });

    // Navegació entre pàgines
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/foro');
        break;
      case 1:
        // Ja estem a col·lecció
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
    // Dades d'exemple per la col·lecció
    final List<Map<String, dynamic>> coleccionItems = [
      {
        'nom': 'Moneda Antiga',
        'imatge': 'assets/coleccion/moneda.jpg',
        'any': '1890',
        'valor': '150€'
      },
      {
        'nom': 'Segell Postal',
        'imatge': 'assets/coleccion/sello.jpg',
        'any': '1925',
        'valor': '75€'
      },
      {
        'nom': 'Figura de Porcellana',
        'imatge': 'assets/coleccion/porcelana.jpg',
        'any': '1850',
        'valor': '320€'
      },
      {
        'nom': 'Llibre Antic',
        'imatge': 'assets/coleccion/libro.jpg',
        'any': '1789',
        'valor': '500€'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('La Meva Col·lecció'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Acció per afegir nou ítem
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'La Meva Col·lecció Personal',
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
                            item['imatge'],
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
                                item['nom'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('Any: ${item['any']}'),
                              Text('Valor estimat: ${item['valor']}'),
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
                // Acció per veure estadístiques
              },
              icon: const Icon(Icons.analytics),
              label: const Text('Veure Estadístiques'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Acció per afegir nou ítem
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