from flask import Flask
from app.routes.routes import *
from app.routes.hrms_routes import *
from app.routes.cbs_routes import *

def create_app():
    app = Flask(__name__)
    app.config.from_object('app.config.Config')

    # Register routes
    app.register_blueprint(routes)
    app.register_blueprint(cbs_routes)
    app.register_blueprint(hrms_routes)


    return app
