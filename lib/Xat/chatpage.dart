import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatPage extends StatefulWidget {
  final String idConversacion;
  final String usuarioActual;
  final String contacto;
  final String idUsuarioActual;

  const ChatPage({
    super.key,
    required this.idConversacion,
    required this.usuarioActual,
    required this.contacto,
    required this.idUsuarioActual,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late IO.Socket socket;
  final TextEditingController mensajeController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  List<Map<String, dynamic>> mensajes = [];

  @override
  void initState() {
    super.initState();
    conectarSocket();
    obtenerMensajes();
  }

  void conectarSocket() {
    socket = IO.io('http://10.100.3.25:5000/api', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      print('Conectado al socket');
      socket.emit('unirse_a_conversacion', {
        'usuario': widget.contacto,
        'id_usuario': widget.idUsuarioActual,
      });
    });

    socket.on('nuevo_mensaje', (data) {
      if (data['id_conversacion'].toString() == widget.idConversacion) {
        setState(() {
          mensajes.add({
            'id_remitente': data['id_remitente'],
            'mensaje': data['mensaje'],
            'fecha_envio': data['fecha_envio']
          });
        });
        scrollAlFinal();
      }
    });
  }

  Future<void> obtenerMensajes() async {
    final url = Uri.parse(
        'http://10.100.3.25:5000/api/chat/mensajes/${widget.contacto}/${widget.usuarioActual}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> datos = json.decode(response.body);
      setState(() {
        mensajes = datos.map((m) => Map<String, dynamic>.from(m)).toList();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollAlFinal();
      });
    } else {
      print("Error al obtener mensajes: ${response.body}");
    }
  }

  void enviarMensaje() {
  final mensaje = mensajeController.text.trim();
  if (mensaje.isEmpty) return;

  socket.emit('enviar_mensaje', {
    'id_conversacion': widget.idConversacion,
    'id_remitente': widget.idUsuarioActual,
    'mensaje': mensaje,
  });

  setState(() {
    mensajes.add({
      'id_remitente': widget.idUsuarioActual,
      'mensaje': mensaje,
      'fecha_envio': DateTime.now().toIso8601String(),
    });
  });

  mensajeController.clear();
  scrollAlFinal();
}

  void scrollAlFinal() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    socket.emit('salir_de_conversacion', {
      'id_conversacion': widget.idConversacion,
    });
    socket.dispose();
    mensajeController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contacto),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: mensajes.length,
              itemBuilder: (context, index) {
                final mensaje = mensajes[index];
                final esMio = mensaje['id_remitente'].toString() ==
                    widget.idUsuarioActual;

                return Align(
                  alignment:
                      esMio ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 4, horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: esMio
                          ? Colors.blue[200]
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(mensaje['mensaje']),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: mensajeController,
                    decoration: const InputDecoration(
                      hintText: 'Escribe un mensaje...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: enviarMensaje,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
