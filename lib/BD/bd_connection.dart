import 'package:mysql1/mysql1.dart';

class DatabaseHelper {
  // Método para conectar (similar a tu función en Python)
  static Future<MySqlConnection> getConnection() async {
    try {
      final conn = await MySqlConnection.connect(
        ConnectionSettings(
          host: '10.100.0.78',  // o 'localhost'
          user: 'root',
          password: '',
          db: 'la_trobada',
          port: 3306,
        ),
      );
      print('Conexión exitosa');
      return conn;
    } on MySqlException catch (err) {
      // Manejo específico de errores
      if (err.errorNumber == 1045) {  // Acceso denegado
        print('Error: Usuario o contraseña incorrectos');
      } else if (err.errorNumber == 1049) {  // BD no existe
        print('Error: La base de datos no existe');
      } else {
        print('Error desconocido: ${err.message}');
      }
      throw Exception('Falló la conexión a la base de datos');
    }
  }

  // Cerrar conexión
  static Future<void> closeConnection(MySqlConnection? conn) async {
    if (conn != null) await conn.close();
  }
}