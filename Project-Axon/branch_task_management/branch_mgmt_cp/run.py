from flask import Flask
from app.route import banking_routes  # Ensure app is a package

app = Flask(__name__)

# Register the routes
app.register_blueprint(banking_routes)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5003)

