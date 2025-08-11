#API Endpoints
from flask import Blueprint, jsonify
from app.branch_mgmt import generate_branch, generate_daily_operation, generate_inventory, generate_asset

banking_routes = Blueprint('banking_routes', __name__)

@banking_routes.route('/generate_branch', methods=['GET'])
def generate_branch_route():
    return jsonify(generate_branch())

@banking_routes.route('/generate_daily_operation', methods=['GET'])
def generate_daily_operation_route():
    return jsonify(generate_daily_operation())

@banking_routes.route('/generate_inventory', methods=['GET'])
def generate_inventory_route():
    return jsonify(generate_inventory())

@banking_routes.route('/generate_asset', methods=['GET'])
def generate_asset_route():
    return jsonify(generate_asset())

