import logging
from flask import Flask, jsonify
from faker import Faker
import random

# Initialize Flask app and Faker
app = Flask(__name__)
fake = Faker()

# --- Set up logging ---
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)


# @app.route('/crm/customer', methods=['GET'])
# def generate_customer():
#     num_records = int(request.args.get('num', 1))
#     customers = [CRMCustomer().to_dict() for _ in range(num_records)]
#     logger.info(f"Generated {num_records} customer records.")
#     return jsonify(customers)

# @app.route('/erp/account', methods=['GET'])
# def generate_account():
#     num_records = int(request.args.get('num', 1))
#     accounts = [ERPAccount().to_dict() for _ in range(num_records)]
#     logger.info(f"Generated {num_records} account records.")
#     return jsonify(accounts)

# # Dummy Data Generator
# def generate_dummy_data(num_customers=5, num_interactions=10, num_sales=5, num_products=3, num_activities=5):
#     customers = [Customer(customer_id=i) for i in range(1, num_customers + 1)]
#     interactions = [Interaction(interaction_id=i, customer_id=random.randint(1, num_customers)) for i in range(1, num_interactions + 1)]
#     sales = [Sale(sale_id=i, customer_id=random.randint(1, num_customers)) for i in range(1, num_sales + 1)]
#     products = [Product(product_id=i) for i in range(1, num_products + 1)]
#     activities = [Activity(activity_id=i, customer_id=random.randint(1, num_customers)) for i in range(1, num_activities + 1)]
#
#     return {
#         'customers': [customer.to_dict() for customer in customers],
#         'interactions': [interaction.to_dict() for interaction in interactions],
#         'sales': [sale.to_dict() for sale in sales],
#         'products': [product.to_dict() for product in products],
#         'activities': [activity.to_dict() for activity in activities]
#     }
#
# @app.route('/generate_data', methods=['GET'])
# def generate_data():
#     data = generate_dummy_data()
#     return jsonify(data)

# --- Run Flask App ---
if __name__ == "__main__":
    logger.info("Starting Flask application...")
    app.run(debug=True, host='0.0.0.0', port=8084)


# hrms-> performance, attendance, time tracking, employee
#  cbs-> feedback, loan, transaction, account, customer