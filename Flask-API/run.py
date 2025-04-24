# Importa la funció 'create_app' del mòdul 'app' (normalment de app.py)
from app import create_app
# Crea la instància de l'aplicació Flask
app = create_app()
# Si s'executa directament (no importat), inicia el servidor
if __name__ == '__main__':
    app.run(debug=True, # Mode desenvolupament (errors detallats + recàrrega automàtica)
            host='0.0.0.0', # Permet connexions des de qualsevol dispositiu a la xarxa
            port=5000 # Port per defecte de Flask
            )
    