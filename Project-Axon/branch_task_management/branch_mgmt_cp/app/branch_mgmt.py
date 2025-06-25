#Handles data generation
import random
from faker import Faker
from app.history import HistoryStore  # Ensure correct import

fake = Faker()
history_store = HistoryStore()

def generate_unique_data(generator_func, history_store, table_name):
    """Ensures generated data is unique by checking the history store"""
    while True:
        data = generator_func()
        if history_store.is_unique(table_name, data):
            history_store.add(table_name, data)
            return data

def generate_branch():
    """Generates a unique branch"""
    return generate_unique_data(lambda: {
        'branch_id': (branch_id := random.randint(1, 99)),
        'branch_name': fake.company(),
        'location': fake.city(),
        'region': random.choice(['North', 'South', 'East', 'West']),
        'manager_id': f"MGR{branch_id}",
        'ifsc_code': f"{''.join(fake.company().split()[:4]).upper()[:4]}{branch_id}",
        'established_date': fake.date_this_century().strftime('%Y-%m-%d')
    }, history_store, "branches")

def generate_daily_operation():
    """Generates a unique daily operation for a branch"""
    branch = generate_branch()
    return generate_unique_data(lambda: {
        'operation_id': fake.uuid4(),
        'branch_id': branch['branch_id'],
        'operation_date': fake.date_this_year().strftime('%Y-%m-%d'),
        'customers_served': random.randint(100, 500),
        'transactions_processed': random.randint(50, 200),
        'staff_count': random.randint(5, 20),
        'operational_cost': round(random.uniform(1000, 5000), 2)
    }, history_store, "operations")

def generate_inventory():
    """Generates unique inventory for a branch"""
    branch = generate_branch()
    return generate_unique_data(lambda: {
        'inventory_id': fake.uuid4(),
        'branch_id': branch['branch_id'],
        'product_id': fake.uuid4(),
        'product_name': random.choice(['InstaKit', 'POS Terminal', 'Lockers', 'Debit Cards']),
        'stock_quantity': (quantity := random.randint(10, 100)),
        'unit_price': (unit_price := round(random.uniform(50, 2000), 2)),
        'status': random.choice(['Available', 'Out of Stock']),
        'stock_value': round(quantity * unit_price, 2)  # Fixed stock value calculation
    }, history_store, "inventory")

def generate_asset():
    """Generates a unique asset"""
    branch = generate_branch()
    return generate_unique_data(lambda: {
        'asset_id': fake.uuid4(),
        'branch_id': branch['branch_id'],
        'asset_type': random.choice(['ATM', 'Branch Furniture', 'Security Camera', 'Building', 'Vehicle', 'Desktop', 'Keyboard', 'Mouse']),
        'location': fake.city(),
        'purchase_date': fake.date_this_decade().strftime('%Y-%m-%d'),
        'status': random.choice(['Operational', 'Under Maintenance', 'Retired'])
    }, history_store, "assets")

