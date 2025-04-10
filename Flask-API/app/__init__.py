from flask import Flask
from flask_cors import CORS

# Crear la instancia de Flask primero
app = Flask(__name__)

# Configurar extensiones
cors = CORS()

def create_app():
    # Configuración
    app.config.from_object('app.config.Config')
    

    cors.init_app(app)
    
    # Importar rutas después de crear app para evitar circular imports
    from app import routes
    app.register_blueprint(routes.api)
    app.config['SECRET_KEY'] = 'nil_albert'
    return app