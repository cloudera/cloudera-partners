from flask import Blueprint, jsonify
from app.models.call_center import *

call_routes = Blueprint('call_routes', __name__)

# Endpoint for CallCenterInteraction
@call_routes.route('/callcenter', methods=['GET'])
def call_center_interaction():
    call_center_interactions = generate_call_center_interaction()  # Generate dummy CallCenterInteraction data
    return jsonify(call_center_interactions)

# Endpoint for Customer Complaints
@call_routes.route('/customer-complaints', methods=['GET'])
def customer_complaints():
    complaints = generate_customer_complaint()  # Generate dummy CustomerComplaint data
    return jsonify(complaints)
