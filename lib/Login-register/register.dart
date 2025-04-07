import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    // Función para realizar el registro
    Future<void> _registerUser() async {
      // Validación de campos vacíos
      if (usernameController.text.isEmpty || 
          emailController.text.isEmpty || 
          passwordController.text.isEmpty || 
          confirmPasswordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, complete todos los campos')),
        );
        return;
      }

      // Validación de contraseñas coincidentes
      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Las contraseñas no coinciden')),
        );
        return;
      }

      // Validación básica de email
      if (!emailController.text.contains('@')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor ingrese un email válido')),
        );
        return;
      }

      // URL de tu API Flask (ajusta según tu configuración)
      const String apiUrl = 'http://10.100.0.78:5000/api/register';
      
      try {
        // Crear el cuerpo de la petición
        final Map<String, dynamic> requestBody = {
          'nom_usuari': usernameController.text,
          'correu': emailController.text,
          'contrasenya': passwordController.text,
        };

        // Realizar la petición POST
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestBody),
        );

        // Procesar la respuesta
        if (response.statusCode == 201) { // 201 es común para creación exitosa
          final responseData = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registro exitoso: ${responseData['message']}')),
          );
          
          // Navegar de vuelta al login después del registro exitoso
          Navigator.pop(context);
        } else {
          // Error en el registro
          final errorData = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorData['message'] ?? 'Error en el registro')),
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
        title: const Text('Registro de Usuario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Campo de nombre de usuario
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de Usuario',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Campo de email
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
              
              // Campo de contraseña
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              
              const SizedBox(height: 20),
              
              // Campo de confirmar contraseña
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Repetir Contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
              
              const SizedBox(height: 30),
              
              // Botón de registro
              ElevatedButton(
                onPressed: () async {
                  await _registerUser();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Registrarse'),
              ),
              
              const SizedBox(height: 20),
              
              // Opción para volver al login
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('¿Ya tienes cuenta? Inicia Sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}