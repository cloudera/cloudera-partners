from flask import Blueprint, jsonify
from app.models.nps_responses import *

nps_routes = Blueprint('nps_routes', __name__)

# Endpoint to generate all NPS Responses data
@nps_routes.route('/nps-responses', methods=['GET'])
def nps_responses():
    responses = generate_nps_responses()
    return jsonify(responses)
