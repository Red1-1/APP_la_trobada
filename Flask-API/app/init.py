from flask import Flask
from flask_mysqldb import MySQL
from flask_cors import CORS
from app import routes


app = Flask(__name__)
app.config.from_object('app.config.Config')

mysql = MySQL(app)
CORS(app)  # Esto permitirá peticiones desde tu app Android y webapp
