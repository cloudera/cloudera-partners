from faker import Faker
import random
from datetime import datetime

fake = Faker()

def generate_unique_data(generator_func, history_store, table_name):
    while True:
        data = generator_func()
        if history_store.is_unique(table_name, data):
            history_store.add(table_name, data)
            return data

def generate_branch_data(history_store):
    def branch_generator():
        return {
            "BranchID": fake.unique.uuid4(),
            "BranchName": fake.company(),
            "BranchLocation": fake.address()
        }
    return generate_unique_data(branch_generator, history_store, "branch")

def generate_revenue_data(history_store):
    def revenue_generator():
        return {
            "RevenueID": fake.unique.uuid4(),
            "BranchID": fake.uuid4(),
            "Date": fake.date_this_year().isoformat(),
            "RevenueType": random.choice(["Service Fees", "Loan Interest"]),
            "Amount": round(random.uniform(1000, 50000), 2),
            "Description": fake.sentence()
        }
    return generate_unique_data(revenue_generator, history_store, "revenue")

def generate_expense_data(history_store):
    def expense_generator():
        return {
            "ExpenseID": fake.unique.uuid4(),
            "BranchID": fake.uuid4(),
            "Date": fake.date_this_year().isoformat(),
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
            "PnLID": fake.unique.uuid4(),
            "BranchID": fake.uuid4(),
            "Date": fake.date_this_year().isoformat(),
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
            "CashFlowID": fake.unique.uuid4(),
            "BranchID": fake.uuid4(),
            "Date": fake.date_this_year().isoformat(),
            "CashInflow": cash_inflow,
            "CashOutflow": cash_outflow,
            "NetCashFlow": round(cash_inflow - cash_outflow, 2),
            "OperatingCashFlow": round(random.uniform(1000, 5000), 2),
            "InvestingCashFlow": round(random.uniform(-5000, 10000), 2),
            "FinancingCashFlow": round(random.uniform(-2000, 5000), 2)
        }
    return generate_unique_data(cashflow_generator, history_store, "cashflow")

