import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final String _api = 'http://10.100.3.25:5000/api';
  List<dynamic> _events = [];
  String _username = '';
  int _currentIndex = 5;  // Events es index 5
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserAndEvents();
  }

  Future<void> _loadUserAndEvents() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? '';
    });
    await _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('$_api/eventos/mostrar'));
      if (response.statusCode == 200) {
        setState(() {
          _events = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print('Error cargando eventos: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _joinEvent(String eventId) async {
    try {
      final response = await http.post(
        Uri.parse('$_api/eventos/unirse'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_evento': eventId,
          'usuario': _username,
        }),
      );

      if (response.statusCode == 201) {
        await _loadEvents();
      }
    } catch (e) {
      print('Error al unirse al evento: $e');
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
        Navigator.pushReplacementNamed(context, '/Xat');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/usuari');
        break;
      case 5:
        // Ya estamos en Eventos
        break;
    }
  }

  Widget _buildEventCard(dynamic event) {
    final dateTime = DateTime.parse(event['fecha_evento']);
    final isCreator = event['creador_nombre'] == _username;
    final isParticipant = (event['participantes'] as List).any((p) => p['nom_usuari'] == _username);

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
                if (isCreator)
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event['titulo'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(event['descripcion'] ?? ''),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 8),
                Text(event['localizacion']),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text(DateFormat('dd/MM/yyyy HH:mm').format(dateTime)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person, size: 16),
                const SizedBox(width: 8),
                Text('Creado por: ${event['creador_nombre']}'),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: Text('Participantes: ${event['participantes'].length}'),
                ),
                ...(event['participantes'] as List).take(3).map((p) => Chip(
                  label: Text(p['nom_usuari']),
                  avatar: const Icon(Icons.person, size: 16),
                )),
                if (event['participantes'].length > 3)
                  Chip(label: Text('+${event['participantes'].length - 3}')),
              ],
            ),
            const SizedBox(height: 8),
            if (!isParticipant && !isCreator)
              ElevatedButton(
                onPressed: () => _joinEvent(event['id_evento'].toString()),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                ),
                child: const Text('Unirse al Evento'),
              ),
            if (isParticipant)
              const Text(
                'Ya estás participando',
                style: TextStyle(color: Colors.green),
              ),
          ],
        ),
      ),
    );
  }

  void _navigateToCreateEvent() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateEventScreen(username: _username, onEventCreated: _loadEvents)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEvents,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? const Center(child: Text('No hay eventos programados'))
              : RefreshIndicator(
                  onRefresh: _loadEvents,
                  child: ListView.builder(
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      return _buildEventCard(_events[index]);
                    },
                  ),
                ),
      floatingActionButton: _username.isNotEmpty
          ? FloatingActionButton(
              onPressed: _navigateToCreateEvent,
              tooltip: 'Crear nuevo evento',
              child: const Icon(Icons.add),
            )
          : null,
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

class CreateEventScreen extends StatefulWidget {
  final String username;
  final VoidCallback onEventCreated;

  const CreateEventScreen({
    required this.username,
    required this.onEventCreated,
    super.key,
  });

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final String _api = 'http://10.100.3.25:5000/api';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _createEvent() async {
    if (_titleController.text.isEmpty || 
        _locationController.text.isEmpty || 
        _selectedDate == null || 
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    final eventDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$_api/eventos/crear'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'creador': widget.username,
          'titulo': _titleController.text,
          'descripcion': _descriptionController.text,
          'fecha_evento': eventDateTime.toIso8601String(),
          'localizacion': _locationController.text,
        }),
      );

      if (response.statusCode == 201) {
        widget.onEventCreated();
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear evento: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nuevo Evento'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Creador: ${widget.username}'),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título del evento*',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción (opcional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Ubicación*',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(
                      _selectedDate == null
                          ? 'Seleccionar fecha*'
                          : 'Fecha: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      _selectedTime == null
                          ? 'Seleccionar hora*'
                          : 'Hora: ${_selectedTime!.format(context)}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.access_time),
                      onPressed: () => _selectTime(context),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _createEvent,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Crear Evento'),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}