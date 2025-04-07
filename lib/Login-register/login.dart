import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'register.dart'; // Asegúrate de que esta ruta es correcta

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    // Función para realizar el login
    Future<void> _loginUser() async {
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, complete todos los campos')),
        );
        return;
      }

      // URL de tu API Flask (ajusta según tu configuración)
      const String apiUrl = 'http://10.100.0.78:5000/api/login';
      
      try {
        // Crear el cuerpo de la petición
        final Map<String, dynamic> requestBody = {
          'usuari': emailController.text,
          'contrasenya': passwordController.text,
        };

        // Realizar la petición POST
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestBody),
        );

        // Procesar la respuesta
        if (response.statusCode == 200) {
          // Login exitoso
          final responseData = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bienvenido ${responseData['status']}')),
          );
          
          // Navegar a otra pantalla después del login exitoso
          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
        } else {
          // Error en el login
          final errorData = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorData['message'] ?? 'Error en el login')),
          );
        }
      } catch (e) {
        // Error de conexión
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de conexión: ${e.toString()}')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio de Sesión'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Correo Electrónico',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            
            const SizedBox(height: 20),
            
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
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
              child: const Text('Iniciar Sesión'),
            ),
            
            const SizedBox(height: 20),
            
            TextButton(
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const Register()),
                );
              },
              child: const Text('¿No tienes cuenta? Regístrate'),
            ),
          ],
        ),
      ),
    );
  }
}