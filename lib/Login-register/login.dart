import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Añadido
import 'register.dart';
import '../coleccio/coleccio.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    // Función para guardar el usuario en SharedPreferences
    Future<void> _saveUserData(String username) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);
      // Puedes guardar más datos si necesitas:
      // await prefs.setString('email', email);
      // await prefs.setBool('isLogged', true);
    }

    Future<void> _loginUser() async {
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Si us plau, omple tots els camps')),
        );
        return;
      }

      const String apiUrl = 'http://10.100.3.25:5000/api/login';
      
      try {
        final Map<String, dynamic> requestBody = {
          'usuari': emailController.text,
          'contrasenya': passwordController.text,
        };

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestBody),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          
          // Guardar el nombre de usuario
          await _saveUserData(emailController.text); 

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Benvingut ${responseData['status']}')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Coleccio(),
              // Si Coleccio necesita el usuario, puedes pasarlo como parámetro:
              // builder: (context) => Coleccio(username: emailController.text),
            ),
          );
          
        } else {
          final errorData = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorData['message'] ?? 'Error en el login')),
          );
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de connexió: ${e.toString()}')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inici de Sessió'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Correu Electrònic',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            
            const SizedBox(height: 20),
            
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Contrasenya',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            
            const SizedBox(height: 30),
            
            ElevatedButton(
              onPressed: () async {
                await _loginUser();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Iniciar Sessió'),
            ),
            
            const SizedBox(height: 20),
            
            TextButton(
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const Register()),
                );
              },
              child: const Text('No tens compte? Registra\'t'),
            ),
          ],
        ),
      ),
    );
  }
}