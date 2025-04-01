import 'package:flutter/material.dart';
import './camara.dart';
import 'galeria.dart';
import 'reproductor.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => CameraPage(), // Página Cámara
  '/galeria': (context) => GaleriaPage(), // Página Galería
  '/reproductor': (context) => ReproductorPage(), // Página Reproductor
};