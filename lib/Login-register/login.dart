import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'register.dart'; // Importa la pantalla de registre
import '../coleccio/coleccio.dart'; // Importa la pantalla de la col·lecció

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    // Controladors pels camps del formulari
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    // Funció per fer login
    Future<void> _loginUser() async {
      // Validació de camps buits
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Si us plau, omple tots els camps')),
        );
        return;
      }

      // URL de l'API de login
      const String apiUrl = 'http://10.100.3.25:5000/api/login';
      
      try {
        // Preparar dades per enviar
        final Map<String, dynamic> requestBody = {
          'usuari': emailController.text,
          'contrasenya': passwordController.text,
        };

        // Fer petició POST
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestBody),
        );

        // Processar resposta
        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Benvingut ${responseData['status']}')),
          );

          // Navegar a la pantalla principal
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Coleccio()),
          );
          
        } else {
          // Mostrar error
          final errorData = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorData['message'] ?? 'Error en el login')),
          );
        }
      } catch (e) {
        print('Error: $e'); // Per depuració
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
            // Camp per l'email
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
            
            // Camp per la contrasenya
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
            
            // Botó per fer login
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
            
            // Enllaç per anar al registre
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