// Importacions de paquets i fitxers necessaris
import 'package:flutter/material.dart';  // Biblioteca principal de Flutter
import './Xat/xat.dart';                 // Pantalla del xat
import 'Foro/foro.dart';                 // Pantalla del fòrum
import 'Scanner/scanner.dart';           // Pantalla de l'scanner
import 'usuari/usuari.dart';             // Pantalla de l'usuari
import 'coleccio/coleccio.dart';         // Pantalla de la col·lecció
import 'Login-register/login.dart';      // Pantalla d'inici de sessió
import 'Login-register/register.dart';   // Pantalla de registre
import 'eventos/event.dart';         // Pantalla d'esdeveniments
// Mapa que defineix les rutes de l'aplicació
final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => Login(),         // Ruta inicial (pantalla de login)
  '/register': (context) => Register(), // Pantalla de registre
  '/foro': (context) => Foro(),      // Pantalla del fòrum
  '/usuari': (context) => Usuari(),  // Pantalla del perfil d'usuari
  '/coleccio': (context) => Coleccio(), // Pantalla de la col·lecció
  '/Scanner': (context) => Scanner(), // Pantalla de l'scanner
  '/Xat': (context) => Xat(),
  '/Event': (context) => EventScreen(),       // Pantalla del xat
};