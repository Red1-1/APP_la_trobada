# Importacions de Flask i extensions
from flask import Flask  # Framework principal
from flask_cors import CORS  # Per a gestió de CORS (Cross-Origin Resource Sharing)

# Creem la instància principal de Flask
app = Flask(__name__)  # __name__ identifica el mòdul actual

# Inicialitzem l'extensió CORS (sense associar-la a l'app encara)
cors = CORS()

# Funció factoria per crear i configurar l'aplicació
def create_app():
    """Configura i retorna una instància de l'aplicació Flask"""
    
    # Carreguem la configuració des d'un objecte Config
    app.config.from_object('app.config.Config')  # Importa config.py del paquet app
    
    # Inicialitzem extensions amb l'aplicació
    cors.init_app(app)  # Habilita CORS per a tots els dominis/rutes
    
    # Importem les rutes després de crear l'app per evitar imports circulars
    from app import routes  # routes.py dins del paquet app
    app.register_blueprint(routes.api)  # Registra el Blueprint de l'API
    
    # Clau secreta per sessions (en producció, usar variable d'entorn!)
    app.config['SECRET_KEY'] = 'nil_albert'  
    
    return app