import 'package:flutter/material.dart';

class Usuari extends StatelessWidget {
  const Usuari({super.key});


    @override
  Widget build(BuildContext context) {
    // Controladores para los campos de texto
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio de Sesión'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
              obscureText: true, // Oculta el texto para contraseñas
            ),
            
            const SizedBox(height: 30),
            
            // Botón de login
            ElevatedButton(
              onPressed: () {
                // Validación simple
                if (emailController.text.isEmpty || passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, complete todos los campos')),
                  );
                } else {
                  // Aquí iría la lógica para autenticar al usuario
                  // Por ahora solo mostramos un mensaje
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Bienvenido ${emailController.text}')),
                  );
                  
                  // Navegar a otra pantalla después del login exitoso
                  // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Iniciar Sesión'),
            ),
            
            const SizedBox(height: 20),
            
            // Opción para registrarse
            TextButton(
              onPressed: () {
                // Navegar a pantalla de registro
                // Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
              },
              child: const Text('¿No tienes cuenta? Regístrate'),
            ),
          ],
        ),
      ),
    );
  }
}