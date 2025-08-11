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

# --- CRM Tables ---

# 1. crm_customers
class CRMCustomer:
    def __init__(self):
        self.customer_id = fake.random_int(min=1, max=99999)
        self.first_name = fake.first_name()
        self.last_name = fake.last_name()
        self.email = fake.email()
        self.phone = fake.phone_number()
        self.dob = fake.date_of_birth()
        self.address = fake.address()
        self.city = fake.city()
        self.state = fake.state()
        self.postal_code = fake.zipcode()
        self.country = fake.country()
        self.gender = random.choice(['Male', 'Female', 'Other'])  # Added Gender
        self.kyc_status = random.choice(['Verified', 'Pending', 'Rejected'])  # Added KYCStatus
        self.customer_type = random.choice(['Individual', 'Corporate'])  # Added CustomerType
        self.relationship_manager_id = fake.random_int(min=1, max=1000)  # Added RelationshipManagerID
        self.status = random.choice(['Active', 'Inactive', 'Lead', 'Prospect'])
        self.source = random.choice(['Website', 'Referral', 'Campaign', 'Social Media'])
        self.created_at = fake.date_this_decade()
        self.updated_at = fake.date_this_year()

    def to_dict(self) -> dict:
        return {
            'customer_id': self.customer_id,
            'first_name': self.first_name,
            'last_name': self.last_name,
            'gender': self.gender,
            'email': self.email,
            'phone': self.phone,
            'dob': str(self.dob),
            'address': self.address,
            'city': self.city,
            'state': self.state,
            'postal_code': self.postal_code,
            'country': self.country,
            'status': self.status,
            'source': self.source,
            'created_at': str(self.created_at),
            'updated_at': str(self.updated_at),
            'kyc_status': self.kyc_status,
            'customer_type': self.customer_type,
            'relationship_manager_id': self.relationship_manager_id
        }

# --- ERP Tables ---

# 9. erp_accounts
class ERPAccount:
    def __init__(self):
        self.account_number = fake.unique.random_int(min=100000000, max=999999999)  # Added AccountNumber
        self.customer_id = fake.random_int(min=1, max=99999)
        self.account_type = random.choice(['Checking', 'Savings', 'Loan', 'Credit'])
        self.current_balance = round(random.uniform(500, 50000), 2)
        self.account_status = random.choice(['Active', 'Dormant', 'Closed'])
        self.opening_date = fake.date_this_decade()
        self.branch_code = fake.random_int(min=1000, max=9999)  # Added BranchCode
        self.currency_type = random.choice(['USD', 'EUR', 'INR', 'GBP'])  # Added CurrencyType
        self.interest_rate = round(random.uniform(0.5, 5.0), 2)  # Added InterestRate
        self.last_transaction_date = fake.date_this_month()  # Added LastTransactionDate

    def to_dict(self) -> dict:
        return {
            'account_number': self.account_number,
            'customer_id': self.customer_id,
            'account_type': self.account_type,
            'current_balance': self.current_balance,
            'opening_date': str(self.opening_date),
            'branch_code': self.branch_code,
            'currency_type': self.currency_type,
            'account_status': self.account_status,
            'interest_rate': self.interest_rate,
            'last_transaction_date': str(self.last_transaction_date)
        }

# --- HRMS Tables ---

# 18. hrms_employees
class HRMSEmployee:
    def __init__(self):
        self.employee_id = fake.random_int(min=1, max=9999)
        self.first_name = fake.first_name()
        self.last_name = fake.last_name()
        self.email = fake.email()
        self.phone = fake.phone_number()
        self.department = random.choice(['Sales', 'Operations', 'IT', 'Finance', 'HR'])
        self.position = random.choice(['Manager', 'Associate', 'Director', 'Executive', 'Teller', 'Customer Service'])
        self.hire_date = fake.date_this_decade()
        self.salary = round(random.uniform(25000, 120000), 2)
        self.status = random.choice(['Active', 'Inactive'])
        self.branch_id = fake.random_int(min=1000, max=9999)

    def to_dict(self) -> dict:
        return {
            'employee_id': self.employee_id,
            'first_name': self.first_name,
            'last_name': self.last_name,
            'email': self.email,
            'phone': self.phone,
            'department': self.department,
            'position': self.position,
            'hire_date': str(self.hire_date),
            'salary': self.salary,
            'status': self.status,
            'branch_id': self.branch_id,
        }

# 19. hrms_attendance
class HRMSAttendance:
    def __init__(self):
        self.attendance_id = fake.random_int(min=1000, max=9999)
        self.employee_id = fake.random_int(min=1, max=9999)
        self.date = fake.date_this_month()
        self.status = random.choice(['Present', 'Absent'])

    def to_dict(self) -> dict:
        return {
            'attendance_id': self.attendance_id,
            'employee_id': self.employee_id,
            'date': str(self.date),
            'status': self.status
        }

# --- Routes ---
@app.route('/crm/customer', methods=['GET'])
def generate_customer():
    customer = CRMCustomer()
    data = customer.to_dict()
    logger.info(f"Generated customer data: {data}")
    return jsonify(data)

# @app.route('/crm/customer', methods=['GET'])
# def generate_customer():
#     num_records = int(request.args.get('num', 1))
#     customers = [CRMCustomer().to_dict() for _ in range(num_records)]
#     logger.info(f"Generated {num_records} customer records.")
#     return jsonify(customers)

@app.route('/erp/account', methods=['GET'])
def generate_account():
    account = ERPAccount()
    data = account.to_dict()
    logger.info(f"Generated ERP account data: {data}")
    return jsonify(data)

# @app.route('/erp/account', methods=['GET'])
# def generate_account():
#     num_records = int(request.args.get('num', 1))
#     accounts = [ERPAccount().to_dict() for _ in range(num_records)]
#     logger.info(f"Generated {num_records} account records.")
#     return jsonify(accounts)

@app.route('/hrm/employee', methods=['GET'])
def generate_employee():
    employee = HRMSEmployee()
    data = employee.to_dict()
    logger.info(f"Generated HRMS employee data: {data}")
    return jsonify(data)

@app.route('/hrm/attendance', methods=['GET'])
def generate_attendance():
    attendance = HRMSAttendance()
    data = attendance.to_dict()
    logger.info(f"Generated HRMS attendance data: {data}")
    return jsonify(data)

# --- Default Route and Error Handling ---

@app.errorhandler(404)
def page_not_found(error):
    return jsonify({"error": "Page not found"}), 404

@app.route('/', methods=['GET'])
def api_overview():
    """Provide a welcome message and links to all available tables."""
    welcome_message = "Welcome to the Banking API. Below are the available endpoints for various tables in CRM, ERP, and HRMS systems."
    return jsonify(welcome_message)

@app.route('/crm', methods=['GET'])
def crm_api_overview():
    api_endpoints = {
            "crm_customers": "/crm/customers",
            "crm_interactions": "/crm/interactions",
            "crm_support_tickets": "/crm/support_tickets",
            "crm_opportunities": "/crm/opportunities",
            "crm_campaigns": "/crm/campaigns",
            "crm_customer_campaigns": "/crm/customer_campaigns",
            "crm_feedback": "/crm/feedback",
            "crm_transactions": "/crm/transactions"
        }

    return jsonify(api_endpoints)

@app.route('/hrm', methods=['GET'])
def hrm_api_overview():
    api_endpoints = {
        "hrms_employees": "/hrms/employees",
        "hrms_attendance": "/hrms/attendance",
        "hrms_payroll": "/hrms/payroll",
        "hrms_performance": "/hrms/performance",
        "hrms_leave": "/hrms/leave",
        "hrms_training": "/hrms/training",
        "hrms_recruitment": "/hrms/recruitment",
        "hrms_benefits": "/hrms/benefits",
        "hrms_departments": "/hrms/departments",
        "hrms_time_tracking": "/hrms/time_tracking"
    }

    return jsonify(api_endpoints)

@app.route('/erp', methods=['GET'])
def erp_api_overview():
    api_endpoints = {
            "erp_accounts": "/erp/accounts",
            "erp_transactions": "/erp/transactions",
            "erp_ledger": "/erp/ledger",
            "erp_invoices": "/erp/invoices",
            "erp_assets": "/erp/assets",
            "erp_inventory": "/erp/inventory",
            "erp_loans": "/erp/loans",
            "erp_payments": "/erp/payments",
            "erp_revenue": "/erp/revenue"
        }
    return jsonify(api_endpoints)


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
