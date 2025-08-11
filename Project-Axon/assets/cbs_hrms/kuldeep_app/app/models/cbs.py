from faker import Faker
import random
from datetime import datetime

fake = Faker()

class CBSCustomer:
    def __init__(self):
        self.customer_id = fake.random_int(min=1, max=99)
        self.first_name = fake.first_name()
        self.last_name = fake.last_name()
        self.email = fake.email()
        self.phone = fake.phone_number()
        self.dob = fake.date_of_birth().isoformat()
        self.address = fake.address()
        self.city = fake.city()
        self.state = fake.state()
        self.postal_code = fake.zipcode()
        self.country = fake.country()
        self.gender = random.choice(['Male', 'Female', 'Other'])
        self.kyc_status = random.choice(['Verified', 'Pending', 'Rejected'])
        self.customer_type = random.choice(['Individual', 'Corporate'])
        self.relationship_manager_id = fake.random_int(min=1, max=1000)
        self.customer_status = random.choice(['Active', 'Inactive', 'Lead', 'Prospect'])
        self.source = random.choice(['Website', 'Referral', 'Campaign', 'Social Media'])
        self.created_at = fake.date_time_this_decade().strftime("%Y-%m-%d %H:%M:%S")
        self.updated_at = fake.date_time_this_year().strftime("%Y-%m-%d %H:%M:%S")

    def to_dict(self) -> dict:
        return self.__dict__

class CBSAccount:
    def __init__(self):
        self.account_id = fake.random_int(min=1, max=99)
        self.account_number = fake.random_int(min=1, max=99)
        self.customer_id = fake.random_int(min=1, max=99)
        self.account_type = random.choice(['Savings', 'Current', 'Fixed Deposit'])
        self.balance = round(random.uniform(500, 50000000), 2)
        self.interest_rate = round(random.uniform(0.5, 5.0), 2)
        self.branch_id = fake.random_int(min=1, max=99)
        self.currency_type = random.choice(['USD', 'EUR', 'INR', 'GBP'])
        self.account_status = random.choice(['Active', 'Dormant', 'Closed'])
        self.last_transaction_date = fake.date_time_this_month().strftime("%Y-%m-%d %H:%M:%S")
        self.created_at = fake.date_time_this_decade().strftime("%Y-%m-%d %H:%M:%S")

    def to_dict(self) -> dict:
        return self.__dict__

class CBSTransaction:
    def __init__(self):
        self.transaction_id = fake.random_int(min=1, max=99)
        self.account_number = fake.random_int(min=1, max=99)
        self.transaction_type = random.choice(['Credit', 'Debit', 'Deposit', 'Withdrawal'])
        self.amount = round(random.uniform(10, 500000000), 2)
        self.transaction_date = fake.date_time_this_month().strftime("%Y-%m-%d %H:%M:%S")
        self.branch_id = fake.random_int(min=1, max=99)
        self.transaction_reference_id = fake.uuid4()
        self.currency_type = random.choice(['USD', 'EUR', 'INR', 'GBP'])
        self.transaction_mode = random.choice(['Online', 'ATM', 'Cheque', 'Cash', 'Credit Card', 'Bank Transfer', 'UPI', 'RTGS'])
        self.transaction_status = random.choice(['Confirmed', 'Pending', 'Declined', 'Success', 'Failed'])
        self.transaction_due_date = fake.date_time_this_year().strftime("%Y-%m-%d %H:%M:%S")
        self.description = fake.sentence()

    def to_dict(self) -> dict:
        return self.__dict__

class CBSLoan:
    def __init__(self):
        self.loan_id = fake.random_int(min=1, max=99)
        self.customer_id = fake.random_int(min=1, max=99)
        self.loan_type = random.choice(['Home Loan', 'Personal Loan', 'Car Loan'])
        self.principal_amount = round(random.uniform(1000, 50000000), 2)
        self.interest_rate = round(random.uniform(1.5, 12.0), 2)
        self.start_date = fake.date_time_this_decade().strftime("%Y-%m-%d %H:%M:%S")
        self.end_date = fake.date_time_this_decade().strftime("%Y-%m-%d %H:%M:%S")
        self.account_number = fake.random_int(min=100000000, max=999999999)
        self.emi_amount = round(random.uniform(100, 50000), 2)
        self.loan_status = random.choice(['Approved', 'Rejected', 'Pending', 'Active', 'Closed', 'Defaulted'])
        self.outstanding_balance = round(random.uniform(0, 5000000), 2)

    def to_dict(self) -> dict:
        return self.__dict__

class CBSFeedback:
    def __init__(self):
        self.feedback_id = fake.random_int(min=1, max=99)
        self.customer_id = fake.random_int(min=1, max=99)
        self.branch_id = fake.random_int(min=1, max=99)
        self.feedback_date = fake.date_time_this_month().strftime("%Y-%m-%d %H:%M:%S")
        self.feedback_type = random.choice(['Complaint', 'Praise', 'Suggestion'])
        self.feedback_rating = random.randint(1, 5)
        self.feedback_status = random.choice(['Open', 'Resolved'])
        self.feedback_comment = fake.text(max_nb_chars=200)

    def to_dict(self) -> dict:
        return self.__dict__
