import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<dynamic>> fetchData() async {
  final response = await http.get(Uri.parse('http://10.100.0.78:5000/api/data'));
  
  if (response.statusCode == 200) {
    return json.decode(response.body)['data'];
  } else {
    throw Exception('Error al cargar los datos');
  }
}

Future<void> postData(Map<String, dynamic> data) async {
  final response = await http.post(
    Uri.parse('http://10.100.0.78:5000/api/data'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(data),
  );
  
  if (response.statusCode != 200) {
    throw Exception('Error al enviar los datos');
  }
}
