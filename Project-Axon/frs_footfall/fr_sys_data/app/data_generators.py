from faker import Faker
import random
from datetime import datetime, timedelta

fake = Faker()

# Predefined list of 99 unique branch IDs between 1 and 99
BRANCHES = random.sample(range(1, 100), 99)
BRANCH_METADATA = [
    {"BranchID": bid, "BranchName": fake.company(), "BranchLocation": fake.address()}
    for bid in BRANCHES
]

# Helper: Get a random BranchID from predefined list
def get_random_branch_id():
    return random.choice(BRANCHES)

# Helper: Get a date between 2021 and 2025
def get_random_date():
    start_date = datetime(2021, 1, 1)
    end_date = datetime(2025, 12, 31)
    delta = end_date - start_date
    random_days = random.randint(0, delta.days)
    return (start_date + timedelta(days=random_days)).date().isoformat()

# Unique data generation logic
def generate_unique_data(generator_func, history_store, table_name):
    while True:
        data = generator_func()
        if history_store.is_unique(table_name, data):
            history_store.add(table_name, data)
            return data

generated_ids = set()

def unique_8_digit_id():
    while True:
        new_id = fake.random_int(min=10000000, max=99999999)
        if new_id not in generated_ids:
            generated_ids.add(new_id)
            return new_id

# Branch data is predefined and seeded once
def generate_branch_data(history_store):
    for branch in BRANCH_METADATA:
        history_store.add("branch", branch)
    return BRANCH_METADATA

# Revenue generator with amount logic based on type
def generate_revenue_data(history_store):
    def revenue_generator():
        revenue_type = random.choice(["Service Fees", "Loan Interest"])
        amount = round(
            random.uniform(50, 200), 2
        ) if revenue_type == "Service Fees" else round(random.uniform(1000, 50000), 2)

        return {
            "RevenueID": unique_8_digit_id(),
            "BranchID": get_random_branch_id(),
            "Record_Date": get_random_date(),
            "RevenueType": revenue_type,
            "Amount": amount,
            "Description": fake.sentence()
        }
    return generate_unique_data(revenue_generator, history_store, "revenue")

def generate_expense_data(history_store):
    def expense_generator():
        return {
            "ExpenseID": unique_8_digit_id(),
            "BranchID": get_random_branch_id(),
            "Record_Date": get_random_date(),
            "ExpenseType": random.choice(["Salaries", "Rent", "Utilities"]),
            "Amount": round(random.uniform(500, 20000), 2),
            "Description": fake.sentence()
        }
    return generate_unique_data(expense_generator, history_store, "expense")

def generate_pnl_data(history_store):
    def pnl_generator():
        total_revenue = round(random.uniform(10000, 100000), 2)
        total_expense = round(random.uniform(5000, total_revenue), 2)
        return {
            "PnLID": unique_8_digit_id(),
            "BranchID": get_random_branch_id(),
            "Record_Date": get_random_date(),
            "TotalRevenue": total_revenue,
            "TotalExpense": total_expense,
            "NetProfitLoss": round(total_revenue - total_expense, 2),
            "ProfitMargin": round((total_revenue - total_expense) / total_revenue * 100, 2)
        }
    return generate_unique_data(pnl_generator, history_store, "pnl")

def generate_cashflow_data(history_store):
    def cashflow_generator():
        cash_inflow = round(random.uniform(10000, 100000), 2)
        cash_outflow = round(random.uniform(5000, cash_inflow), 2)
        return {
            "CashFlowID": unique_8_digit_id(),
            "BranchID": get_random_branch_id(),
            "Record_Date": get_random_date(),
            "CashInflow": cash_inflow,
            "CashOutflow": cash_outflow,
            "NetCashFlow": round(cash_inflow - cash_outflow, 2),
            "OperatingCashFlow": round(random.uniform(1000, 5000), 2),
            "InvestingCashFlow": round(random.uniform(-5000, 10000), 2),
            "FinancingCashFlow": round(random.uniform(-2000, 5000), 2)
        }
    return generate_unique_data(cashflow_generator, history_store, "cashflow")

