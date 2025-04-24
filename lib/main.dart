// Importacions dels paquets necessaris
import 'package:flutter/material.dart';  // Biblioteca bàsica de Flutter
import 'routes.dart';  // Fitxer que conté les rutes de l'aplicació

// Funció principal que executa l'aplicació
void main() {
  runApp(MyApp());  // Inicialitza l'aplicació amb el widget MyApp
}

// Classe principal de l'aplicació que hereda de StatelessWidget
class MyApp extends StatelessWidget {
  const MyApp({super.key});  // Constructor amb key opcional

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'La trobada',  // Títol de l'aplicació
      initialRoute: '/',  // Ruta inicial (pantalla de login)
      routes: appRoutes,  // Mapa de rutes definit a routes.dart
    );
  }
}