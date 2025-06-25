from flask import Flask
from app.routes.routes import *
from app.routes.campaign_routes import *
from app.routes.nps_routes import *
from app.routes.call_routes import *

def create_app():
    app = Flask(__name__)
    app.config.from_object('app.config.Config')

    # Register routes
    app.register_blueprint(routes)
    app.register_blueprint(campaign_routes)
    app.register_blueprint(nps_routes)
    app.register_blueprint(call_routes)


    return app
