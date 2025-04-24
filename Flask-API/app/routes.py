from flask import Blueprint, jsonify, request
import mysql.connector  # Importa la biblioteca necesaria para conectarse a una base de datos MySQL
from mysql.connector import errorcode  # Importa el módulo de errores de MySQL
import bcrypt  # Importa la biblioteca para el hashing de contraseñas
from mtgsdk import Card  # Importa la biblioteca para interactuar con la API de cartas

# Crea un Blueprint para la API con un prefijo de URL '/api'
api = Blueprint('api', __name__, url_prefix='/api')

@api.route('/login', methods=['POST'])
def login():
    # Obtiene los datos JSON de la solicitud
    data = request.get_json()
    # Verifica que los datos contengan 'usuari' y 'contrasenya'
    if not data or 'usuari' not in data or 'contrasenya' not in data:
        return jsonify({'error': 'Falta el usuari o la contrasenya', 'status': 'error'}), 400
    
    username_or_email = data['usuari']
    password = data['contrasenya'].encode('utf-8')  # Convierte la contraseña a bytes para bcrypt
    
    try:
        cnx = databaseconnection()  # Establece la conexión a la base de datos
        if cnx.is_connected():
            with cnx.cursor(dictionary=True) as cursor:  # Usa un cursor que devuelve diccionarios
                # Consulta para buscar el usuario por nombre o correo
                cursor.execute("SELECT id, nom_usuari, correu, contrasenya FROM usuari WHERE nom_usuari = %s OR correu = %s", 
                              (username_or_email, username_or_email))
                user = cursor.fetchone()  # Obtiene el primer resultado
                
                if not user:
                    return jsonify({'error': 'No es pot trobar a cap usuari amb aquest nom o correu', 'status': 'error'}), 404
                
                # Verifica la contraseña hasheada
                if bcrypt.checkpw(password, user['contrasenya'].encode('utf-8')):
                    # Contraseña correcta - retorna éxito (sin datos sensibles)
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
            cnx.close()  # Cierra la conexión a la base de datos

@api.route('/register', methods=['POST'])
def register():
    # Obtiene los datos JSON de la solicitud
    data = request.get_json()
    # Verifica que los datos contengan 'nom_usuari', 'correu' y 'contrasenya'
    if not data or 'nom_usuari' not in data or 'correu' not in data or 'contrasenya' not in data:
        return jsonify({'error': 'Falta el nom d\'usuari, el correu o la contrasenya', 'status': 'error'}), 400
    
    usuari = data['nom_usuari']
    correu = data['correu']
    contrasenya = data['contrasenya']
    
    try:
        # Genera un salt y hash de la contraseña
        salt = bcrypt.gensalt()
        contrasenya_hash = bcrypt.hashpw(contrasenya.encode('utf-8'), salt)
        
        cnx = databaseconnection()  # Establece la conexión a la base de datos
        if cnx.is_connected():
            with cnx.cursor() as cursor:
                # Verifica si ya existe un usuario con ese nombre o correo
                cursor.execute("SELECT id FROM usuari WHERE correu = %s", (correu,))
                existing_user = cursor.fetchone()
                
                if existing_user:
                    return jsonify({
                        'error': 'Ja existeix un correu electrònic igual',
                        'status': 'error'
                    }), 409  # 409 Conflict es el código adecuado para recursos que ya existen
                
                cursor.execute("SELECT id FROM usuari WHERE nom_usuari = %s", (usuari,))
                existing_user = cursor.fetchone()
                
                if existing_user:
                    return jsonify({
                        'error': 'Ja existeix un usuari amb aquest nom',
                        'status': 'error'
                    }), 409  # 409 Conflict es el código adecuado para recursos que ya existen
                
                # Si no existe, procede con el registro
                cursor.execute("INSERT INTO usuari(correu, contrasenya, nom_usuari) VALUES (%s, %s, %s)", 
                             (correu, contrasenya_hash, usuari))
                cnx.commit()  # Confirma los cambios en la base de datos
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
            cnx.close()  # Cierra la conexión a la base de datos

@api.route('/carta/web', methods=['POST'])
def trobar_carta_web():
    # Obtiene los datos JSON de la solicitud
    data = request.get_json()
    # Verifica que los datos contengan 'nom'
    if not data or 'nom' not in data:
        return jsonify({'error': 'Falta el id de la carta', 'status': 'error'}), 400
    
    # Obtiene todas las cartas que coinciden con el nombre
    cards = Card.where(name=data['nom']).all()
    if not cards:
        return jsonify({'error': 'No es pot trobar cap carta amb aquest nom', 'status': 'error'}), 404
    else:
        return jsonify([
            {
                'id': card.multiverse_id,
                'nom': card.name,
                'imatge': card.image_url,
                'expansio': card.set
            } for card in cards if card.name == data['nom'] or card.name == data['nom'].lower()
        ]), 200  

@api.route('/coleccio', methods=['POST'])
def crear_coleccio():
    # Obtiene los datos JSON de la solicitud
    data = request.get_json()
    # Verifica que los datos contengan 'usr' y 'nom_col'
    if not data or 'usr' not in data or 'nom_col' not in data:
        return jsonify({'error': 'Falta el nom d\'usuari o el nom de la col·lecció', 'status': 'error'}), 400
    
    cnx = databaseconnection()  # Establece la conexión a la base de datos
    coleccio = data['nom_col']
    usr = data['usr']
    
    if cnx.is_connected():
        with cnx.cursor(dictionary=True) as cursor:
            # Verifica si el usuario existe
            cursor.execute("SELECT id FROM usuari WHERE nom_usuari= %s", (usr,))
            id_user = cursor.fetchone()
            
            if id_user:
                # Inserta la nueva colección en la base de datos
                cursor.execute("INSERT INTO coleccio(id_user,nombre) VALUES(%s,%s)", (id_user['id'], coleccio))
                cnx.commit()  # Confirma los cambios
                return jsonify({'message': 'Col·lecció creada correctament', 'status': 'success'}), 201
            else:
                return jsonify({'error': 'el ususari no existeix', 'status': 'error'}), 409

  

@api.route('/carta/coleccio', methods=['POST'])
def afegir_carta_coleccio():
    # Obtiene los datos JSON de la solicitud
    data = request.get_json()
    # Verifica que los datos contengan 'id_carta' y 'id_col'
    if not data or 'id_carta' not in data or 'id_col' not in data:
        return jsonify({'error': 'Falta el id de la carta o el nom d\'usuari', 'status': 'error'}), 400
    
    carta = data['id_carta']
    id_col = data['id_col']
    cnx = databaseconnection()  # Establece la conexión a la base de datos
    
    try:
        if cnx.is_connected():
            with cnx.cursor(dictionary=True) as cursor:
                # Verifica si la carta ya está en la colección
                cursor.execute("SELECT id_carta FROM cartes WHERE id_carta = %s", (carta,))
                existing_card = cursor.fetchone()
                if existing_card:
                    # Inserta la carta en la colección
                    cursor.execute("INSERT INTO coleccio_cartes(id_coleccio, id_carta) VALUES(%s,%s)", (id_col , carta))
                    cnx.commit()  # Confirma los cambios
                    return jsonify({'Success': 'Carta afegida correctament a la col·lecció', 'status': 'success'}), 200
                else:
                    return jsonify({'error': 'La carta no existeix', 'status': 'error'}), 404
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'error': 'Error', 'status': 'error'}), 500

@api.route('/coleccio/mostrar', methods=['POST', 'GET'])
def mostrar_coleccions():
    # Obtiene los datos JSON de la solicitud
    data = request.get_json()
    # Verifica que los datos contengan 'usr'
    if not data or 'usr' not in data:
        return jsonify({'error': 'Falta el nom d\'usuari', 'status': 'error'}), 400
    
    cnx = databaseconnection()  # Establece la conexión a la base de datos
    usr = data['usr']
    
    try:
        if cnx.is_connected():
            with cnx.cursor(dictionary=True) as cursor:
                # Busca el ID del usuario
                cursor.execute("SELECT id FROM usuari WHERE nom_usuari= %s", (usr,))
                id_user = cursor.fetchone()
                user_id = id_user['id']
                
                if user_id:
                    # Obtiene las colecciones del usuario
                    cursor.execute("SELECT nombre, id FROM coleccio WHERE id_user=%s", (user_id,))
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

@api.route('/carta/coleccio/mostrar', methods=['GET'])
def mostrar_coleccio():
    # Obtiene los datos JSON de la solicitud
    data = request.get_json()
    # Verifica que los datos contengan 'id_col'
    if not data or 'id_col' not in data:
        return jsonify({'error': 'Falta el id de la carta o el nom d\'usuari', 'status': 'error'}), 400
    
    id_col = data['id_col']
    cnx = databaseconnection()  # Establece la conexión a la base de datos
    
    if cnx.is_connected():
        with cnx.cursor(dictionary=True) as cursor:
            # Busca las cartas en la colección
            cursor.execute("SELECT id_carta FROM coleccio_cartes WHERE id_coleccio = %s", (id_col,))
            ids_cartes = cursor.fetchall()

            cartas_encontradas = []
            for id_carta in ids_cartes:
                # Accede al valor del ID
                multiverse_id = id_carta['id_carta'] if isinstance(id_carta, dict) else id_carta[0]
                
                # Busca la carta por su multiverse ID
                cards = Card.where(multiverseid=multiverse_id).all()
                
                # Añade todas las cartas encontradas
                for card in cards:
                    cartas_encontradas.append({
                        'nom': card.name,
                        'imatge': card.image_url,
                        'id_carta': card.multiverse_id  # Añadido ID para referencia
                    })

            if not cartas_encontradas:
                return jsonify({'error': 'No se encontraron cartas para esta colección'}), 404

            return jsonify(cartas_encontradas), 200

@api.route('/coleccio/eliminar', methods=['POST'])
def eliminar_coleccio():
    # Obtiene los datos JSON de la solicitud
    data = request.get_json()
    # Verifica que los datos contengan 'usr' y 'nom_col'
    if not data or 'usr' not in data:
        return jsonify({'error': 'Falta el nom d\'usuari o el nom de la col·lecció', 'status': 'error'}), 400
    
    cnx = databaseconnection()  # Establece la conexión a la base de datos
    usr = data['usr']
    id = data['id']
    
    if cnx.is_connected():
        with cnx.cursor(dictionary=True) as cursor:
            # Verifica si el usuario existe
            cursor.execute("SELECT id FROM usuari WHERE nom_usuari= %s", (usr,))
            id_user = cursor.fetchone()
            if id_user:
                # Elimina la colección de la base de datos
                cursor.execute("DELETE FROM coleccio WHERE id= %s", (id,))
                cnx.commit()  # Confirma los cambios
                return jsonify({'message': 'Col·lecció eliminada correctament', 'status': 'success'}), 200
            else:
                return jsonify({'error': 'el ususari no existeix', 'status': 'error'}), 409

def databaseconnection():  # Función para conectarse a la base de datos
    try:
        # Establece la conexión con la base de datos
        cnx = mysql.connector.connect(user='root', password='', database='la_trobada')
        return cnx  # Retorna la conexión establecida
    except mysql.connector.Error as err:  # Captura errores de conexión
        if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:  # Verifica si el error es de acceso denegado
            print("Incorrect user")
            cnx.close()  # Cierra la conexión
        elif err.errno == errorcode.ER_BAD_DB_ERROR:  # Verifica si el error es que la base de datos no existe
            print("database doesn't exist")
            cnx.close()  # Cierra la conexión
        else:
            print(err)  # Imprime cualquier otro error
            cnx.close()  # Cierra la conexión