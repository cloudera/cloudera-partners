from flask import Blueprint, jsonify
from app.models.cbs import *
from app.utils.logger import setup_logging

logger = setup_logging()

cbs_routes = Blueprint('cbs_routes', __name__)

@cbs_routes.route('/cbs', methods=['GET'])
def cbs_api_overview():
    api_endpoints = {
        "cbs_customers": "/cbs/customer",
        "cbs_feedback": "/cbs/feedback",
        "cbs_transactions": "/cbs/transaction",
        "/cbs/account": "/cbs/account",
        "/cbs/loan": "/cbs/loan"
    }
    return jsonify(api_endpoints)

@cbs_routes.route('/cbs/customer', methods=['GET'])
def generate_customer():
    customer = CBSCustomer()
    data = customer.to_dict()
    logger.info(f"Generated customer data: {data}")
    return jsonify(data)

@cbs_routes.route('/cbs/feedback', methods=['GET'])
def generate_feedback():
    feedback = CBSFeedback()
    data = feedback.to_dict()
    logger.info(f"Generated CBS feedback data: {data}")
    return jsonify(data)

@cbs_routes.route('/cbs/transaction', methods=['GET'])
def generate_cbs_transaction():
    transaction = CBSTransaction()
    data = transaction.to_dict()
    logger.info(f"Generated CBS transaction data: {data}")
    return jsonify(data)

@cbs_routes.route('/cbs/account', methods=['GET'])
def generate_account():
    account = CBSAccount()
    data = account.to_dict()
    logger.info(f"Generated CBS account data: {data}")
    return jsonify(data)

@cbs_routes.route('/cbs/loan', methods=['GET'])
def generate_cbs_loan():
    loan = CBSLoan()
    data = loan.to_dict()
    logger.info(f"Generated CBS loan data: {data}")
    return jsonify(data)
