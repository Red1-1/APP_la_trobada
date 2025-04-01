from app import app, mysql
from flask import jsonify, request

@app.route('/api/data', methods=['GET'])
def get_data():
    try:
        cur = mysql.connection.cursor()
        cur.execute("SELECT * FROM Usuari")
        data = cur.fetchall()
        cur.close()
        return jsonify({'data': data, 'status': 'success'})
    except Exception as e:
        return jsonify({'error': str(e), 'status': 'error'}), 500

@app.route('/api/data', methods=['POST'])
def add_data():
    try:
        data = request.get_json()
        cur = mysql.connection.cursor()
        cur.execute("INSERT INTO tu_tabla (campo1, campo2) VALUES (%s, %s)", 
                   (data['campo1'], data['campo2']))
        mysql.connection.commit()
        cur.close()
        return jsonify({'message': 'Datos agregados', 'status': 'success'})
    except Exception as e:
        return jsonify({'error': str(e), 'status': 'error'}), 500

# Añade más endpoints según necesites (PUT, DELETE, etc.)