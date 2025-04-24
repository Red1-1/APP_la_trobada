// Importa el paquete http para realizar solicitudes HTTP
import 'package:http/http.dart' as http;
// Importa el paquete dart:convert para convertir datos JSON
import 'dart:convert';

// Función asíncrona para obtener datos desde una API
Future<List<dynamic>> fetchData() async {
  // Realiza una solicitud GET a la URL especificada
  final response = await http.get(Uri.parse('http://10.100.3.25:5000/api/data'));
  
  // Verifica si la respuesta tiene un código de estado 200 (OK)
  if (response.statusCode == 200) {
    // Decodifica el cuerpo de la respuesta JSON y retorna la lista de datos
    return json.decode(response.body)['data'];
  } else {
    // Si la respuesta no es exitosa, lanza una excepción
    throw Exception('Error al cargar los datos');
  }
}

// Función asíncrona para enviar datos a una API
Future<void> postData(Map<String, dynamic> data) async {
  // Realiza una solicitud POST a la URL especificada con los datos en el cuerpo
  final response = await http.post(
    Uri.parse('http://10.100.3.25:5000/api/data'),
    headers: {'Content-Type': 'application/json'}, // Especifica que el contenido es JSON
    body: json.encode(data), // Convierte el mapa de datos a formato JSON
  );
  
  // Verifica si la respuesta tiene un código de estado diferente de 200
  if (response.statusCode != 200) {
    // Si la respuesta no es exitosa, lanza una excepción
    throw Exception('Error al enviar los datos');
  }
}