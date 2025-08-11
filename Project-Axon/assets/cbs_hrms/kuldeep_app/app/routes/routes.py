from flask import Blueprint, jsonify
from app.models.cbs import *
from app.utils.logger import setup_logging

logger = setup_logging()

routes = Blueprint('routes', __name__)

# --- Default Route and Error Handling ---

@routes.errorhandler(404)
def page_not_found(error):
    return jsonify({"error": "Page not found"}), 404

@routes.route('/', methods=['GET'])
def api_overview():
    """Provide a welcome message and links to all available tables."""
    welcome_message = "Welcome to the Banking API. Below are the available endpoints for various tables in CBS, and HRMS systems."
    api_endpoints = {
        "cbs": "/cbs",
        "hrms": "/hrms"
    }
    return jsonify(welcome_message, api_endpoints)