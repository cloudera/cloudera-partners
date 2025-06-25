from flask import Blueprint, jsonify
from app.data_generators import generate_branch_data, generate_revenue_data, generate_expense_data, generate_pnl_data, generate_cashflow_data
from app.history import HistoryStore

api_bp = Blueprint('api', __name__)

history_store = HistoryStore()

@api_bp.route('/branch', methods=['GET'])
def get_branch():
    data = generate_branch_data(history_store)
    return jsonify(data)

@api_bp.route('/revenue', methods=['GET'])
def get_revenue():
    data = generate_revenue_data(history_store)
    return jsonify(data)

@api_bp.route('/expense', methods=['GET'])
def get_expense():
    data = generate_expense_data(history_store)
    return jsonify(data)

@api_bp.route('/pnl', methods=['GET'])
def get_pnl():
    data = generate_pnl_data(history_store)
    return jsonify(data)

@api_bp.route('/cashflow', methods=['GET'])
def get_cashflow():
    data = generate_cashflow_data(history_store)
    return jsonify(data)

