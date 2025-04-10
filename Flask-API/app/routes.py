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
    print("Creando colección...")

@api.route('/carta/web', methods=['POST'])
def trobar_carta_web():
    data = request.get_json()
    if not data or 'nom' not in data:
        return jsonify({'error': 'Falta el nombre de la carta', 'status': 'error'}), 400
    
    # Obtenemos todas las cartas que coinciden exactamente con el nombre
    cards = Card.where(name=f'!"{data["nom"]}"').all()  # ¡Nota el uso de comillas y el signo de exclamación!
    
    if not cards:
        return jsonify({'error': 'No se puede encontrar ninguna carta con este nombre exacto', 'status': 'error'}), 404
    
    # Filtramos adicionalmente por si acaso (doble verificación)
    exact_match_cards = [card for card in cards if card.name.lower() == data['nom'].lower()]
    
    if not exact_match_cards:
        return jsonify({'error': 'No hay coincidencia exacta para este nombre', 'status': 'error'}), 404
    
    return jsonify([
        {
            'id': card.id,
            'nom': card.name,
            'imatge': card.image_url,
            'expansio': card.set
        } for card in exact_match_cards
    ]), 200
    
    
@api.route('/carta/coleccio', methods=['POST'])
def afegir_carta_coleccio():
    data = request.get_json()
    if not data or 'id_carta' not in data or 'nom_col' not in data:
        return jsonify({'error': 'Falta el id de la carta o el nom d\'usuari', 'status': 'error'}), 400
    
    

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
