from flask import Flask
from app.routes import api_bp

app = Flask(__name__)

# Register the blueprint
app.register_blueprint(api_bp, url_prefix='/api')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)  # Change port here

