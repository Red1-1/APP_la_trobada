from flask import Flask
from flask_cors import CORS
from flask_socketio import SocketIO  # Nuevo

app = Flask(__name__)
cors = CORS()
socketio = SocketIO()  # Nuevo

def create_app():
    app.config.from_object('app.config.Config')
    
    # Inicializar extensiones
    cors.init_app(app)
    socketio.init_app(app, cors_allowed_origins="*")  # Nuevo
    
    from app import routes
    app.register_blueprint(routes.api)
    
    app.config['SECRET_KEY'] = 'nil_albert'  
    return app