import 'package:flutter/material.dart';
import './Xat/xat.dart';
import 'Foro/foro.dart';
import 'Scanner/scanner.dart';
import 'usuari/usuari.dart';
import 'coleccio/coleccio.dart';
import 'Login-register/login.dart';
import 'Login-register/register.dart';


final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => Login(),
  '/register': (context) => Register(), // Página de registro
  '/foro': (context) => Foro(), // Página Cámara
  '/usuari': (context) => Usuari(), // Página Galería
  '/coleccio': (context) => Coleccio(),
  '/Scanner':(context) => Scanner(),
  '/Xat':(context) => Xat(),// Página Reproductor
};