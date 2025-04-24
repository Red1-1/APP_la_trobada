import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    // Controladors pels camps del formulari
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    // Funció per registrar l'usuari
    Future<void> _registerUser() async {
      // Validació de camps buits
      if (usernameController.text.isEmpty || 
          emailController.text.isEmpty || 
          passwordController.text.isEmpty || 
          confirmPasswordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Si us plau, omple tots els camps')),
        );
        return;
      }

      // Validació de contrasenyes coincidents
      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Les contrasenyes no coincideixen')),
        );
        return;
      }

      // Validació bàsica d'email
      if (!emailController.text.contains('@')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Si us plau introdueix un email vàlid')),
        );
        return;
      }

      // URL de l'API Flask (ajusta segons la teva configuració)
      const String apiUrl = 'http://10.100.3.25:5000/api/register';
      
      try {
        // Crear el cos de la petició
        final Map<String, dynamic> requestBody = {
          'nom_usuari': usernameController.text,
          'correu': emailController.text,
          'contrasenya': passwordController.text,
        };

        // Fer la petició POST
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestBody),
        );

        // Processar la resposta
        if (response.statusCode == 201) { // 201 és comú per creació exitosa
          final responseData = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registre exitós: ${responseData['message']}')),
          );
          
          // Tornar al login després del registre exitós
          Navigator.pop(context);
        } else {
          // Error en el registre
          final errorData = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorData['message'] ?? 'Error en el registre')),
          );
        }
      } catch (e) {
        // Error de connexió
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de connexió: ${e.toString()}')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registre d\'Usuari'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Camp de nom d'usuari
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Nom d\'Usuari',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Camp d'email
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
              
              // Camp de contrasenya
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contrasenya',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              
              const SizedBox(height: 20),
              
              // Camp de confirmar contrasenya
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Repetir Contrasenya',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
              
              const SizedBox(height: 30),
              
              // Botó de registre
              ElevatedButton(
                onPressed: () async {
                  await _registerUser();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Registrar-se'),
              ),
              
              const SizedBox(height: 20),
              
              // Opció per tornar al login
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Ja tens compte? Inicia Sessió'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}