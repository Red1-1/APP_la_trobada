import 'package:mysql1/mysql1.dart';

Future<void> main() async {
  final settings = ConnectionSettings(
    host: '10.100.0.78', // Dirección IP de tu servidor MySQL en XAMPP
    port: 3306, // Puerto de MySQL
    user: 'root', // Usuario predeterminado de XAMPP
    password: '', // XAMPP usualmente no tiene contraseña por defecto
    db: 'tu_base_de_datos', // Nombre de la base de datos en phpMyAdmin
  );

  try {
    final conn = await MySqlConnection.connect(settings);
    print('Conexión exitosa a MySQL');

    // Ejecutar una consulta de prueba
    var results = await conn.query('SELECT * FROM tu_tabla');
    for (var row in results) {
      print('Fila: ${row.fields}');
    }

    await conn.close();
  } catch (e) {
    print('Error de conexión: $e');
  }
}