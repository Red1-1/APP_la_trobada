from flask import Blueprint, jsonify, request
import mysql.connector #imports the library that is needed to conect to a mysql database
from mysql.connector import errorcode  # Importamos mysql desde el módulo app
import bcrypt 
from mtgsdk import Card

api = Blueprint('api', __name__, url_prefix='/api')

@api.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    if not data or 'usuari' not in data or 'contrasenya' not in data:
        return jsonify({'error': 'Falta el usuari o la contrasenya', 'status': 'error'}), 400
    
    username_or_email = data['usuari']
    password = data['contrasenya'].encode('utf-8')  # Convertimos a bytes para bcrypt
    
    try:
        cnx = databaseconnection()
        if cnx.is_connected():
            with cnx.cursor(dictionary=True) as cursor:  # Usamos dictionary=True para acceder por nombres de columna
                # Query para buscar usuario por nombre o email
                cursor.execute("SELECT id, nom_usuari, correu, contrasenya FROM usuari WHERE nom_usuari = %s OR correu = %s", 
                              (username_or_email, username_or_email))
                user = cursor.fetchone()
                
                if not user:
                    return jsonify({'error': 'No es pot trobar a cap usuari amb aquest nom o correu', 'status': 'error'}), 404
                
                # Verificamos la contraseña hasheada
                if bcrypt.checkpw(password, user['contrasenya'].encode('utf-8')):
                    # Contraseña correcta - retornamos éxito (sin datos sensibles)
                    result = {
                        'status': 'success'
                    }
                    return jsonify(result)
                else:
                    return jsonify({'error': 'Contrasenya incorrecta', 'status': 'error'}), 401
    except mysql.connector.Error as err:
        print(f"Error: {err}")
        return jsonify({'error': 'Error de base de datos', 'status': 'error'}), 500
    except Exception as e:
        return jsonify({'error': str(e), 'status': 'error'}), 500
    finally:
        if 'cnx' in locals() and cnx.is_connected():
            cnx.close()
    

@api.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    if not data or 'nom_usuari' not in data or 'correu' not in data or 'contrasenya' not in data:
        return jsonify({'error': 'Falta el nom d\'usuari, el correu o la contrasenya', 'status': 'error'}), 400
    
    usuari = data['nom_usuari']
    correu = data['correu']
    contrasenya = data['contrasenya']
    
    try:
        # Generar salt y hash de la contraseña
        salt = bcrypt.gensalt()
        contrasenya_hash = bcrypt.hashpw(contrasenya.encode('utf-8'), salt)
        
        cnx = databaseconnection()
        if cnx.is_connected():
            with cnx.cursor() as cursor:
                # Primero verificamos si ya existe un usuario con ese nombre o correo
                cursor.execute("SELECT id FROM usuari WHERE correu = %s", 
                             (correu,))
                existing_user = cursor.fetchone()
                
                if existing_user:
                    return jsonify({
                        'error': 'Ja existeix un correu electrònic igual',
                        'status': 'error'
                    }), 409  # 409 Conflict es el código adecuado para recursos que ya existen
                
                cursor.execute("SELECT id FROM usuari WHERE nom_usuari = %s", 
                             (usuari, ))
                existing_user = cursor.fetchone()
                
                if existing_user:
                    return jsonify({
                        'error': 'Ja existeix un usuari amb aquest nom',
                        'status': 'error'
                    }), 409  # 409 Conflict es el código adecuado para recursos que ya existen
                
                # Si no existe, procedemos con el registro
                cursor.execute("INSERT INTO usuari(correu, contrasenya, nom_usuari) VALUES (%s, %s, %s)", 
                             (correu, contrasenya_hash, usuari))
                cnx.commit()
                return jsonify({'message': 'Usuari creat correctament', 'status': 'success'}), 201
    except mysql.connector.Error as err:
        if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
            return jsonify({'error': 'Incorrect user', 'status': 'error'}), 403
        elif err.errno == errorcode.ER_BAD_DB_ERROR:
            return jsonify({'error': 'Database does not exist', 'status': 'error'}), 404
        else:
            return jsonify({'error': str(err), 'status': 'error'}), 500
    finally:
        if 'cnx' in locals() and cnx.is_connected():
            cnx.close()


@api.route('/coleccio', methods=['POST'])
def crear_coleccio():
    data = request.get_json()
    if not data or 'usr' not in data or 'nom_col' not in data:
        return jsonify({'error': 'Falta el nom d\'usuari o el nom de la col·lecció', 'status': 'error'}), 400
    cnx = databaseconnection()
    coleccio = data['nom_col']
    usr = data['usr']
    if cnx.is_connected():
        with cnx.cursor(dictionary=True) as cursor:
            # Verificamos si la colección ya existe
            cursor.execute("SELECT id FROM usuari WHERE nom_usuari= %s", (usr,))
            id_user = cursor.fetchone()
            
            if id_user:
                cursor.execute("INSERT INTO coleccio(id_user,nombre) VALUES(%s,%s)",(id_user['id'], coleccio))
                cnx.commit()
                return jsonify({'message': 'Col·lecció creada correctament', 'status': 'success'}), 201
            else:
                return jsonify({'error': 'el ususari no existeix', 'status': 'error'}), 409
          


@api.route('/carta/web', methods=['POST'])
def trobar_carta_web():
    data = request.get_json()
    if not data or 'nom' not in data:
        return jsonify({'error': 'Falta el id de la carta', 'status': 'error'}), 400
    
    cards = Card.where(name=data['nom']).all()  # Obtenemos todas las cartas que coinciden con el nombre
    if not cards:
        return jsonify({'error': 'No es pot trobar cap carta amb aquest nom', 'status': 'error'}), 404
    else:
        return jsonify([
            {
                'id': card.id,
                'nom': card.name,
                'imatge': card.image_url,
                'expansio': card.set
            } for card in cards if card.name == data['nom'] or card.name == data['nom'].lower()
        ]), 200    

@api.route('/carta/coleccio', methods=['POST'])
def afegir_carta_coleccio():
    data = request.get_json()
    if not data or 'id_carta' not in data and 'usr' not in data and 'nom_col':
        return jsonify({'error': 'Falta el id de la carta o el nom d\'usuari', 'status': 'error'}), 400
    carta = data['id_carta']
    cnx = databaseconnection()
    if cnx.is_connected():
        with cnx.cursor(dictionary=True) as cursor:
            # Verificamos si la carta ya está en la colección
            cursor.execute("SELECT id_carta FROM cartes WHERE id_carta = %s", (data['id_carta'],))
            existing_card = cursor.fetchone()
            
            if existing_card:
                cursor.execute("SELECT id FROM usuari WHERE nom_usuari= %s", (data['usr'],))
                cnx.commit()
                return jsonify({'error': 'La carta ja existeix a la col·lecció', 'status': 'error'}), 409
            
@api.route('/coleccio/mostrar', methods=['POST', 'GET'])
def mostrar_coleccions():
    data = request.get_json()
    if not data or 'usr' not in data:
        return jsonify({'error': 'Falta el nom d\'usuari', 'status': 'error'}), 400
    cnx = databaseconnection()
    usr = data['usr']
    try:
        if cnx.is_connected():
            with cnx.cursor(dictionary=True) as cursor:
                cursor.execute("SELECT id FROM usuari WHERE nom_usuari= %s", (usr,))
                id_user = cursor.fetchone()
                user_id = id_user['id']
                if user_id:
                    cursor.execute("SELECT nombre FROM coleccio WHERE id_user=%s",(user_id,))
                    coleccions = cursor.fetchall()
                    
                    if coleccions:
                        return jsonify(coleccions), 200
                    else:
                        return jsonify({'error': 'No hi ha col·leccions per a aquest usuari', 'status': 'error'}), 404
                else:
                    return jsonify({'error': 'el ususari no existeix', 'status': 'error'}), 409
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'error': 'Error de base de dades', 'status': 'error'}), 500
                    
@api.route('/carta/coleccio/mostrar', methods=['POST'])
def mostrar_coleccio():
    data = request.get_json()
    if not data or 'nom_col' not in data and 'usr' not in data:
        return jsonify({'error': 'Falta el id de la carta o el nom d\'usuari', 'status': 'error'}), 400
    cnx = databaseconnection()
    if cnx.is_connected():
        with cnx.cursor(dictionary=True) as cursor:
            # Verificamos si la carta ya está en la colección
            cursor.execute("SELECT * FROM cartes WHERE id_carta = %s", (data['id_carta'],))
            existing_card = cursor.fetchone()
            
            if existing_card:
                return jsonify({'error': 'La carta ja existeix a la col·lecció', 'status': 'error'}), 409
      
            
@api.route('/coleccio/eliminar', methods=['POST'])
def eliminar_coleccio():
    try:
        data = request.get_json()
        if not data or 'usr' not in data or 'nom_col' not in data:
            return jsonify({'status': 'error', 'message': 'Parámetros faltantes'}), 400

        cnx = databaseconnection()
        if not cnx.is_connected():
            return jsonify({'status': 'error', 'message': 'Error de conexión a BD'}), 500

        with cnx.cursor(dictionary=True) as cursor:
            # 1. Obtener ID de usuario (consumiendo todos los resultados)
            cursor.execute("SELECT id FROM usuari WHERE nom_usuari = %s", (data['usr'],))
            usuario = cursor.fetchone()  # Esto consume el resultado
            if not usuario:
                return jsonify({'status': 'error', 'message': 'Usuario no existe'}), 404

            # 2. Buscar colección (consumiendo todos los resultados)
            cursor.execute(
                "SELECT id FROM coleccio WHERE id_user = %s AND nombre = %s",
                (usuario['id'], data['nom_col'])
            )
            coleccion = cursor.fetchone()  # Esto consume el resultado
            
            if not coleccion:
                return jsonify({'status': 'error', 'message': 'Colección no encontrada'}), 404

            # 3. Eliminar por ID exacto
            cursor.execute("DELETE FROM coleccio WHERE id = %s", (coleccion['id'],))
            
            if cursor.rowcount == 1:
                cnx.commit()
                return jsonify({'status': 'success', 'message': 'Colección eliminada'}), 200
            else:
                cnx.rollback()
                return jsonify({'status': 'error', 'message': 'No se pudo eliminar'}), 500

    except Exception as e:
        cnx.rollback() if 'cnx' in locals() else None
        return jsonify({'status': 'error', 'message': f'Error del servidor: {str(e)}'}), 500
    finally:
        cnx.close() if 'cnx' in locals() else None
            
def databaseconnection(): #function to connect to the database
    try:
        cnx = mysql.connector.connect(user='root',password='', database='la_trobada') #this line is used to stablish connection with the database, user is the user of the db, password is the password for the user and database is the database that we want the app to connect
        return cnx #it returns the conexion stablished 
    except mysql.connector.Error as err: #it catches the error if any problem happens
        if err.errno == errorcode.ER_ACCESS_DENIED_ERROR: #compares if the error is Acces denied
            print("Incorrect user") 
            cnx.close() #closes the conncetion
        elif err.errno == errorcode.ER_BAD_DB_ERROR: #compares if the error is database doesn't exist
            print("database doesn't exist")
            cnx.close() #closes the conncetion
        else:
            print(err)  #if there is other error rather than the 2 above it will directly print the error
            cnx.close() #closes the conncetion
