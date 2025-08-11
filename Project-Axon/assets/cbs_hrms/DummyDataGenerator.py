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
        self.status = random.choice(['Active', 'Inactive', 'Lead', 'Prospect'])
        self.source = random.choice(['Website', 'Referral', 'Campaign', 'Social Media'])
        self.created_at = fake.date_this_decade()
        self.updated_at = fake.date_this_year()

    def to_dict(self) -> dict:
        return {
            'customer_id': self.customer_id,
            'first_name': self.first_name,
            'last_name': self.last_name,
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
            'updated_at': str(self.updated_at)
        }

# 2. crm_interactions
class CRMInteraction:
    def __init__(self):
        self.interaction_id = fake.random_int(min=1000, max=9999)
        self.customer_id = fake.random_int(min=1, max=99999)
        self.interaction_type = random.choice(['Call', 'Email', 'Meeting', 'Message'])
        self.interaction_date = fake.date_this_year()
        self.outcome = random.choice(['Successful', 'Unsuccessful'])
        self.notes = fake.text(max_nb_chars=100)

    def to_dict(self) -> dict:
        return {
            'interaction_id': self.interaction_id,
            'customer_id': self.customer_id,
            'interaction_type': self.interaction_type,
            'interaction_date': str(self.interaction_date),
            'outcome': self.outcome,
            'notes': self.notes
        }

# 3. crm_support_tickets
class CRMSupportTicket:
    def __init__(self):
        self.ticket_id = fake.random_int(min=1000, max=9999)
        self.customer_id = fake.random_int(min=1, max=99999)
        self.issue_type = random.choice(['Technical', 'Billing', 'General Inquiry'])
        self.status = random.choice(['Open', 'Closed', 'In Progress'])
        self.created_at = fake.date_this_year()
        self.updated_at = fake.date_this_month()

    def to_dict(self) -> dict:
        return {
            'ticket_id': self.ticket_id,
            'customer_id': self.customer_id,
            'issue_type': self.issue_type,
            'status': self.status,
            'created_at': str(self.created_at),
            'updated_at': str(self.updated_at)
        }

# 4. crm_opportunities
class CRMOpportunity:
    def __init__(self):
        self.opportunity_id = fake.random_int(min=1000, max=9999)
        self.customer_id = fake.random_int(min=1, max=99999)
        self.status = random.choice(['Open', 'Closed Won', 'Closed Lost'])
        self.expected_value = round(random.uniform(1000, 50000), 2)
        self.created_at = fake.date_this_year()

    def to_dict(self) -> dict:
        return {
            'opportunity_id': self.opportunity_id,
            'customer_id': self.customer_id,
            'status': self.status,
            'expected_value': self.expected_value,
            'created_at': str(self.created_at)
        }

# 5. crm_campaigns
class CRMCampaign:
    def __init__(self):
        self.campaign_id = fake.random_int(min=1000, max=9999)
        self.name = fake.bs()
        self.start_date = fake.date_this_year()
        self.end_date = fake.date_this_year()
        self.status = random.choice(['Active', 'Completed', 'Pending'])
        self.budget = round(random.uniform(1000, 50000), 2)

    def to_dict(self) -> dict:
        return {
            'campaign_id': self.campaign_id,
            'name': self.name,
            'start_date': str(self.start_date),
            'end_date': str(self.end_date),
            'status': self.status,
            'budget': self.budget
        }

# 6. crm_customer_campaigns
class CRMCustomerCampaign:
    def __init__(self):
        self.customer_campaign_id = fake.random_int(min=1000, max=9999)
        self.customer_id = fake.random_int(min=1, max=99999)
        self.campaign_id = fake.random_int(min=1000, max=9999)
        self.enrolled_at = fake.date_this_year()

    def to_dict(self) -> dict:
        return {
            'customer_campaign_id': self.customer_campaign_id,
            'customer_id': self.customer_id,
            'campaign_id': self.campaign_id,
            'enrolled_at': str(self.enrolled_at)
        }

# 7. crm_feedback
class CRMFeedback:
    def __init__(self):
        self.feedback_id = fake.random_int(min=1000, max=9999)
        self.customer_id = fake.random_int(min=1, max=99999)
        self.rating = random.choice([1, 2, 3, 4, 5])
        self.comments = fake.text(max_nb_chars=200)
        self.submitted_at = fake.date_this_month()

    def to_dict(self) -> dict:
        return {
            'feedback_id': self.feedback_id,
            'customer_id': self.customer_id,
            'rating': self.rating,
            'comments': self.comments,
            'submitted_at': str(self.submitted_at)
        }

# 8. crm_transactions
class CRMTransaction:
    def __init__(self):
        self.transaction_id = fake.random_int(min=1000, max=9999)
        self.customer_id = fake.random_int(min=1, max=99999)
        self.transaction_type = random.choice(['Deposit', 'Withdrawal', 'Transfer'])
        self.amount = round(random.uniform(10, 5000), 2)
        self.transaction_date = fake.date_this_month()
        self.status = random.choice(['Success', 'Failed'])

    def to_dict(self) -> dict:
        return {
            'transaction_id': self.transaction_id,
            'customer_id': self.customer_id,
            'transaction_type': self.transaction_type,
            'amount': self.amount,
            'transaction_date': str(self.transaction_date),
            'status': self.status
        }

# --- ERP Tables ---

# 9. erp_accounts
class ERPAccount:
    def __init__(self):
        self.account_id = fake.random_int(min=100000, max=999999)
        self.customer_id = fake.random_int(min=1, max=99999)
        self.account_type = random.choice(['Checking', 'Savings', 'Loan', 'Credit'])
        self.balance = round(random.uniform(1000, 50000), 2)
        self.status = random.choice(['Active', 'Inactive', 'Closed'])
        self.created_at = fake.date_this_decade()

    def to_dict(self) -> dict:
        return {
            'account_id': self.account_id,
            'customer_id': self.customer_id,
            'account_type': self.account_type,
            'balance': self.balance,
            'status': self.status,
            'created_at': str(self.created_at)
        }

# 10. erp_transactions
class ERPTransaction:
    def __init__(self):
        self.transaction_id = fake.random_int(min=1000, max=9999)
        self.account_id = fake.random_int(min=100000, max=999999)
        self.transaction_type = random.choice(['Deposit', 'Withdrawal', 'Transfer'])
        self.amount = round(random.uniform(10, 5000), 2)
        self.transaction_date = fake.date_this_month()
        self.status = random.choice(['Success', 'Failed'])

    def to_dict(self) -> dict:
        return {
            'transaction_id': self.transaction_id,
            'account_id': self.account_id,
            'transaction_type': self.transaction_type,
            'amount': self.amount,
            'transaction_date': str(self.transaction_date),
            'status': self.status
        }

# 11. erp_ledger
class ERPLedger:
    def __init__(self):
        self.ledger_id = fake.random_int(min=1000, max=9999)
        self.account_id = fake.random_int(min=100000, max=999999)
        self.transaction_id = fake.random_int(min=1000, max=9999)
        self.amount = round(random.uniform(10, 5000), 2)
        self.ledger_date = fake.date_this_year()
        self.status = random.choice(['Posted', 'Pending'])

    def to_dict(self) -> dict:
        return {
            'ledger_id': self.ledger_id,
            'account_id': self.account_id,
            'transaction_id': self.transaction_id,
            'amount': self.amount,
            'ledger_date': str(self.ledger_date),
            'status': self.status
        }

# 12. erp_invoices
class ERPInvoice:
    def __init__(self):
        self.invoice_id = fake.random_int(min=1000, max=9999)
        self.customer_id = fake.random_int(min=1, max=99999)
        self.amount = round(random.uniform(100, 10000), 2)
        self.due_date = fake.date_this_month()
        self.status = random.choice(['Paid', 'Unpaid'])

    def to_dict(self) -> dict:
        return {
            'invoice_id': self.invoice_id,
            'customer_id': self.customer_id,
            'amount': self.amount,
            'due_date': str(self.due_date),
            'status': self.status
        }

# 13. erp_assets
class ERPAsset:
    def __init__(self):
        self.asset_id = fake.random_int(min=1000, max=9999)
        self.asset_type = random.choice(['ATM', 'Branch', 'Vehicle', 'Software'])
        self.location = fake.address()
        self.purchase_date = fake.date_this_decade()
        self.status = random.choice(['Active', 'Inactive'])

    def to_dict(self) -> dict:
        return {
            'asset_id': self.asset_id,
            'asset_type': self.asset_type,
            'location': self.location,
            'purchase_date': str(self.purchase_date),
            'status': self.status
        }

# 14. erp_inventory
class ERPInventory:
    def __init__(self):
        self.inventory_id = fake.random_int(min=1000, max=9999)
        self.product_name = fake.bs()
        self.quantity = fake.random_int(min=1, max=500)
        self.unit_price = round(random.uniform(10, 500), 2)
        self.status = random.choice(['Available', 'Sold Out'])

    def to_dict(self) -> dict:
        return {
            'inventory_id': self.inventory_id,
            'product_name': self.product_name,
            'quantity': self.quantity,
            'unit_price': self.unit_price,
            'status': self.status
        }

# 15. erp_loans
class ERPLoan:
    def __init__(self):
        self.loan_id = fake.random_int(min=1000, max=9999)
        self.customer_id = fake.random_int(min=1, max=99999)
        self.loan_type = random.choice(['Personal', 'Business', 'Mortgage'])
        self.amount = round(random.uniform(1000, 50000), 2)
        self.status = random.choice(['Approved', 'Rejected', 'Pending'])

    def to_dict(self) -> dict:
        return {
            'loan_id': self.loan_id,
            'customer_id': self.customer_id,
            'loan_type': self.loan_type,
            'amount': self.amount,
            'status': self.status
        }

# 16. erp_payments
class ERPPayment:
    def __init__(self):
        self.payment_id = fake.random_int(min=1000, max=9999)
        self.customer_id = fake.random_int(min=1, max=99999)
        self.amount = round(random.uniform(100, 5000), 2)
        self.payment_date = fake.date_this_month()
        self.payment_method = random.choice(['Credit Card', 'Bank Transfer', 'Cash'])

    def to_dict(self) -> dict:
        return {
            'payment_id': self.payment_id,
            'customer_id': self.customer_id,
            'amount': self.amount,
            'payment_date': str(self.payment_date),
            'payment_method': self.payment_method
        }

# 17. erp_revenue
class ERPRevenue:
    def __init__(self):
        self.revenue_id = fake.random_int(min=1000, max=9999)
        self.account_id = fake.random_int(min=100000, max=999999)
        self.amount = round(random.uniform(10, 5000), 2)
        self.revenue_type = random.choice(['Interest', 'Fees', 'Other'])
        self.revenue_date = fake.date_this_year()

    def to_dict(self) -> dict:
        return {
            'revenue_id': self.revenue_id,
            'account_id': self.account_id,
            'amount': self.amount,
            'revenue_type': self.revenue_type,
            'revenue_date': str(self.revenue_date)
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
        self.position = random.choice(['Manager', 'Associate', 'Director', 'Executive'])
        self.hire_date = fake.date_this_decade()
        self.salary = round(random.uniform(30000, 120000), 2)
        self.status = random.choice(['Active', 'Inactive'])

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
            'status': self.status
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

# 20. hrms_payroll
class HRMSPayroll:
    def __init__(self):
        self.payroll_id = fake.random_int(min=1000, max=9999)
        self.employee_id = fake.random_int(min=1, max=9999)
        self.salary = round(random.uniform(30000, 120000), 2)
        self.bonus = round(random.uniform(1000, 5000), 2)
        self.deductions = round(random.uniform(100, 1000), 2)
        self.pay_date = fake.date_this_month()

    def to_dict(self) -> dict:
        return {
            'payroll_id': self.payroll_id,
            'employee_id': self.employee_id,
            'salary': self.salary,
            'bonus': self.bonus,
            'deductions': self.deductions,
            'pay_date': str(self.pay_date)
        }

# 21. hrms_performance
class HRMSPerformance:
    def __init__(self):
        self.performance_id = fake.random_int(min=1000, max=9999)
        self.employee_id = fake.random_int(min=1, max=9999)
        self.performance_rating = random.choice([1, 2, 3, 4, 5])
        self.review_date = fake.date_this_year()
        self.comments = fake.text(max_nb_chars=150)

    def to_dict(self) -> dict:
        return {
            'performance_id': self.performance_id,
            'employee_id': self.employee_id,
            'performance_rating': self.performance_rating,
            'review_date': str(self.review_date),
            'comments': self.comments
        }

# 22. hrms_leave
class HRMSLeave:
    def __init__(self):
        self.leave_id = fake.random_int(min=1000, max=9999)
        self.employee_id = fake.random_int(min=1, max=9999)
        self.leave_type = random.choice(['Sick', 'Vacation', 'Unpaid'])
        self.leave_start = fake.date_this_year()
        self.leave_end = fake.date_this_year()
        self.status = random.choice(['Approved', 'Pending', 'Rejected'])

    def to_dict(self) -> dict:
        return {
            'leave_id': self.leave_id,
            'employee_id': self.employee_id,
            'leave_type': self.leave_type,
            'leave_start': str(self.leave_start),
            'leave_end': str(self.leave_end),
            'status': self.status
        }

# 23. hrms_training
class HRMSTraining:
    def __init__(self):
        self.training_id = fake.random_int(min=1000, max=9999)
        self.employee_id = fake.random_int(min=1, max=9999)
        self.training_name = fake.bs()
        self.start_date = fake.date_this_year()
        self.end_date = fake.date_this_year()
        self.status = random.choice(['Completed', 'Ongoing', 'Scheduled'])

    def to_dict(self) -> dict:
        return {
            'training_id': self.training_id,
            'employee_id': self.employee_id,
            'training_name': self.training_name,
            'start_date': str(self.start_date),
            'end_date': str(self.end_date),
            'status': self.status
        }

# 24. hrms_recruitment
class HRMSRecruitment:
    def __init__(self):
        self.recruitment_id = fake.random_int(min=1000, max=9999)
        self.job_title = random.choice(['Software Engineer', 'HR Manager', 'Product Manager', 'Operations Executive'])
        self.job_description = fake.text(max_nb_chars=150)
        self.application_deadline = fake.date_this_year()
        self.status = random.choice(['Open', 'Closed', 'On Hold'])

    def to_dict(self) -> dict:
        return {
            'recruitment_id': self.recruitment_id,
            'job_title': self.job_title,
            'job_description': self.job_description,
            'application_deadline': str(self.application_deadline),
            'status': self.status
        }

# 25. hrms_benefits
class HRMSBenefits:
    def __init__(self):
        self.benefit_id = fake.random_int(min=1000, max=9999)
        self.employee_id = fake.random_int(min=1, max=9999)
        self.benefit_type = random.choice(['Health Insurance', 'Retirement Plan', 'Paid Time Off', 'Stock Options'])
        self.start_date = fake.date_this_year()
        self.end_date = fake.date_this_year()
        self.status = random.choice(['Active', 'Expired', 'Pending'])

    def to_dict(self) -> dict:
        return {
            'benefit_id': self.benefit_id,
            'employee_id': self.employee_id,
            'benefit_type': self.benefit_type,
            'start_date': str(self.start_date),
            'end_date': str(self.end_date),
            'status': self.status
        }

# 26. hrms_departments
class HRMSDepartment:
    def __init__(self):
        self.department_id = fake.random_int(min=1000, max=9999)
        self.department_name = random.choice(['Sales', 'IT', 'Operations', 'Finance', 'HR'])
        self.manager = fake.name()
        self.location = fake.city()

    def to_dict(self) -> dict:
        return {
            'department_id': self.department_id,
            'department_name': self.department_name,
            'manager': self.manager,
            'location': self.location
        }

# 27. hrms_time_tracking
class HRMSTimeTracking:
    def __init__(self):
        self.time_tracking_id = fake.random_int(min=1000, max=9999)
        self.employee_id = fake.random_int(min=1, max=9999)
        self.date = fake.date_this_month()
        self.hours_worked = round(random.uniform(4, 10), 2)
        self.overtime_hours = round(random.uniform(0, 3), 2)
        self.status = random.choice(['Approved', 'Pending', 'Rejected'])

    def to_dict(self) -> dict:
        return {
            'time_tracking_id': self.time_tracking_id,
            'employee_id': self.employee_id,
            'date': str(self.date),
            'hours_worked': self.hours_worked,
            'overtime_hours': self.overtime_hours,
            'status': self.status
        }

# --- Routes ---
@app.route('/crm/customer', methods=['GET'])
def generate_customer():
    customer = CRMCustomer()
    data = customer.to_dict()
    logger.info(f"Generated customer data: {data}")
    return jsonify(data)

@app.route('/crm/interaction', methods=['GET'])
def generate_crm_interaction():
    interaction = CRMInteraction()
    data = interaction.to_dict()
    logger.info(f"Generated CRM interaction data: {data}")
    return jsonify(data)

@app.route('/crm/ticket', methods=['GET'])
def generate_support_ticket():
    ticket = CRMSupportTicket()
    data = ticket.to_dict()
    logger.info(f"Generated CRM support ticket data: {data}")
    return jsonify(data)

@app.route('/crm/opportunity', methods=['GET'])
def generate_opportunity():
    opportunity = CRMOpportunity()
    data = opportunity.to_dict()
    logger.info(f"Generated CRM opportunity data: {data}")
    return jsonify(data)

@app.route('/crm/campaign', methods=['GET'])
def generate_campaign():
    campaign = CRMCampaign()
    data = campaign.to_dict()
    logger.info(f"Generated CRM campaign data: {data}")
    return jsonify(data)

@app.route('/crm/customer_campaign', methods=['GET'])
def generate_customer_campaign():
    customer_campaign = CRMCustomerCampaign()
    data = customer_campaign.to_dict()
    logger.info(f"Generated CRM customer campaign data: {data}")
    return jsonify(data)

@app.route('/crm/feedback', methods=['GET'])
def generate_feedback():
    feedback = CRMFeedback()
    data = feedback.to_dict()
    logger.info(f"Generated CRM feedback data: {data}")
    return jsonify(data)

@app.route('/crm/transaction', methods=['GET'])
def generate_crm_transaction():
    transaction = CRMTransaction()
    data = transaction.to_dict()
    logger.info(f"Generated CRM transaction data: {data}")
    return jsonify(data)

@app.route('/erp/account', methods=['GET'])
def generate_account():
    account = ERPAccount()
    data = account.to_dict()
    logger.info(f"Generated ERP account data: {data}")
    return jsonify(data)

@app.route('/erp/transaction', methods=['GET'])
def generate_erp_transaction():
    erp_transaction = ERPTransaction()
    data = erp_transaction.to_dict()
    logger.info(f"Generated ERP transaction data: {data}")
    return jsonify(data)

@app.route('/erp/ledger', methods=['GET'])
def generate_erp_ledger():
    ledger = ERPLedger()
    data = ledger.to_dict()
    logger.info(f"Generated ERP ledger data: {data}")
    return jsonify(data)

@app.route('/erp/invoice', methods=['GET'])
def generate_invoice():
    invoice = ERPInvoice()
    data = invoice.to_dict()
    logger.info(f"Generated ERP invoice data: {data}")
    return jsonify(data)

@app.route('/erp/asset', methods=['GET'])
def generate_asset():
    asset = ERPAsset()
    data = asset.to_dict()
    logger.info(f"Generated ERP asset data: {data}")
    return jsonify(data)

@app.route('/erp/inventory', methods=['GET'])
def generate_inventory():
    inventory = ERPInventory()
    data = inventory.to_dict()
    logger.info(f"Generated ERP inventory data: {data}")
    return jsonify(data)

@app.route('/erp/loan', methods=['GET'])
def generate_erp_loan():
    loan = ERPLoan()
    data = loan.to_dict()
    logger.info(f"Generated ERP loan data: {data}")
    return jsonify(data)

@app.route('/erp/payment', methods=['GET'])
def generate_payment():
    payment = ERPPayment()
    data = payment.to_dict()
    logger.info(f"Generated ERP payment data: {data}")
    return jsonify(data)

@app.route('/erp/revenue', methods=['GET'])
def generate_revenue():
    revenue = ERPRevenue()
    data = revenue.to_dict()
    logger.info(f"Generated ERP revenue data: {data}")
    return jsonify(data)

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

@app.route('/hrm/payroll', methods=['GET'])
def generate_payroll():
    payroll = HRMSPayroll()
    data = payroll.to_dict()
    logger.info(f"Generated HRMS payroll data: {data}")
    return jsonify(data)

@app.route('/hrm/performance', methods=['GET'])
def generate_performance():
    performance = HRMSPerformance()
    data = performance.to_dict()
    logger.info(f"Generated HRMS performance data: {data}")
    return jsonify(data)

@app.route('/hrm/leave', methods=['GET'])
def generate_leave():
    leave = HRMSLeave()
    data = leave.to_dict()
    logger.info(f"Generated HRMS leave data: {data}")
    return jsonify(data)

@app.route('/hrm/training', methods=['GET'])
def generate_training():
    training = HRMSTraining()
    data = training.to_dict()
    logger.info(f"Generated HRMS training data: {data}")
    return jsonify(data)

@app.route('/hrm/recruitment', methods=['GET'])
def generate_recruitment():
    recruitment = HRMSRecruitment()
    data = recruitment.to_dict()
    logger.info(f"Generated HRMS recruitment data: {data}")
    return jsonify(data)

@app.route('/hrm/benefits', methods=['GET'])
def generate_benefits():
    benefits = HRMSBenefits()
    data = benefits.to_dict()
    logger.info(f"Generated HRMS benefits data: {data}")
    return jsonify(data)

@app.route('/hrm/department', methods=['GET'])
def generate_department():
    department = HRMSDepartment()
    data = department.to_dict()
    logger.info(f"Generated HRMS department data: {data}")
    return jsonify(data)

@app.route('/hrm/time_tracking', methods=['GET'])
def generate_time_tracking():
    time_tracking = HRMSTimeTracking()
    data = time_tracking.to_dict()
    logger.info(f"Generated HRMS time tracking data: {data}")
    return jsonify(data)

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

# --- Run Flask App ---
if __name__ == "__main__":
    logger.info("Starting Flask application...")
    app.run(debug=True, host='0.0.0.0', port=8084)
